%% Speedgoat EEG Real-Time UDP System
% System for receiving EEG data from Bittium NeurOne via UDP
% and performing real-time spectral analysis

%% System Parameters
EEG_CHANNELS = 20;
SAMPLING_RATE = 1000; % Hz
UDP_RATE = 100; % Hz
BUFFER_TIME = 0.5; % seconds
BUFFER_SIZE = BUFFER_TIME * SAMPLING_RATE; % 500 samples
TARGET_IP = '192.168.200.240';
SOURCE_IP = '192.168.200.220';
SOURCE_PORT = 5000;
UDP_PORT = 8080; % Port for receiving on target

%% Create Simulink Model
modelName = 'SpeedgoatEEGSystem';
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
new_system(modelName);
open_system(modelName);

%% Add UDP Receive Block
udp_block = add_block('slrealtime/UDP Receive', [modelName '/UDP_Receive']);
set_param(udp_block, 'LocalIPPort', num2str(UDP_PORT));
set_param(udp_block, 'MaximumMessageLength', '1600'); % 20 channels * 8 bytes * 10 samples
set_param(udp_block, 'ReceiveBufferSize', '32768');
set_param(udp_block, 'SampleTime', num2str(1/UDP_RATE));

%% Add Data Type Conversion and Reshape
% Convert received bytes to double
dtconv_block = add_block('simulink/Signal Attributes/Data Type Conversion', ...
    [modelName '/DataTypeConversion']);
set_param(dtconv_block, 'OutDataTypeStr', 'double');

% Reshape to separate channels
reshape_block = add_block('simulink/Math Operations/Reshape', [modelName '/Reshape']);
set_param(reshape_block, 'OutputDimensionality', 'Column vector (2-D)');
set_param(reshape_block, 'OutputDimensions', ['[' num2str(EEG_CHANNELS) ', -1]']);

%% Add Buffer Block for Each Channel
buffer_subsystem = add_block('simulink/Ports & Subsystems/Subsystem', ...
    [modelName '/EEG_Buffer_System']);

% Create buffer subsystem
Simulink.SubSystem.deleteContents(buffer_subsystem);
add_block('simulink/Sources/In1', [buffer_subsystem '/In1']);
add_block('simulink/Sinks/Out1', [buffer_subsystem '/Out1']);

% Add buffer blocks for each channel
for ch = 1:EEG_CHANNELS
    % Channel selector
    selector_block = add_block('simulink/Signal Routing/Selector', ...
        [buffer_subsystem sprintf('/Ch%d_Selector', ch)]);
    set_param(selector_block, 'IndexMode', 'One-based');
    set_param(selector_block, 'Indices', num2str(ch));
    set_param(selector_block, 'InputPortWidth', num2str(EEG_CHANNELS));
    
    % Buffer
    buffer_block = add_block('dsp/Buffers/Buffer', ...
        [buffer_subsystem sprintf('/Ch%d_Buffer', ch)]);
    set_param(buffer_block, 'N', num2str(BUFFER_SIZE));
    set_param(buffer_block, 'ic', '0');
    set_param(buffer_block, 'Ts', num2str(1/SAMPLING_RATE));
    
    % Connect selector to buffer
    add_line(buffer_subsystem, sprintf('Ch%d_Selector/1', ch), sprintf('Ch%d_Buffer/1', ch));
end

% Multiplex all buffered channels
mux_block = add_block('simulink/Signal Routing/Mux', [buffer_subsystem '/BufferMux']);
set_param(mux_block, 'Inputs', num2str(EEG_CHANNELS));

% Connect buffers to mux
for ch = 1:EEG_CHANNELS
    add_line(buffer_subsystem, sprintf('Ch%d_Buffer/1', ch), sprintf('BufferMux/%d', ch));
end

% Connect input to all selectors
for ch = 1:EEG_CHANNELS
    add_line(buffer_subsystem, 'In1/1', sprintf('Ch%d_Selector/1', ch));
end

% Connect mux to output
add_line(buffer_subsystem, 'BufferMux/1', 'Out1/1');

%% Add Spectral Analysis Subsystem
spectrum_subsystem = add_block('simulink/Ports & Subsystems/Subsystem', ...
    [modelName '/Spectrum_Analysis']);

Simulink.SubSystem.deleteContents(spectrum_subsystem);
add_block('simulink/Sources/In1', [spectrum_subsystem '/In1']);
add_block('simulink/Sinks/Out1', [spectrum_subsystem '/Out1']);

% Add FFT and power spectrum calculation for each channel
for ch = 1:EEG_CHANNELS
    % Channel selector for buffered data
    selector_block = add_block('simulink/Signal Routing/Selector', ...
        [spectrum_subsystem sprintf('/Spectrum_Ch%d_Selector', ch)]);
    set_param(selector_block, 'IndexMode', 'One-based');
    set_param(selector_block, 'Indices', sprintf('%d:%d:%d', ch, EEG_CHANNELS, EEG_CHANNELS*BUFFER_SIZE));
    set_param(selector_block, 'InputPortWidth', num2str(EEG_CHANNELS*BUFFER_SIZE));
    
    % Window function (Hamming)
    window_block = add_block('dsp/Transforms/Window Function', ...
        [spectrum_subsystem sprintf('/Ch%d_Window', ch)]);
    set_param(window_block, 'Window', 'Hamming');
    
    % FFT
    fft_block = add_block('dsp/Transforms/FFT', ...
        [spectrum_subsystem sprintf('/Ch%d_FFT', ch)]);
    set_param(fft_block, 'BitRevOrder', 'off');
    
    % Magnitude squared (Power)
    magsq_block = add_block('dsp/Math Functions/Magnitude-Angle to Complex', ...
        [spectrum_subsystem sprintf('/Ch%d_MagSq', ch)]);
    set_param(magsq_block, 'Output', 'Magnitude squared');
    
    % Connect channel processing chain
    add_line(spectrum_subsystem, 'In1/1', sprintf('Spectrum_Ch%d_Selector/1', ch));
    add_line(spectrum_subsystem, sprintf('Spectrum_Ch%d_Selector/1', ch), sprintf('Ch%d_Window/1', ch));
    add_line(spectrum_subsystem, sprintf('Ch%d_Window/1', ch), sprintf('Ch%d_FFT/1', ch));
    add_line(spectrum_subsystem, sprintf('Ch%d_FFT/1', ch), sprintf('Ch%d_MagSq/1', ch));
end

% Multiplex all spectra
spectrum_mux_block = add_block('simulink/Signal Routing/Mux', [spectrum_subsystem '/SpectrumMux']);
set_param(spectrum_mux_block, 'Inputs', num2str(EEG_CHANNELS));

% Connect power spectra to mux
for ch = 1:EEG_CHANNELS
    add_line(spectrum_subsystem, sprintf('Ch%d_MagSq/1', ch), sprintf('SpectrumMux/%d', ch));
end

% Connect mux to output
add_line(spectrum_subsystem, 'SpectrumMux/1', 'Out1/1');

%% Add Scope for UDP Data Monitoring
scope_block = add_block('simulink/Commonly Used Blocks/Scope', [modelName '/UDP_Monitor_Scope']);
set_param(scope_block, 'NumInputPorts', '1');
set_param(scope_block, 'TimeRange', '10');
set_param(scope_block, 'YMin', '-500');
set_param(scope_block, 'YMax', '500');
set_param(scope_block, 'DataLogging', 'on');

%% Add Spectrum Display Scope
spectrum_scope_block = add_block('simulink/Commonly Used Blocks/Scope', [modelName '/Spectrum_Scope']);
set_param(spectrum_scope_block, 'NumInputPorts', '1');
set_param(spectrum_scope_block, 'TimeRange', '2');
set_param(spectrum_scope_block, 'YMin', '0');
set_param(spectrum_scope_block, 'YMax', '1000');

%% Connect All Blocks
% UDP to Data Type Conversion
add_line(modelName, 'UDP_Receive/1', 'DataTypeConversion/1');

% Data Type Conversion to Reshape
add_line(modelName, 'DataTypeConversion/1', 'Reshape/1');

% Reshape to Buffer System
add_line(modelName, 'Reshape/1', 'EEG_Buffer_System/1');

% Buffer System to Spectrum Analysis
add_line(modelName, 'EEG_Buffer_System/1', 'Spectrum_Analysis/1');

% Reshape to UDP Monitor Scope
add_line(modelName, 'Reshape/1', 'UDP_Monitor_Scope/1');

% Spectrum Analysis to Spectrum Scope
add_line(modelName, 'Spectrum_Analysis/1', 'Spectrum_Scope/1');

%% Configure Model for Speedgoat
set_param(modelName, 'Solver', 'FixedStepDiscrete');
set_param(modelName, 'FixedStep', num2str(1/UDP_RATE));
set_param(modelName, 'StopTime', 'inf');

% Set target configuration
set_param(modelName, 'SystemTargetFile', 'slrealtime.tlc');
set_param(modelName, 'TemplateMakefile', 'slrealtime_default_tmf');

%% Create Target Object and Configure
tg = slrealtime('TargetPC1');

% Connect to target
try
    connect(tg);
    fprintf('Connected to Speedgoat target: %s\n', tg.TargetSettings.name);
catch ME
    warning('Could not connect to target: %s', ME.message);
end

%% Build and Load Model
fprintf('Building model for Speedgoat...\n');
try
    slbuild(modelName);
    fprintf('Model built successfully.\n');
    
    % Load to target if connected
    if strcmp(tg.Status, 'connected')
        load(tg, modelName);
        fprintf('Model loaded to target.\n');
    end
catch ME
    warning('Build failed: %s', ME.message);
end

%% Helper Functions for Runtime Control

function startEEGAcquisition(targetObj, modelName)
    % Start the real-time application
    if strcmp(targetObj.Status, 'connected')
        start(targetObj);
        fprintf('EEG acquisition started on %s\n', targetObj.TargetSettings.name);
    else
        warning('Target not connected');
    end
end

function stopEEGAcquisition(targetObj)
    % Stop the real-time application
    if strcmp(targetObj.Status, 'connected')
        stop(targetObj);
        fprintf('EEG acquisition stopped\n');
    end
end

function data = getRealtimeData(targetObj, signalName)
    % Get real-time signal data
    if strcmp(targetObj.Status, 'connected')
        data = getsignal(targetObj, signalName);
    else
        data = [];
        warning('Target not connected');
    end
end

%% Network Configuration Instructions
fprintf('\n=== NETWORK CONFIGURATION INSTRUCTIONS ===\n');
fprintf('1. Configure Speedgoat target IP: %s\n', TARGET_IP);
fprintf('2. Ensure Bittium NeurOne is configured to send to: %s:%d\n', TARGET_IP, UDP_PORT);
fprintf('3. Data format expected: 20 channels × double precision (8 bytes)\n');
fprintf('4. UDP packet rate: %d Hz\n', UDP_RATE);
fprintf('5. Buffer duration: %.1f seconds\n', BUFFER_TIME);
fprintf('\n=== USAGE ===\n');
fprintf('1. Run this script to create and build the model\n');
fprintf('2. Use startEEGAcquisition(tg, ''%s'') to start\n', modelName);
fprintf('3. Use stopEEGAcquisition(tg) to stop\n');
fprintf('4. Monitor data using the scopes in the model\n');

%% Save Model
save_system(modelName);
fprintf('\nModel saved as: %s.slx\n', modelName);