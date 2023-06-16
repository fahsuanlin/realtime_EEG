close all; clear all;

trace_obj=[];
for idx=1:10000
    
    trace_obj=rteeg_draw_trace(randn(10,300),1024,'trace_obj',trace_obj);

    pause(0.1)

end;