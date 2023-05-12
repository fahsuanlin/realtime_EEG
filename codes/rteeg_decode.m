function [buffer_decode,varargout]=rteeg_decode(buffer,varargin)
buffer_decode=[];
try

    buffer_decode.frameType=swapbytes(typecast(uint8(buffer(1)),'uint8'));
    if( buffer_decode.frameType==2) % Samples Packets
        buffer_decode.mainUnitNum=swapbytes(typecast(uint8(buffer(2)),'uint8'));
        buffer_decode.reserved=swapbytes(typecast(uint8(buffer(3:4)),'uint16'));
        buffer_decode.packetSeqNo=swapbytes(typecast(uint8(buffer(5:8)),'uint32'));
        buffer_decode.numChannels=swapbytes(typecast(uint8(buffer(9:10)),'uint16'));
        buffer_decode.numSampleBundles=swapbytes(typecast(uint8(buffer(11:12)),'uint16'));
        buffer_decode.firstSampleIndex=swapbytes(typecast(uint8(buffer(13:20)),'uint64'));
        buffer_decode.firstSampleTime=swapbytes(typecast(uint8(buffer(21:28)),'uint64'));
        buffer_decode.sample=uint8(buffer(29:end));

        buffer_decode.sample=reshape(buffer_decode.sample,[3, length(buffer_decode.sample)/3]);
        buffer_decode.sample=rteeg_read_int24(buffer_decode.sample);
        buffer_decode.sample=reshape(buffer_decode.sample, [buffer_decode.numChannels, length(buffer_decode.sample(:))/ buffer_decode.numChannels]);
    else

    end;
catch

end;


return;

