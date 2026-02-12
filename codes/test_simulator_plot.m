close all; clear all;

% Ensure local toolbox functions in this folder are used first.
this_dir = fileparts(mfilename('fullpath'));
if ~isempty(this_dir)
    addpath(this_dir, '-begin');
end

% Generate synthetic packets and decode them through rteeg_decode
[packets, meta] = rteeg_simulator( ...
    'numChannels', 10, ...
    'samplingRateHz', 1000, ...
    'numSampleBundles', 20, ...
    'numPackets', 200, ...
    'includeTriggers', true, ...
    'triggerEveryPackets', 25);

trace_obj = [];
for idx = 1:numel(packets)
    dec = rteeg_decode(packets{idx});
    if isempty(dec)
        continue;
    end
    if isfield(dec, 'flag_ok') && dec.flag_ok && dec.frameType == 2
        trace_obj = rteeg_draw_trace(double(dec.sample), meta.samplingRateHz, 'trace_obj', trace_obj);
        pause(0.01);
    end
end

