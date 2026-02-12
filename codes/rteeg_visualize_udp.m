close all; clear all;

% rteeg_visualize_udp  Receive, decode, and visualize NeurOne UDP packets
%
% This script listens on a UDP port, decodes packets with rteeg_decode,
% plots Samples packets using rteeg_draw_trace, optionally shows Morlet
% wavelet amplitude/phase for a selected channel, and archives data.

%% Parameters
localPort = 50000;           % UDP port to listen on
defaultFs = 1000;           % fallback sampling rate if no MeasurementStart
verbose = true;
checkTimeoutSec = 3;        % UDP sanity check timeout (seconds)
windowSec = 0.5;            % rolling window length (s) for spectral view
freqVec = 4:1:250;          % Hz (Morlet frequencies)
waveletCycles = 7;          % Morlet cycles
specChannel = 1;            % channel to visualize spectrum
specUpdateEvery = 20;       % update spectrum every N packets
showSpectrum = true;        % toggle spectral plot
logEnabled = true;          % archive incoming data + spectral features
logFile = fullfile(pwd, ['rteeg_visualize_log_' datestr(now,'yyyymmdd_HHMMSS') '.mat']);
logFlushEveryPackets = 200; % flush packet data to disk every N packets
logFlushEverySpec = 50;     % flush spectral data every N spec updates

%% UDP sanity check
try
    [ok, info] = rteeg_check_udp_connection('localPort', localPort, 'timeoutSec', checkTimeoutSec, 'verbose', verbose);
    if ~ok
        warning('No UDP packets received during check; visualizer will still start.');
    end
catch ME
    warning('UDP check failed: %s', ME.message);
end

%% Init UDP
if exist('udpport', 'file') ~= 2
    error('udpport not available in this MATLAB version.');
end
u = udpport("datagram", "IPV4", "LocalPort", localPort);

%% Receive + plot loop
fs = defaultFs;
trace_obj = [];
buffer = [];
bufferReady = false;
packetCount = 0;

specFig = [];
ampLine = [];
phaseLine = [];
wavelets = [];

% logging state
logMf = [];
logPacketIdx = 0;
logSpecIdx = 0;
logPacketBuf = [];
logPacketT = [];
logPacketBufIdx = 0;
logSpecAmpBuf = [];
logSpecPhaseBuf = [];
logSpecT = [];
logSpecBufIdx = 0;

tStart = tic;
startDatenum = now;
cleanupObj = onCleanup(@() cleanup_all());

if verbose
    fprintf('Listening on UDP port %d (Ctrl+C to stop)...\n', localPort);
end

while true
    if u.NumDatagramsAvailable > 0
        [data, src] = read(u, 1, "uint8");
        dec = rteeg_decode(data);
        if ~isempty(dec) && isfield(dec, 'flag_ok') && dec.flag_ok
            if dec.frameType == 1
                if isfield(dec, 'samplingRateHz')
                    fs = double(dec.samplingRateHz);
                    if verbose
                        fprintf('MeasurementStart: samplingRateHz=%g\n', fs);
                    end
                end
            elseif dec.frameType == 2
                trace_obj = rteeg_draw_trace(double(dec.sample), fs, 'trace_obj', trace_obj);
                packetCount = packetCount + 1;
                if logEnabled
                    log_packet(dec.sample, toc(tStart), startDatenum);
                end

                if showSpectrum
                    % init buffer/wavelets on first sample packet
                    if isempty(buffer)
                        windowSamples = round(windowSec * fs);
                        buffer = zeros(size(dec.sample, 1), windowSamples);
                        bufferReady = false;
                        wavelets = build_morlet_bank(freqVec, fs, windowSamples, waveletCycles);
                        [specFig, ampLine, phaseLine] = init_spectrum_plot(freqVec);
                    end

                    % update rolling buffer
                    n = size(dec.sample, 2);
                    if n >= size(buffer, 2)
                        buffer = double(dec.sample(:, end-size(buffer,2)+1:end));
                        bufferReady = true;
                    else
                        buffer(:, 1:end-n) = buffer(:, n+1:end);
                        buffer(:, end-n+1:end) = double(dec.sample);
                        bufferReady = bufferReady || (packetCount * n >= size(buffer,2));
                    end

                    % update spectrum view
                    if bufferReady && mod(packetCount, specUpdateEvery) == 0
                        x = buffer(specChannel, :);
                        x = x - mean(x);
                        [amp, phase] = morlet_features(x, wavelets);
                        set(ampLine, 'YData', amp);
                        set(phaseLine, 'YData', phase);
                        drawnow limitrate;
                        if logEnabled
                            log_spec(amp, phase, toc(tStart), startDatenum);
                        end
                    end
                end
            end
        end
    else
        pause(0.001);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bank = build_morlet_bank(freqVec, fs, winSamples, cycles)
% Precompute time-domain Morlet wavelets aligned to last sample
t = (-(winSamples-1):0) / fs;
bank = complex(zeros(numel(freqVec), winSamples));
for fi = 1:numel(freqVec)
    f = freqVec(fi);
    s = cycles / (2*pi*f);
    w = exp(2*1i*pi*f*t) .* exp(-(t.^2)/(2*s^2));
    w = w / sqrt(sum(abs(w).^2));
    bank(fi, :) = w;
end
return;

function [amp, phase] = morlet_features(x, bank)
% Compute wavelet coefficient at last sample (dot product)
c = bank * x.';
amp = abs(c).';
phase = angle(c).';
return;

function [fig, ampLine, phaseLine] = init_spectrum_plot(freqVec)
fig = figure('Name', 'Morlet Spectral Amplitude/Phase', 'Color', 'w');
subplot(2,1,1);
ampLine = plot(freqVec, zeros(size(freqVec)), 'LineWidth', 1.2);
grid on;
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Morlet Amplitude');
subplot(2,1,2);
phaseLine = plot(freqVec, zeros(size(freqVec)), 'LineWidth', 1.2);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
title('Morlet Phase');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function init_log_if_needed()
    if isempty(logMf)
        logMf = matfile(logFile, 'Writable', true);
        logMf.meta = struct( ...
            'localPort', localPort, ...
            'windowSec', windowSec, ...
            'freqVec', freqVec, ...
            'waveletCycles', waveletCycles, ...
            'specChannel', specChannel, ...
            'startTime', datestr(startDatenum, 'yyyy-mm-dd HH:MM:SS'), ...
            'startDatenum', startDatenum);
        logMf.samples = zeros(size(dec.sample,1), size(dec.sample,2), 0, 'int32');
        logMf.packet_tsec = zeros(1, 0);
        logMf.packet_datenum = zeros(1, 0);
        logMf.spec_amp = zeros(numel(freqVec), 0, 'single');
        logMf.spec_phase = zeros(numel(freqVec), 0, 'single');
        logMf.spec_tsec = zeros(1, 0);
        logMf.spec_datenum = zeros(1, 0);
    end
end

function log_packet(sampleBlock, tsec, t0dn)
    init_log_if_needed();
    if isempty(logPacketBuf)
        logPacketBuf = zeros(size(sampleBlock,1), size(sampleBlock,2), logFlushEveryPackets, 'int32');
        logPacketT = zeros(1, logFlushEveryPackets);
        logPacketDN = zeros(1, logFlushEveryPackets);
        logPacketBufIdx = 0;
    end
    logPacketBufIdx = logPacketBufIdx + 1;
    logPacketBuf(:,:,logPacketBufIdx) = int32(sampleBlock);
    logPacketT(logPacketBufIdx) = tsec;
    logPacketDN(logPacketBufIdx) = t0dn + tsec/86400;
    if logPacketBufIdx >= logFlushEveryPackets
        flush_packet_log();
    end
end

function log_spec(amp, phase, tsec, t0dn)
    init_log_if_needed();
    if isempty(logSpecAmpBuf)
        logSpecAmpBuf = zeros(numel(freqVec), logFlushEverySpec, 'single');
        logSpecPhaseBuf = zeros(numel(freqVec), logFlushEverySpec, 'single');
        logSpecT = zeros(1, logFlushEverySpec);
        logSpecDN = zeros(1, logFlushEverySpec);
        logSpecBufIdx = 0;
    end
    logSpecBufIdx = logSpecBufIdx + 1;
    logSpecAmpBuf(:, logSpecBufIdx) = single(amp(:));
    logSpecPhaseBuf(:, logSpecBufIdx) = single(phase(:));
    logSpecT(logSpecBufIdx) = tsec;
    logSpecDN(logSpecBufIdx) = t0dn + tsec/86400;
    if logSpecBufIdx >= logFlushEverySpec
        flush_spec_log();
    end
end

function flush_packet_log()
    if isempty(logMf) || logPacketBufIdx == 0
        return;
    end
    startIdx = logPacketIdx + 1;
    endIdx = logPacketIdx + logPacketBufIdx;
    logMf.samples(:,:,startIdx:endIdx) = logPacketBuf(:,:,1:logPacketBufIdx);
    logMf.packet_tsec(1, startIdx:endIdx) = logPacketT(1:logPacketBufIdx);
    logMf.packet_datenum(1, startIdx:endIdx) = logPacketDN(1:logPacketBufIdx);
    logPacketIdx = endIdx;
    logPacketBufIdx = 0;
end

function flush_spec_log()
    if isempty(logMf) || logSpecBufIdx == 0
        return;
    end
    startIdx = logSpecIdx + 1;
    endIdx = logSpecIdx + logSpecBufIdx;
    logMf.spec_amp(:, startIdx:endIdx) = logSpecAmpBuf(:, 1:logSpecBufIdx);
    logMf.spec_phase(:, startIdx:endIdx) = logSpecPhaseBuf(:, 1:logSpecBufIdx);
    logMf.spec_tsec(1, startIdx:endIdx) = logSpecT(1:logSpecBufIdx);
    logMf.spec_datenum(1, startIdx:endIdx) = logSpecDN(1:logSpecBufIdx);
    logSpecIdx = endIdx;
    logSpecBufIdx = 0;
end

function cleanup_all()
    try
        flush_packet_log();
        flush_spec_log();
    catch
    end
    try
        clear u;
    catch
    end
end
