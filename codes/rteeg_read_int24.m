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

Bytes=flipud(input); %little --> big endian

%Bytes=flipud([248 231 55]');
% reshape to matrix with one column(length 3) for each int24 value
Casted = reshape(Bytes,3,[]);
% add pending zero to each column to enable native uint32 type conversion
Casted = [Casted;zeros(1,size(Casted,2))];
% execute typecast for each column and transpose to maintain row vector
Casted = typecast(uint8(Casted(:)),'uint32')';
% simulate int32 value by bytehshift, convert and shift back
Casted = bitshift(Casted, 8);
Casted = bitshift(typecast(Casted,'int32'), -8);

output=Casted;
return;
