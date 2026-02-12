close all; clear all;

% rteeg_record_udp  Record incoming NeurOne UDP packets to a MAT file
%
% This script records raw UDP datagrams so they can be replayed later.
% It does NOT decode packets (use rteeg_decode during playback if needed).
%
% Usage:
%   - Edit parameters below and run the script.
%   - Press Ctrl+C to stop early (data will still be saved).

%% Parameters
localPort = 50000;           % UDP port to listen on
durationSec = 60;           % max recording duration (seconds)
maxPackets = inf;           % max packets to record
outfile = fullfile(pwd, ['rteeg_record_' datestr(now,'yyyymmdd_HHMMSS') '.mat']);
verbose = true;
checkTimeoutSec = 3;        % UDP sanity check timeout (seconds)

%% UDP sanity check
try
    [ok, info] = rteeg_check_udp_connection('localPort', localPort, 'timeoutSec', checkTimeoutSec, 'verbose', verbose);
    if ~ok
        warning('No UDP packets received during check; recording will still start.');
    end
catch ME
    warning('UDP check failed: %s', ME.message);
end

%% Init UDP
if exist('udpport', 'file') ~= 2
    error('udpport not available in this MATLAB version.');
end

u = udpport("datagram", "IPV4", "LocalPort", localPort);
cleanupObj = onCleanup(@() clear u);

%% Recording loop
packets = {};
packet_len = [];
packet_tsec = [];
packet_src_ip = {};
packet_src_port = [];

tStart = tic;
numRecorded = 0;

if verbose
    fprintf('Recording UDP on port %d for up to %.1f sec...\n', localPort, durationSec);
    fprintf('Output: %s\n', outfile);
    fprintf('Press Ctrl+C to stop early.\n');
end

recordingAborted = false;
try
    while (toc(tStart) < durationSec) && (numRecorded < maxPackets)
        if u.NumDatagramsAvailable > 0
            [data, src] = read(u, 1, "uint8");
            numRecorded = numRecorded + 1;
            packets{numRecorded,1} = uint8(data(:).');
            packet_len(numRecorded,1) = numel(data);
            packet_tsec(numRecorded,1) = toc(tStart);
            packet_src_ip{numRecorded,1} = src.Address;
            packet_src_port(numRecorded,1) = src.Port;
        else
            pause(0.001);
        end
    end
catch ME
    recordingAborted = true;
    warning('Recording interrupted: %s', ME.message);
end

%% Save
meta = struct();
meta.localPort = localPort;
meta.durationSec = durationSec;
meta.maxPackets = maxPackets;
meta.startTime = datestr(now, 'yyyy-mm-dd HH:MM:SS');
meta.numRecorded = numRecorded;
meta.aborted = recordingAborted;

save(outfile, 'packets', 'packet_len', 'packet_tsec', ...
    'packet_src_ip', 'packet_src_port', 'meta', '-v7.3');

if verbose
    fprintf('Saved %d packets to %s\n', numRecorded, outfile);
end
