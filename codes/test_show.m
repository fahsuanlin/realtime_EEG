close all; clear all;

a=randn(10,10000);
sf=1000;
etc_trace(a,'fs',sf);

while true

    now=GetSecs;

    while(GetSecs-now<0.1) end;

    now=GetSecs;

    a(:,1:round(0.1*sf))=[];
    a(:,end+1:end+round(0.1*sf))=randn(10,round(0.1*sf));

    global etc_trace_obj;
    etc_trace_obj.data=a;
    etc_trace_handle('redraw');
end;