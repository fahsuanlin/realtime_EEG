function [ok, info, firstPacket] = rteeg_check_udp_connection(varargin)
% rteeg_check_udp_connection  Quick UDP receive sanity check
%
% [ok, info, firstPacket] = rteeg_check_udp_connection('name', value, ...)
%
% Parameters:
%   localPort  : UDP port to listen on (default 50000)
%   timeoutSec : how long to wait for a packet (default 3)
%   verbose    : print status messages (default true)
%
% Output:
%   ok          : true if a packet was received
%   info        : struct with source info and timing
%   firstPacket : first received datagram (uint8 row vector)

params.localPort = 50000;
params.timeoutSec = 3;
params.verbose = true;

if mod(numel(varargin), 2) ~= 0
    error('rteeg_check_udp_connection expects name/value pairs.');
end
for k = 1:2:numel(varargin)
    key = lower(varargin{k});
    val = varargin{k+1};
    switch key
        case 'localport'
            params.localPort = val;
        case 'timeoutsec'
            params.timeoutSec = val;
        case 'verbose'
            params.verbose = logical(val);
        otherwise
            error('Unknown parameter: %s', varargin{k});
    end
end

ok = false;
info = struct();
firstPacket = uint8([]);
u = [];
useUdpPort = (exist('udpport', 'file') == 2);
useLegacyUdp = (exist('udp', 'file') == 2);
jSock = [];
useJavaUdp = false;
if useUdpPort
    u = udpport("datagram", "IPV4", "LocalPort", params.localPort);
elseif useLegacyUdp
    u = udp('0.0.0.0', 'LocalPort', params.localPort);
    fopen(u);
else
    useJavaUdp = true;
    jSock = java.net.DatagramSocket(params.localPort);
    jSock.setSoTimeout(10);
end
cleanupObj = onCleanup(@() local_cleanup_udp(u, jSock, useUdpPort, useLegacyUdp, useJavaUdp)); %#ok<NASGU>

if params.verbose
    fprintf('Checking UDP on port %d (timeout %.1f s)...\n', params.localPort, params.timeoutSec);
end

tStart = tic;
while toc(tStart) < params.timeoutSec
    if useUdpPort
        if u.NumDatagramsAvailable > 0
            [data, src] = read(u, 1, "uint8");
            ok = true;
            firstPacket = uint8(data(:).');
            info.srcIP = src.Address;
            info.srcPort = src.Port;
            info.len = numel(data);
            info.tsec = toc(tStart);
            break;
        end
    elseif useLegacyUdp
        nAvail = get(u, 'BytesAvailable');
        if nAvail > 0
            data = fread(u, nAvail, 'uint8');
            ok = true;
            firstPacket = uint8(data(:).');
            info.srcIP = '';
            info.srcPort = NaN;
            info.len = numel(data);
            info.tsec = toc(tStart);
            break;
        end
    else
        try
            rxBuf = int8(zeros(65535, 1));
            pkt = java.net.DatagramPacket(rxBuf, numel(rxBuf));
            jSock.receive(pkt);
            n = pkt.getLength();
            raw = pkt.getData();
            % Preserve raw byte values when converting Java byte[] -> MATLAB uint8.
            data = typecast(raw(1:n), 'uint8').';
            ok = true;
            firstPacket = data;
            info.srcIP = char(pkt.getAddress().getHostAddress());
            info.srcPort = double(pkt.getPort());
            info.len = n;
            info.tsec = toc(tStart);
            break;
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
    pause(0.01);
end

if params.verbose
    if ok
        fprintf('UDP OK: received %d bytes from %s:%d after %.3f s\n', ...
            info.len, info.srcIP, info.srcPort, info.tsec);
    else
        fprintf('UDP check: no packets received within %.1f s\n', params.timeoutSec);
    end
end

return;

function local_cleanup_udp(u, jSock, useUdpPort, useLegacyUdp, useJavaUdp)
if useJavaUdp
    try
        if ~isempty(jSock)
            jSock.close();
        end
    catch
    end
    return;
end
if isempty(u)
    return;
end
try
    if useUdpPort
        clear u;
    elseif useLegacyUdp
        if strcmpi(get(u, 'Status'), 'open')
            fclose(u);
        end
        delete(u);
    end
catch
end
return;
