function [packets, meta] = rteeg_simulator(varargin)
% rteeg_simulator  Generate synthetic NeurOne UDP packets for testing
%
% [packets, meta] = rteeg_simulator('name', value, ...)
%
% Output:
%   packets : cell array of uint8 row vectors (each is a packet)
%   meta    : struct with generation parameters and samples
%
% Example:
%   [packets, meta] = rteeg_simulator('numChannels', 16, 'numPackets', 50);
%

% defaults
params.numChannels = 8;
params.samplingRateHz = 1000;
params.numSampleBundles = 10;
params.numPackets = 100;
params.mainUnitNum = uint8(0);
params.sampleFormat = uint32(hex2dec('80000018'));
params.triggerDefs = uint32(0);
params.sourceChannels = [];
params.channelTypes = [];
params.includeMeasurementStart = true;
params.includeMeasurementEnd = true;
params.includeHardwareState = false;
params.includeTriggers = false;
params.triggerEveryPackets = 10;
params.triggerType = uint8(3*16 + 4); % source id=3 (parallel), mode=4 (parallel)
params.triggerCode = uint8(1);
params.amplitude = 2;
params.noiseStd = 0;
params.uvPerCount = 0.01; % simulator quantization: 0.01 uV per ADC count
params.freqHz = [6];
params.phaseRad = [0];
params.seed = [];
params.sendUdp = false;
params.udpIP = '127.0.0.1';
params.udpPort = 50000;
params.realtime = false;

% parse name/value pairs
if mod(numel(varargin), 2) ~= 0
    error('rteeg_simulator expects name/value pairs.');
end
for k = 1:2:numel(varargin)
    key = lower(varargin{k});
    val = varargin{k+1};
    switch key
        case 'numchannels'
            params.numChannels = val;
        case 'samplingratehz'
            params.samplingRateHz = val;
        case 'numsamplebundles'
            params.numSampleBundles = val;
        case 'numpackets'
            params.numPackets = val;
        case 'mainunitnum'
            params.mainUnitNum = uint8(val);
        case 'sampleformat'
            params.sampleFormat = uint32(val);
        case 'triggerdefs'
            params.triggerDefs = uint32(val);
        case 'sourcechannels'
            params.sourceChannels = val;
        case 'channeltypes'
            params.channelTypes = val;
        case 'includemeasurementstart'
            params.includeMeasurementStart = logical(val);
        case 'includemeasurementend'
            params.includeMeasurementEnd = logical(val);
        case 'includehardwarestate'
            params.includeHardwareState = logical(val);
        case 'includetriggers'
            params.includeTriggers = logical(val);
        case 'triggereverypackets'
            params.triggerEveryPackets = val;
        case 'triggertype'
            params.triggerType = uint8(val);
        case 'triggercode'
            params.triggerCode = uint8(val);
        case 'amplitude'
            params.amplitude = val;
        case 'noisestd'
            params.noiseStd = val;
        case 'uvpercount'
            params.uvPerCount = val;
        case 'freqhz'
            params.freqHz = val;
        case 'phaserad'
            params.phaseRad = val;
        case 'seed'
            params.seed = val;
        case 'sendudp'
            params.sendUdp = logical(val);
        case 'udpip'
            params.udpIP = val;
        case 'udpport'
            params.udpPort = val;
        case 'realtime'
            params.realtime = logical(val);
        otherwise
            error('Unknown parameter: %s', varargin{k});
    end
end

if ~isempty(params.seed)
    rng(params.seed);
end

if isempty(params.sourceChannels)
    params.sourceChannels = uint16(1:params.numChannels);
end
if isempty(params.channelTypes)
    params.channelTypes = zeros(1, params.numChannels, 'uint8');
end

if isempty(params.freqHz)
    params.freqHz = linspace(6, 20, params.numChannels);
end
if numel(params.freqHz) == 1
    params.freqHz = params.freqHz .* ones(1, params.numChannels);
end

if isempty(params.phaseRad)
    params.phaseRad = 2*pi*rand(1, params.numChannels);
end
if numel(params.phaseRad) == 1
    params.phaseRad = params.phaseRad .* ones(1, params.numChannels);
end
if ~isscalar(params.uvPerCount) || params.uvPerCount <= 0
    error('uvPerCount must be a positive scalar.');
end

packets = {};
if params.includeMeasurementStart
    packets{end+1} = build_measurement_start(params);
end
if params.includeHardwareState
    packets{end+1} = build_hardware_state(params);
end

numTotalBundles = params.numPackets * params.numSampleBundles;
allSamples = zeros(params.numChannels, numTotalBundles, 'int32');

firstSampleIndex = uint64(0);
packetSeqNo = uint32(0);

for p = 1:params.numPackets
    t = (double(firstSampleIndex) + (0:params.numSampleBundles-1)) ./ params.samplingRateHz;
    data = zeros(params.numChannels, params.numSampleBundles);
    for ch = 1:params.numChannels
        data(ch, :) = params.amplitude .* sin(2*pi*params.freqHz(ch).*t + params.phaseRad(ch)) + ...
                      params.noiseStd .* randn(1, params.numSampleBundles);
    end
    dataInt = int32(round(data ./ params.uvPerCount));
    dataInt = max(min(dataInt, 2^23-1), -2^23);

    idx0 = (p-1)*params.numSampleBundles + 1;
    idx1 = p*params.numSampleBundles;
    allSamples(:, idx0:idx1) = dataInt;

    firstSampleTime = uint64(round(double(firstSampleIndex) * 1e6 / params.samplingRateHz));
    packets{end+1} = build_samples(params, dataInt, packetSeqNo, firstSampleIndex, firstSampleTime);

    if params.includeTriggers && mod(p, params.triggerEveryPackets) == 0
        trigSampleIndex = firstSampleIndex + uint64(floor(params.numSampleBundles/2));
        trigMicroTime = uint64(round(double(trigSampleIndex) * 1e6 / params.samplingRateHz));
        packets{end+1} = build_triggers(params, trigMicroTime, trigSampleIndex);
    end

    firstSampleIndex = firstSampleIndex + uint64(params.numSampleBundles);
    packetSeqNo = packetSeqNo + 1;
end

if params.includeMeasurementEnd
    packets{end+1} = build_measurement_end(params, firstSampleIndex);
end

meta = params;
meta.totalSampleBundles = numTotalBundles;
meta.samples = allSamples;
meta.packetCount = numel(packets);

if params.sendUdp
    send_udp_packets(packets, params);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bytes = build_measurement_start(p)
bytes = uint8([]);
bytes = [bytes, pack_uint8(uint8(1))]; % FrameType
bytes = [bytes, pack_uint8(uint8(p.mainUnitNum))];
bytes = [bytes, pack_uint16(uint16(0))]; % Reserved
bytes = [bytes, pack_uint32(uint32(p.samplingRateHz))];
bytes = [bytes, pack_uint32(uint32(p.sampleFormat))];
bytes = [bytes, pack_uint32(uint32(p.triggerDefs))];
bytes = [bytes, pack_uint16(uint16(p.numChannels))];
bytes = [bytes, pack_uint16(uint16(p.sourceChannels))];
bytes = [bytes, pack_uint8(uint8(p.channelTypes))];
return;

function bytes = build_samples(p, dataInt, packetSeqNo, firstSampleIndex, firstSampleTime)
bytes = uint8([]);
bytes = [bytes, pack_uint8(uint8(2))]; % FrameType
bytes = [bytes, pack_uint8(uint8(p.mainUnitNum))];
bytes = [bytes, pack_uint16(uint16(0))]; % Reserved
bytes = [bytes, pack_uint32(uint32(packetSeqNo))];
bytes = [bytes, pack_uint16(uint16(p.numChannels))];
bytes = [bytes, pack_uint16(uint16(p.numSampleBundles))];
bytes = [bytes, pack_uint64(uint64(firstSampleIndex))];
bytes = [bytes, pack_uint64(uint64(firstSampleTime))];
bytes = [bytes, pack_int24(dataInt)];
return;

function bytes = build_triggers(p, microTime, sampleIndex)
bytes = uint8([]);
bytes = [bytes, pack_uint8(uint8(3))]; % FrameType
bytes = [bytes, pack_uint8(uint8(p.mainUnitNum))];
bytes = [bytes, pack_uint16(uint16(1))]; % NumTriggers
bytes = [bytes, pack_uint32(uint32(0))]; % Reserved
bytes = [bytes, pack_uint64(uint64(microTime))];
bytes = [bytes, pack_uint64(uint64(sampleIndex))];
bytes = [bytes, pack_uint8(uint8(p.triggerType))];
bytes = [bytes, pack_uint8(uint8(p.triggerCode))];
bytes = [bytes, pack_uint16(uint16(0))]; % Reserved
return;

function bytes = build_measurement_end(p, finalSampleCount)
bytes = uint8([]);
bytes = [bytes, pack_uint8(uint8(4))]; % FrameType
bytes = [bytes, pack_uint8(uint8(p.mainUnitNum))];
bytes = [bytes, pack_uint16(uint16(0))]; % Reserved
bytes = [bytes, pack_uint64(uint64(finalSampleCount))];
return;

function bytes = build_hardware_state(p)
bytes = uint8([]);
bytes = [bytes, pack_uint8(uint8(5))]; % FrameType
bytes = [bytes, pack_uint8(uint8(p.mainUnitNum))];
bytes = [bytes, pack_uint8(uint8(1))]; % StateType = ClockSourceState
bytes = [bytes, pack_uint8(uint8(0))]; % Reserved
bytes = [bytes, pack_uint64(uint64(0))]; % MicroTime
bytes = [bytes, pack_uint32(uint32(0))]; % ClockFreq
bytes = [bytes, pack_uint32(uint32(0))]; % TargetClockFreq
bytes = [bytes, pack_uint16(uint16(1))]; % ClockSrc (SyncBox internal)
return;

function bytes = pack_uint8(val)
bytes = reshape(uint8(val), 1, []);
return;

function bytes = pack_uint16(val)
bytes = reshape(typecast(swapbytes(uint16(val(:))), 'uint8'), 1, []);
return;

function bytes = pack_uint32(val)
bytes = reshape(typecast(swapbytes(uint32(val(:))), 'uint8'), 1, []);
return;

function bytes = pack_uint64(val)
bytes = reshape(typecast(swapbytes(uint64(val(:))), 'uint8'), 1, []);
return;

function bytes = pack_int24(samples)
vals = int32(samples(:));
vals = max(min(vals, 2^23-1), -2^23);
% Preserve two's-complement bit pattern for negative values.
uvals = typecast(vals, 'uint32');
uvals = bitand(uvals, uint32(2^24-1));
msb = uint8(bitand(bitshift(uvals, -16), uint32(255)));
mid = uint8(bitand(bitshift(uvals, -8), uint32(255)));
lsb = uint8(bitand(uvals, uint32(255)));
bytes = reshape([msb.'; mid.'; lsb.'], 1, []);
return;

function send_udp_packets(packets, p)
useUdpPort = (exist('udpport', 'file') == 2);
useLegacyUdp = (exist('udp', 'file') == 2);
jSock = [];
useJavaUdp = false;

if useUdpPort
    u = udpport("datagram", "IPV4");
elseif useLegacyUdp
    u = udp(p.udpIP, p.udpPort);
    fopen(u);
else
    useJavaUdp = true;
    u = [];
    jSock = java.net.DatagramSocket();
    jAddr = java.net.InetAddress.getByName(p.udpIP);
end

packetIntervalSec = p.numSampleBundles / p.samplingRateHz;
rtTic = [];
samplePacketsSent = 0;
if p.realtime
    rtTic = tic;
end
for i = 1:numel(packets)
    if useUdpPort
        write(u, packets{i}, "uint8", p.udpIP, p.udpPort);
    elseif useLegacyUdp
        fwrite(u, packets{i}, 'uint8');
    else
        % Preserve raw byte values when converting MATLAB uint8 -> Java byte[].
        tx = typecast(uint8(packets{i}), 'int8');
        pkt = java.net.DatagramPacket(tx, numel(tx), jAddr, p.udpPort);
        jSock.send(pkt);
    end
    if p.realtime
        isSamplePacket = ~isempty(packets{i}) && packets{i}(1) == uint8(2);
        if isSamplePacket
            samplePacketsSent = samplePacketsSent + 1;
            targetSec = samplePacketsSent * packetIntervalSec;
            remainSec = targetSec - toc(rtTic);
            if remainSec > 0
                % Coarse sleep first, then short spin-wait for sub-ms accuracy.
                if remainSec > 0.002
                    pause(remainSec - 0.001);
                end
                while toc(rtTic) < targetSec
                end
            end
        end
    end
end
if useJavaUdp
    jSock.close();
elseif useUdpPort
    clear u;
else
    fclose(u);
    delete(u);
end
return;

