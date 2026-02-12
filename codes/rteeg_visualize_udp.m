close all; clear all;

% rteeg_visualize_udp  Receive, decode, and visualize NeurOne UDP packets
%
% This script listens on a UDP port, decodes packets with rteeg_decode,
% plots Samples packets using rteeg_draw_trace, optionally shows Morlet
% wavelet amplitude/phase for a selected channel, and archives data.

%% Parameters
localPort = 50001;           % UDP port to listen on
defaultFs = 1000;           % fallback sampling rate if no MeasurementStart
verbose = true;
checkTimeoutSec = 3;        % UDP sanity check timeout (seconds)
windowSec = 0.5;            % rolling window length (s) for spectral view
freqVec = 4:1:250;          % Hz (Morlet frequencies)
waveletCycles = 7;          % Morlet cycles
specChannel = 1;            % channel to visualize spectrum
specUpdateEvery = 20;       % update spectrum every N packets
traceUpdateHz = 10;         % max trace redraw rate (UI), packets are still fully ingested
showSpectrum = false;       % keep visualization in a single figure window
logEnabled = false;         % archive incoming data + spectral features
logFile = fullfile(pwd, ['rteeg_visualize_log_' datestr(now,'yyyymmdd_HHMMSS') '.mat']);
logFlushEveryPackets = 200; % flush packet data to disk every N packets
logFlushEverySpec = 50;     % flush spectral data every N spec updates

%% UDP sanity check
hasNativeUdp = (exist('udpport', 'file') == 2) || (exist('udp', 'file') == 2);
if hasNativeUdp
    try
        [ok, info] = rteeg_check_udp_connection('localPort', localPort, 'timeoutSec', checkTimeoutSec, 'verbose', verbose); %#ok<NASGU>
        if ~ok
            warning('No UDP packets received during check; visualizer will still start.');
        end
    catch ME
        warning('UDP check failed: %s', ME.message);
    end
elseif verbose
    fprintf('Skipping UDP pre-check (Java socket fallback mode).\n');
end

%% Init UDP
useUdpPort = (exist('udpport', 'file') == 2);
useLegacyUdp = (exist('udp', 'file') == 2);
jSock = [];
useJavaUdp = false;
SOCK_APPDATA_KEY = 'rteeg_visualize_udp_jSock';

% Best-effort cleanup of a stale Java socket from an interrupted prior run.
if isappdata(0, SOCK_APPDATA_KEY)
    try
        oldSock = getappdata(0, SOCK_APPDATA_KEY);
        if ~isempty(oldSock)
            oldSock.close();
        end
    catch
    end
    try
        rmappdata(0, SOCK_APPDATA_KEY);
    catch
    end
end

if useUdpPort
    u = udpport("datagram", "IPV4", "LocalPort", localPort);
elseif useLegacyUdp
    u = udp('0.0.0.0', 'LocalPort', localPort);
    fopen(u);
else
    useJavaUdp = true;
    u = [];
    bindErr = [];
    for bindTry = 1:2
        try
            jSock = java.net.DatagramSocket(localPort);
            jSock.setSoTimeout(10);
            setappdata(0, SOCK_APPDATA_KEY, jSock);
            bindErr = [];
            break;
        catch ME
            bindErr = ME;
            % Retry once after closing any leaked socket from the same MATLAB session.
            try
                if isappdata(0, SOCK_APPDATA_KEY)
                    oldSock = getappdata(0, SOCK_APPDATA_KEY);
                    if ~isempty(oldSock)
                        oldSock.close();
                    end
                    rmappdata(0, SOCK_APPDATA_KEY);
                end
            catch
            end
            pause(0.05);
        end
    end
    if ~isempty(bindErr)
        rethrow(bindErr);
    end
end

%% Receive + plot loop
fs = defaultFs;
trace_obj = [];
traceFig = figure('Name', 'EEG Trace', 'Color', 'w', 'Visible', 'on');
drawnow;
traceUpdateSec = 1 / max(traceUpdateHz, 1);
traceLastDrawTic = tic;
tracePendingChunks = {};
tracePendingCols = 0;
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
    hasData = false;
    data = [];
    srcIP = 'unknown';
    srcPort = NaN;
    if useUdpPort
        if u.NumDatagramsAvailable > 0
            [data, srcInfo] = read(u, 1, "uint8");
            try
                if istable(srcInfo)
                    if any(strcmp(srcInfo.Properties.VariableNames, 'SourceAddress'))
                        srcIP = char(string(srcInfo.SourceAddress(1)));
                    end
                    if any(strcmp(srcInfo.Properties.VariableNames, 'SourcePort'))
                        srcPort = double(srcInfo.SourcePort(1));
                    end
                end
            catch
            end
            hasData = true;
        end
    elseif useLegacyUdp
        nAvail = get(u, 'BytesAvailable');
        if nAvail > 0
            data = fread(u, nAvail, 'uint8');
            hasData = true;
        end
    else
        try
            rxBuf = int8(zeros(65535, 1));
            pkt = java.net.DatagramPacket(rxBuf, numel(rxBuf));
            jSock.receive(pkt);
            n = pkt.getLength();
            raw = pkt.getData();
            % Preserve raw byte values when converting Java byte[] -> MATLAB uint8.
            data = typecast(raw(1:n), 'uint8');
            try
                srcIP = char(pkt.getAddress().getHostAddress());
                srcPort = double(pkt.getPort());
            catch
            end
            hasData = true;
        catch ME
            msg = '';
            try
                msg = char(ME.message);
            catch
            end
            isTimeout = contains(char(ME.identifier), 'SocketTimeoutException') || ...
                        contains(msg, 'SocketTimeoutException') || ...
                        contains(msg, 'Receive timed out');
            if ~isTimeout
                rethrow(ME);
            end
        end
    end

    if hasData
        dec = rteeg_decode(uint8(data(:).'));
        if ~isempty(dec) && isfield(dec, 'flag_ok') && dec.flag_ok
            if dec.frameType == 1
                if isfield(dec, 'samplingRateHz')
                    fs = double(dec.samplingRateHz);
                    if verbose
                        if isnan(srcPort)
                            fprintf('MeasurementStart from %s: samplingRateHz=%g\n', srcIP, fs);
                        else
                            fprintf('MeasurementStart from %s:%d samplingRateHz=%g\n', srcIP, srcPort, fs);
                        end
                    end
                end
            elseif dec.frameType == 2
                sampleBlock = double(dec.sample);
                if isempty(tracePendingChunks)
                    tracePendingChunks = {sampleBlock};
                    tracePendingCols = size(sampleBlock, 2);
                else
                    firstRows = size(tracePendingChunks{1}, 1);
                    if firstRows == size(sampleBlock,1)
                        tracePendingChunks{end+1} = sampleBlock; %#ok<AGROW>
                        tracePendingCols = tracePendingCols + size(sampleBlock, 2);
                    else
                        tracePendingChunks = {sampleBlock};
                        tracePendingCols = size(sampleBlock, 2);
                    end
                end

                packetCount = packetCount + 1;

                if toc(traceLastDrawTic) >= traceUpdateSec && ~isempty(tracePendingChunks)
                    if numel(tracePendingChunks) == 1
                        traceDraw = tracePendingChunks{1};
                    else
                        nRows = size(tracePendingChunks{1},1);
                        traceDraw = zeros(nRows, tracePendingCols);
                        c0 = 1;
                        for ci = 1:numel(tracePendingChunks)
                            cc = size(tracePendingChunks{ci},2);
                            traceDraw(:, c0:c0+cc-1) = tracePendingChunks{ci};
                            c0 = c0 + cc;
                        end
                    end
                    trace_obj = rteeg_draw_trace(traceDraw, fs, 'trace_obj', trace_obj, 'fig', traceFig);
                    tracePendingChunks = {};
                    tracePendingCols = 0;
                    traceLastDrawTic = tic;
                    drawnow limitrate;
                end

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
                        if isempty(ampLine) || isempty(phaseLine) || ...
                                ~isgraphics(ampLine) || ~isgraphics(phaseLine)
                            [specFig, ampLine, phaseLine] = init_spectrum_plot(freqVec); %#ok<NASGU>
                        end
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
end

function [amp, phase] = morlet_features(x, bank)
% Compute wavelet coefficient at last sample (dot product)
c = bank * x.';
amp = abs(c).';
phase = angle(c).';
return;
end

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
end

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
        if useJavaUdp
            if ~isempty(jSock)
                jSock.close();
            end
            if isappdata(0, SOCK_APPDATA_KEY)
                rmappdata(0, SOCK_APPDATA_KEY);
            end
        elseif useUdpPort
            clear u;
        else
            if strcmpi(get(u, 'Status'), 'open')
                fclose(u);
            end
            delete(u);
        end
    catch
    end
end
