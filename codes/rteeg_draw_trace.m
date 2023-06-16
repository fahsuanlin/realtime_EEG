function [trace_obj]=rt_eeg_draw_trace(data,config_trace_fs, varargin)

fig=[];
trace_obj=[];

Sel=[]; %selection
Mon=[]; %montage
Sca=[]; %scaling

config_trace_color=[0.8500    0.3250    0.0980];
config_trace_width=1;

config_trace_ylim=[-5 5];
config_trace_duration=10; %duration of the trace to be shown (second)


if(isempty(Sel))
    Sel=eye(size(data,1)+1);
end;

if(isempty(Mon))
    Mon=eye(size(data,1)+1);
end;

if(isempty(Sca))
    Sca=eye(size(data,1)+1);
end;


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'fig'
            fig=option_value;
        case 'trace_obj'
            trace_obj=option_value;
        otherwise
    end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


prev_data=ones(size(data,1),round(config_trace_duration*config_trace_fs)).*nan;
prev_data_end_idx=1;
if(~isempty(trace_obj))
    if(isfield(trace_obj,'prev_data'))
        prev_data=trace_obj.prev_data;
    end;
    if(isfield(trace_obj,'prev_data_end_idx'))
        prev_data_end_idx=trace_obj.prev_data_end_idx;
    end;
end;


%update data
tmp=prev_data;
tmp(:,prev_data_end_idx+1:prev_data_end_idx+size(data,2))=data;
prev_data_end_idx=prev_data_end_idx+size(data,2);
if(size(tmp,2)>round(config_trace_duration*config_trace_fs))
    tmpp=tmp(:,round(config_trace_duration*config_trace_fs)+1:end);
    tmp(:,round(config_trace_duration*config_trace_fs)+1:end)=[];
    tmp(:,1:size(tmpp,2))=tmpp;
    prev_data_end_idx=size(tmpp,2);
end;
data_now=tmp;

%add nan future
tmp=data_now;
nan_data=ones(size(data,1),round(config_trace_fs*.3)).*nan;
tmp(:,prev_data_end_idx+1:prev_data_end_idx+size(nan_data,2))=nan_data;
if(size(tmp,2)>round(config_trace_duration*config_trace_fs))
    tmpp=tmp(:,round(config_trace_duration*config_trace_fs)+1:end);
    tmp(:,round(config_trace_duration*config_trace_fs)+1:end)=[];
    tmp(:,1:size(tmpp,2))=tmpp;
end;
data_now=tmp;



data_now=cat(1,data_now,ones(1,size(data_now,2)));

%select channels;
tmp=Sel*data_now;

%montage channels;
tmp=Mon*tmp;

%scaling channels;
tmp=Sca*tmp;


%vertical shift for display
S=eye(size(tmp,1));

if(isempty(fig))
    if(isempty(trace_obj))
       f=figure;
    else
        if(isfield(trace_obj,'fig'))
            try
                f=trace_obj.fig;
            catch
            end;
        else
            f=figure;
        end;
    end;
else
    try
        f=fig;
        clf(f);
    catch
        f=figure;
    end;
end;
trace_obj.fig=f;

%hold on;
axis;
ax=gca;
set(ax,'xlim',[0 config_trace_duration]);
set(ax,'ylim',[0 1]);

switch('trace')
    case 'trace'
        S(1:(size(tmp,1)-1),end)=(diff(sort(config_trace_ylim)).*[0:size(tmp,1)-2])'; %typical
    otherwise
end;


tmp=S*tmp;


trace_obj.hh=plot(ax, tmp.','color',config_trace_color);
set(trace_obj.hh,'linewidth',config_trace_width);

try
    set(ax,'ylim',[min(config_trace_ylim)-0.5 max(config_trace_ylim)+0.5+(size(Mon,1)-2)*diff(sort(config_trace_ylim))]);
    
    set(ax,'xlim',[1 round(config_trace_duration*config_trace_fs)]);
    set(ax,'xtick',round([0:config_trace_duration].*config_trace_fs)+1);
    set(ax,'ydir','reverse');
    xx=round([0:config_trace_duration]);
    set(ax,'xticklabel',cellstr(num2str(xx')));
catch ME
end;


if(~isempty(config_trace_duration))
    if(~isempty(config_trace_fs))
        %temporal grid line; 1-s per vertical line;
        yylim=get(ax,'ylim');
        for grid_idx=2:config_trace_duration
            grid_hh=line([(grid_idx-1)*config_trace_fs,(grid_idx-1)*config_trace_fs], yylim);
            set(grid_hh,'color',[1 1 1].*0.3);
        end;
    end;
end;


%font style
set(ax,'YTickLabel',{});
set(ax,'fontname','helvetica','fontsize',12);
set(f,'color','w')
set(ax,'Clipping','off');

trace_obj.prev_data=data_now(1:end-1,:);
trace_obj.prev_data_end_idx=prev_data_end_idx;

return;
%set(hh,'ButtonDownFcn',@etc_trace_callback);