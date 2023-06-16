function [buffer_decode,varargout]=rteeg_decode(buffer,varargin)
buffer_decode=[];
try

    buffer_decode.frameType=swapbytes(typecast(uint8(buffer(1)),'uint8'));
    buffer_decode.flag_ok=0;

    switch buffer_decode.frameType
        case 1 % MeasurementStart Packets
            buffer_decode.mainUnitNum=swapbytes(typecast(uint8(buffer(2)),'uint8'));
            buffer_decode.reserved=swapbytes(typecast(uint8(buffer(3:4)),'uint16'));
            buffer_decode.samplingRateHz=swapbytes(typecast(uint8(buffer(5:8)),'uint32'));
            buffer_decode.sampleFormat=swapbytes(typecast(uint8(buffer(9:12)),'uint32')); %should be 0x80000018 according to the manual
            buffer_decode.triggerDefs=swapbytes(typecast(uint8(buffer(13:16)),'uint32'));
            buffer_decode.numChannels=swapbytes(typecast(uint8(buffer(17:18)),'uint16'));
            for ch_idx=1:buffer_decode.numChannels
                buffer_decode.sourceChannels(ch_idx)=swapbytes(typecast(uint8(buffer(19+(ch_idx-1)*2:20+(ch_idx-1)*2)),'uint16'));
            end;
            offset=20+(ch_idx-1)*2+1;
            for ch_idx=1:buffer_decode.numChannels
                buffer_decode.channelType(ch_idx)=swapbytes(typecast(uint8(buffer(offset+(ch_idx-1)*2:offset+1+(ch_idx-1)*2)),'uint16'));
            end;

            buffer_decode.flag_ok=1;

        case 2 % Samples Packets
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

            buffer_decode.flag_ok=1;

        case 3 % Trigger Packets
            buffer_decode.mainUnitNum=swapbytes(typecast(uint8(buffer(2)),'uint8'));
            buffer_decode.numTriggers=swapbytes(typecast(uint8(buffer(3:4)),'uint16'));
            buffer_decode.reserved=swapbytes(typecast(uint8(buffer(5:8)),'uint32'));
            for trigger_idx=1:buffer_decode.numTriggers
                buffer_decode.trigger(trigger_idx).microTime=swapbytes(typecast(uint8(buffer(8+(trigger_idx-1)*20+1:8+(trigger_idx-1)*20+8)),'uint64'));
                buffer_decode.trigger(trigger_idx).sampleIndex=swapbytes(typecast(uint8(buffer(8+(trigger_idx-1)*20+9:8+(trigger_idx-1)*20+16)),'uint64'));
                buffer_decode.trigger(trigger_idx).type=swapbytes(typecast(uint8(buffer(8+(trigger_idx-1)*20+17)),'uint8'));
                buffer_decode.trigger(trigger_idx).code=swapbytes(typecast(uint8(buffer(8+(trigger_idx-1)*20+18)),'uint8'));
                buffer_decode.trigger(trigger_idx).reserved=swapbytes(typecast(uint8(buffer(8+(trigger_idx-1)*20+19:trigger_idx-1)*20+20)),'uint16'));
            end;

            buffer_decode.flag_ok=1;

        case 4 % MeasurementEnd Packets
            buffer_decode.mainUnitNum=swapbytes(typecast(uint8(buffer(2)),'uint8'));
            buffer_decode.reserved=swapbytes(typecast(uint8(buffer(3:4)),'uint16'));
            buffer_decode.finalSampleCount=swapbytes(typecast(uint8(buffer(5:12)),'uint64'));
            
            buffer_decode.flag_ok=1;
            
        case 5 % HardwareState Packets
            buffer_decode.mainUnitNum=swapbytes(typecast(uint8(buffer(2)),'uint8'));
            buffer_decode.stateType=swapbytes(typecast(uint8(buffer(3)),'uint8'));
            buffer_decode.reserved=swapbytes(typecast(uint8(buffer(4)),'uint8'));
            if(buffer_decode.stateType==1) %ClockSourceState
                buffer_decode.clockSourceState.microTime=swapbytes(typecast(uint8(buffer(5:12)),'uint64'));
                buffer_decode.clockSourceState.clockFreq=swapbytes(typecast(uint8(buffer(13:16)),'uint32'));
                buffer_decode.clockSourceState.targetclockFreq=swapbytes(typecast(uint8(buffer(17:20)),'uint32'));
                buffer_decode.clockSourceState.clockSrc=swapbytes(typecast(uint8(buffer(21:22)),'uint16'));
            end;
            
            buffer_decode.flag_ok=1;

        otherwise
            %not defined....
    end;
catch
    %error in decoding
end;


return;

