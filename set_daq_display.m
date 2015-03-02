function lh = set_daq_display(s)

fig = findobj(0,'Type','figure','Tag','daq_display');
if isempty(fig)
    fig = figure('Name','DAQ display','Tag','daq_display');
end
ch = get(s,'Channels');
nchan = length(ch);

col = get(fig,'DefaultAxesColorOrder');
ncol = ceil(nchan/size(col,1));
col = repmat(col,[ncol 1]);

ax = findobj(fig,'Type','axes');
if (length(ax) ~= nchan)
    clf(fig);

    ax = zeros(nchan,1);
    hln = zeros(nchan,1);

    w = 0.85;
    htotal = 0.9;
    h = htotal/nchan;
    x = (1-w)/2;
    y = 1 - (1-htotal)/2 - h;

    for i = 1:nchan
        ax(i) = axes('Parent',fig, 'Position',[x y w h]);
        nm = get(ch(i),'Name');
        if (isempty(nm))
            nm = get(ch(i), 'ID');
        end
        ylabel(ax(i), nm);
        y = y-h;

        if (i < nchan)
            set(ax(i),'XTickLabel',{});
        end

        hln(i) = line('XData',[], 'YData',[], 'Color',col(i,:), 'Parent',ax(i));
    end
    linkaxes(ax,'x');
    set(ax,'XLim',[0 get(s,'DurationInSeconds')]);
else
    ax = ax(end:-1:1);
    
    hln = zeros(nchan,1);
    for i = 1:nchan
        hln1 = findobj(ax(i),'Type','line');
        if ~isempty(hln)
            hln(i) = hln1(1);
            set(hln(i),'XData',[], 'YData',[]);
        else
            hln(i) = line('XData',[], 'YData',[], 'Color',col(i,:), 'Parent',ax(i));
        end
    end
end
            
lh = addlistener(s,'DataAvailable', @(src,event) show_daq_data(src,event,hln));

function show_daq_data(src,event,hln)

tadd = event.TimeStamps;
datadd = event.Data;

for i = 1:size(datadd,2)
    t = get(hln(i),'XData');
    if (isempty(t))
        t = tadd;
    else
        t = cat(1,t(:),tadd(:));
    end
    dat = get(hln(i),'YData');
    if (isempty(dat))
        dat = datadd(:,i);
    else
        dat = cat(1,dat(:),datadd(:,i));
    end
    
    set(hln(i),'XData',t, 'YData',dat);
end



    
    
    
    
