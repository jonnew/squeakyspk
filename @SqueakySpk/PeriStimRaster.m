function[] = PeriStimRaster(SS,bound,dur,ch)
%PERISTIMTIMERASTER creates a colorful peristimulus raster plot, similar to
%figure 1b of Bakkum, Chao, and Potter's Long-Term Activity-Dependent
%Plasticity of Action Potential Propagation Delay and Amplitude in Cortical
%Networks
%
%   	PeriStimRaster(SS,bound,dur,ch) calculates the peristimulus raster
%   	plot.  This consists of an 8 x 8 grid, one subplot for each
%   	stimulating eletrode. Each responding electrode is shown with a
%   	different color (ie, spikes detected on channel 2 in response to
%   	stimulation appear cyan, whereas spikes detected on channel 63
%   	appear red).  The x axis shows the delay from the stimulus in
%   	milliseconds, the y axis shows the time elapsed from the beginning
%   	of the experiment in secons.
%       BOUND is a two element array showing the upper and lower time bound
%       to examine in this plot (ie, what part of the experiment do you
%       want to look at?)
%       DUR is the duration- how many milliseconds after stimulation do you
%       want to look?  The figure referenced above looked 20 ms post
%       stimulus, which is where most dAPs are expected to occur
%       CH is an optional argument, specifying what channel you want to
%       look at.  This can be useful if you want to zoom in on the
%       responses to a particular channel rather than look at all the data
%       at once.

tic
%

%set(h,'visible','off');
if nargin < 1
    error('Need to act on SqueakSpk Object');
end
if (nargin < 2)
    bound = [min(SS.st_time) max(SS.st_time)];
end
if (nargin <3)
    dur =20;
end
if (nargin<4)
    all = 1;
else
    all = 0;
end


% Make sure the data actual has stimulation entries
if isempty(SS.st_time)
    warning('You must provide stimulus timing information to form a peristimulus raster. Now exiting...')
    return
end
if all
    goodstim = find(SS.st_time >= bound(1) & SS.st_time <= bound(2));
else
    goodstim = find(SS.st_time >= bound(1) & SS.st_time <= bound(2) & SS.st_channel ==ch);
end
st_time = SS.st_time(goodstim);
st_chan = SS.st_channel(goodstim);

goodspike = find((SS.time >= bound(1) & SS.time <= bound(2))&SS.clean);
sp_time = SS.time(goodspike);
sp_chan = SS.channel(goodspike);


 i = 1:64;
%     if all
%         subplot(8,8,i); axis([0 dur bound(1) bound(2)]);
%     end
    r = ceil(i/8);
    c = ceil(mod(i-1,8))+1;
    colors = [c/8 ;1-r/8 ;1-c/8]';
%     plot(1,10,'*','markersize',45,'color',colors(i,:));
    

% if ~all
% axis([0 dur bound(1) bound(2)]);
% end

%looking at responses to just one channel
h2 = waitbar(0,'generating peristimulus raster');
xoffset = dur;
yoffset = bound(2)-bound(1);


x = NaN(length(sp_time),1);
y = NaN(length(sp_time),1);
cl = NaN(length(sp_time),1);
ind = 1;
for i = 1:length(st_time)
    
   
    
    tmpx = sp_time((sp_time-st_time(i)<dur/1000) & (sp_time-st_time(i)>0));

    if ~isempty(tmpx)
        if all
            tmpy = st_time(i)+yoffset*(r(st_chan(i))-1)-bound(1);
            tmpx = tmpx-st_time(i);
            tmpx = tmpx*1000+xoffset*(c(st_chan(i))-1);
            tmpc = sp_chan((sp_time-st_time(i)<dur/1000) & (sp_time-st_time(i)>0));
        else
            tmpy = st_time(i)-bound(1);
            tmpx = tmpx-st_time(i);
            tmpx = tmpx*1000;
            tmpc = sp_chan((sp_time-st_time(i)<dur/1000) & (sp_time-st_time(i)>0));
        end
        %set(h,);
        %colors(tmpc,:)
        
       % [tmp'*1000;tmp'*1000]
       % tmpx*ones(2,length(tmpc))
      % x
      % tmpx
      x(ind:ind-1+length(tmpx)) =tmpx';
     % y
     % tmpy*ones(1,length(tmpc))
      y(ind:ind-1+length(tmpx)) = tmpy*ones(1,length(tmpc));
      cl(ind:ind-1+length(tmpx)) = tmpc';
      ind = ind+length(tmpx);
        %set(b,'ColorOrder',colors(tmpc,:));
        
        %line([tmpx';tmpx'],tmpy*ones(2,length(tmpc)));
        
    end

    if (mod(i,40)==0)
        waitbar(i/length(st_time),h2);
    end
%pause
end
toc
h = figure;
set(h,'visible','off');%hold on;
if all
    b = axes('XLim',[0 8*xoffset],'YLim',[0 8*yoffset]);
else
    b = axes('XLim',[0 xoffset],'YLim',[0 yoffset]);
end

set(b,'ColorOrder',colors(cl(1:ind-1),:));
%,'.','markersize',1
lout =line([x(1:ind-1)';x(1:ind-1)'],[y(1:ind-1)';y(1:ind-1)']);
set(lout,'MarkerSize',1,'LineStyle','.');

if all
    n=8;
    xgridy = [yoffset*(1:n);yoffset*(1:n)];
    xgridx = [zeros(1,n); xoffset*n*ones(1,n)];

    ygridx = [xoffset*(1:n);xoffset*(1:n)];
    ygridy = [yoffset*n*ones(1,n);zeros(1,n)];

    line(ygridx,ygridy,'color',[0 0 0]);
    line(xgridx,xgridy,'color',[0 0 0]);
end
set(gca,'XTick',[0 xoffset],'YTick',[0 yoffset],'YTickLabel',bound);
xlabel('msec post stimulus')
ylabel('seconds into experiment')
title('PeriStimulus Rasterplot');
set(h,'visible','on');
close(h2);

toc

end