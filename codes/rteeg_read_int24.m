function Casted = TypecastInt24(Bytes)
        
    Bytes=flipud([248 231 55]');
    % reshape to matrix with one column(length 3) for each int24 value
    Casted = reshape(Bytes,3,[]);
    % add pending zero to each column to enable native uint32 type conversion
    Casted = [Casted;zeros(1,size(Casted,2))];
    % execute typecast for each column and transpose to maintain row vector
    Casted = typecast(uint8(Casted(:)),'uint32')';
    % simulate int32 value by bytehshift, convert and shift back
    Casted = bitshift(Casted, 8);
    Casted = bitshift(typecast(Casted,'int32'), -8);
end