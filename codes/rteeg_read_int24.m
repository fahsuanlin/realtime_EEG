%function Casted = TypecastInt24(Bytes)
function output=rteeg_read_int24(input)
% rteeg_read_int24  converts the input data from uint8 into int24
%
% output=rteeg_read_int24(input)
%
% input: a 3xN byte data matrix
%
% out: a 1xN byte vector matrix
%
% fhlin@May 11 2023
%


output=[];

[m,n]=size(input);
if(m~=3)
    fprintf('input must be a 3xN matrix!\nerror!\n');
    return;
end;

% Decode signed int24 from bytes ordered as [MSB; MID; LSB].
u = uint32(input(1,:)) * uint32(65536) + ...
    uint32(input(2,:)) * uint32(256) + ...
    uint32(input(3,:));
i = int32(u);
negMask = bitand(u, uint32(hex2dec('800000'))) ~= 0;
i(negMask) = int32(double(i(negMask)) - 2^24);
output = double(i);
return;
