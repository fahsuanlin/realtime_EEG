# Real‑Time EEG Tools (Recorder, Player, Decoder, Visualizer)

This repo includes small MATLAB utilities for capturing, replaying, decoding, and visualizing NeurOne UDP packets.

## Recorder (UDP capture)
**Script:** `codes/rteeg_record_udp.m`

Records raw UDP datagrams into a `.mat` file so you can replay later.

1) Open `codes/rteeg_record_udp.m` and set:
   - `localPort` (UDP port to listen on, e.g., `50000`)
   - `durationSec` and/or `maxPackets`
   - `outfile` (default is timestamped in the current folder)
2) Run the script:
   ```matlab
   rteeg_record_udp
   ```
3) Press `Ctrl+C` to stop early. The data is still saved.

Saved variables:
- `packets`: cell array of raw `uint8` UDP datagrams
- `packet_tsec`: timestamp (sec) from start of recording
- `packet_len`, `packet_src_ip`, `packet_src_port`
- `meta`: recording settings

## Player (UDP replay)
**Script:** `codes/rteeg_playback_udp.m`

Replays a recorded `.mat` file to a UDP destination. It loops forever until you break it.

1) Open `codes/rteeg_playback_udp.m` and set:
   - `infile` (or leave empty to pick via file dialog)
   - `destIP`, `destPort`
   - `preserveTiming`, `speedFactor`
2) Run the script:
   ```matlab
   rteeg_playback_udp
   ```

Behavior:
- Sends a Trigger packet at playback start.
- Sends another Trigger packet **3 seconds before the end** of the file (timing scaled if `speedFactor` is used).
- Loops until `Ctrl+C`.

## Decoder (packet parser)
**Function:** `codes/rteeg_decode.m`

Decodes one raw packet at a time:

```matlab
dec = rteeg_decode(packets{idx});
if dec.flag_ok && dec.frameType == 2
    % dec.sample is [numChannels x numSampleBundles]
end
```

`frameType` values:
- 1: MeasurementStart
- 2: Samples
- 3: Triggers
- 4: MeasurementEnd
- 5: HardwareState

## Visualizer (trace plot)
**Function:** `codes/rteeg_draw_trace.m`

Call it with sample matrices (channels × samples). It keeps an internal buffer and scrolls:

```matlab
trace_obj = [];
trace_obj = rteeg_draw_trace(double(dec.sample), fs, 'trace_obj', trace_obj);
```

Example driver (simulated data):
- `codes/test_simulator_plot.m`

## Visualizer (UDP receive + decode + plot)
**Script:** `codes/rteeg_visualize_udp.m`

Receives UDP packets, decodes them, and plots Samples packets in real time.

```matlab
rteeg_visualize_udp
```

Before starting, it runs a UDP sanity check via `rteeg_check_udp_connection`.

## UDP sanity check
**Function:** `codes/rteeg_check_udp_connection.m`

Quickly verifies incoming UDP packets are visible on a given port:

```matlab
[ok, info] = rteeg_check_udp_connection('localPort', 50000, 'timeoutSec', 3);
```

## Do I need two MATLAB instances to play and decode/plot at the same time?
**Practically, yes** with the current scripts:
- `rteeg_playback_udp.m` is a blocking, infinite loop.
- A receiver/decoder/visualizer also needs its own loop to read UDP and update plots.

**Simplest setup:** run two MATLAB instances:
1) Instance A: `rteeg_playback_udp` (sender)
2) Instance B: your UDP receiver + `rteeg_decode` + `rteeg_draw_trace`

It’s possible to do both in one MATLAB session by writing a combined script that:
- Creates one `udpport` for send and another for receive, and
- Uses a timer or `while` loop that interleaves send/receive/plotting.

If you want, I can add a combined “player + receiver + plot” example in one script.

## Speedgoat setup (scripted)
**Model generator:** `codes/build_slrt_eeg_model.m`

This script builds a Speedgoat/Simulink model that:
- Receives NeurOne UDP packets
- Maintains a 0.5 s rolling buffer per channel
- Computes Morlet wavelet amplitude + phase (4–250 Hz, 1 Hz step, 7 cycles)
- Outputs `Amp_Out`, `Phase_Out`, and `Freq_Out`

1) Edit the parameters at the top of `codes/build_slrt_eeg_model.m`:
   - `numChannels = 40`
   - `samplingRateHz = 1000`
   - `numSampleBundles = 1` (delivery rate = 1000 Hz)
   - `localIP`, `localPort`, `fromIP`
2) Build + deploy:
   ```matlab
   build_slrt_eeg_model
   slbuild('slrt_eeg_rt')
   tg = slrealtime('TargetPC1');
   connect(tg);
   load(tg, 'slrt_eeg_rt');
   start(tg);
   ```

## Example: Real NeurOne -> Speedgoat + PC monitor
**Goal:** NeurOne sends UDP to Speedgoat for real‑time processing while this PC monitors the same stream.

Example network (replace with your actual IPs):
- NeurOne Digital Out: `192.168.200.220`
- Speedgoat: `192.168.200.240`
- PC: `192.168.200.10`
- Subnet: `255.255.255.0`

Steps:
1) On NeurOne, set Digital Out destination to **broadcast** (e.g., `192.168.200.255`) and port `50000`.
   - This allows **both** Speedgoat and PC to receive the same packets.
2) On Speedgoat, build/start the model with `localIP=192.168.200.240`, `localPort=50000`.
3) On the PC, run:
   ```matlab
   rteeg_visualize_udp
   ```
   This decodes and plots traces + wavelet amplitude/phase, and archives to a timestamped `.mat`.

Notes:
- If you must use unicast only, you can set NeurOne to send to Speedgoat and then re‑stream from Speedgoat or use a managed switch with port mirroring to feed the PC.

## Example: Simulated NeurOne -> Speedgoat + PC monitor
**Goal:** Send simulated packets to Speedgoat and monitor on this PC at the same time.

Option A (replay a recorded `.mat` file):
1) In `codes/rteeg_playback_udp.m`, set:
   - `destIP = '192.168.200.255'` (broadcast)
   - `destPort = 50000`
2) Run playback in one MATLAB instance:
   ```matlab
   rteeg_playback_udp
   ```
3) In another MATLAB instance on the PC, run:
   ```matlab
   rteeg_visualize_udp
   ```
4) Start Speedgoat model (as above).

Option B (live simulator):
```matlab
rteeg_simulator('sendUdp', true, 'udpIP', '192.168.200.255', 'udpPort', 50000, 'realtime', true);
```

Tips:
- Use broadcast so Speedgoat and the PC can receive the same packets.
- Two MATLAB instances are recommended because the sender loops indefinitely.
