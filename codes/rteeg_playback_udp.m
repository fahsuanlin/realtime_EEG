close all; clear all;

% rteeg_playback_udp  Replay recorded NeurOne UDP packets
%
% This script re-sends packets captured by rteeg_record_udp.m.
% It can preserve original timing or send as fast as possible.
% It loops indefinitely until the user stops it (Ctrl+C).
% It sends a Trigger packet at playback start and another 3 s before end.
%
% Usage:
%   - Set infile and destination parameters below.
%   - Run the script.

%% Parameters
infile = '';                % path to .mat (leave empty to pick via dialog)
destIP = '127.0.0.1';       % destination IP
destPort = 50000;            % destination UDP port
preserveTiming = true;      % true = replay with recorded timing
speedFactor = 1.0;          % >1 faster, <1 slower (applies only if preserveTiming)
verbose = true;
% Trigger packet settings
triggerMainUnitNum = uint8(0);
triggerType = uint8(3*16 + 4);   % source id=3 (parallel), mode=4 (parallel)
triggerCodeStart = uint8(1);
triggerCodeEnd = uint8(2);
triggerSamplingRateHz = [];      % set if you want SampleIndex ~= 0

%% Load recording
if isempty(infile)
    [fname, fpath] = uigetfile('*.mat', 'Select recording');
    if isequal(fname, 0)
        error('No input file selected.');
    end
    infile = fullfile(fpath, fname);
end

S = load(infile, 'packets', 'packet_tsec', 'meta');
if ~isfield(S, 'packets') || isempty(S.packets)
    error('No packets found in file: %s', infile);
end

packets = S.packets;
packet_tsec = [];
if isfield(S, 'packet_tsec')
    packet_tsec = S.packet_tsec;
end

if verbose
    fprintf('Loaded %d packets from %s\n', numel(packets), infile);
end

%% Init UDP
if exist('udpport', 'file') ~= 2
    error('udpport not available in this MATLAB version.');
end
u = udpport("datagram", "IPV4");
cleanupObj = onCleanup(@() clear u);

%% Replay (loop until user breaks)
endTimeSec = 0;
if ~isempty(packet_tsec)
    endTimeSec = packet_tsec(end);
elseif isfield(S, 'meta') && isfield(S.meta, 'durationSec')
    endTimeSec = S.meta.durationSec;
end

loopCount = 0;
while true
    loopCount = loopCount + 1;
    if verbose
        fprintf('Playback loop %d (Ctrl+C to stop)\n', loopCount);
    end

    tLoopStart = tic;
    send_trigger(u, destIP, destPort, triggerMainUnitNum, triggerType, triggerCodeStart, 0, triggerSamplingRateHz);

    endTriggerSent = false;
    endTriggerTimeScaled = endTimeSec;
    if preserveTiming
        endTriggerTimeScaled = endTimeSec / max(speedFactor, eps);
    end
    if preserveTiming && ~isempty(packet_tsec) && endTriggerTimeScaled <= 0
        send_trigger(u, destIP, destPort, triggerMainUnitNum, triggerType, triggerCodeEnd, 0, triggerSamplingRateHz);
        endTriggerSent = true;
    end

    for i = 1:numel(packets)
        write(u, packets{i}, "uint8", destIP, destPort);
        if preserveTiming && ~isempty(packet_tsec)
            tTarget = packet_tsec(i) / max(speedFactor, eps);
            while toc(tLoopStart) < tTarget
                if ~endTriggerSent && toc(tLoopStart) >= endTriggerTimeScaled
                    send_trigger(u, destIP, destPort, triggerMainUnitNum, triggerType, triggerCodeEnd, toc(tLoopStart), triggerSamplingRateHz);
                    endTriggerSent = true;
                end
                pause(0.0005);
            end
        else
            if ~endTriggerSent && i == numel(packets)
                % No timing info; send end trigger just before the last packet completes.
                send_trigger(u, destIP, destPort, triggerMainUnitNum, triggerType, triggerCodeEnd, 0, triggerSamplingRateHz);
                endTriggerSent = true;
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function send_trigger(u, destIP, destPort, mainUnitNum, trigType, trigCode, tsec, fs)
microTime = uint64(round(tsec * 1e6));
if isempty(fs)
    sampleIndex = uint64(0);
else
    sampleIndex = uint64(round(tsec * fs));
end
pkt = build_trigger_packet(mainUnitNum, trigType, trigCode, microTime, sampleIndex);
write(u, pkt, "uint8", destIP, destPort);
return;

function bytes = build_trigger_packet(mainUnitNum, trigType, trigCode, microTime, sampleIndex)
bytes = uint8([]);
bytes = [bytes, pack_uint8(uint8(3))]; % FrameType
bytes = [bytes, pack_uint8(uint8(mainUnitNum))];
bytes = [bytes, pack_uint16(uint16(1))]; % NumTriggers
bytes = [bytes, pack_uint32(uint32(0))]; % Reserved
bytes = [bytes, pack_uint64(uint64(microTime))];
bytes = [bytes, pack_uint64(uint64(sampleIndex))];
bytes = [bytes, pack_uint8(uint8(trigType))];
bytes = [bytes, pack_uint8(uint8(trigCode))];
bytes = [bytes, pack_uint16(uint16(0))]; % Reserved
return;

function bytes = pack_uint8(val)
bytes = uint8(val(:)).';
return;

function bytes = pack_uint16(val)
bytes = typecast(swapbytes(uint16(val(:))), 'uint8').';
return;

function bytes = pack_uint32(val)
bytes = typecast(swapbytes(uint32(val(:))), 'uint8').';
return;

function bytes = pack_uint64(val)
bytes = typecast(swapbytes(uint64(val(:))), 'uint8').';
return;
