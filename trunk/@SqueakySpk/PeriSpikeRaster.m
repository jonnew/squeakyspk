function[] = PeriSpikeRaster(SS,unit,bound,dur)

%PERISPIKERASTER creates a colorful perispike raster plot, similar to
%figure 1b of Bakkum, Chao, and Potter's Long-Term Activity-Dependent
%Plasticity of Action Potential Propagation Delay and Amplitude in Cortical
%Networks.  Except this time, we are looking at all the stimuli that evoked
%a response on this particular unit
%
%   	PeriSpikeRaster(SS,bound,dur,unit) finds all the stimuli that
%   	occurred directly before a spike was detected on either a specific
%   	channel or a specific unit.  Stimuli are color coded by channel in
%   	a manner identicle to how spikes are color coded by channel in the
%   	peristimulusraster plot.
%       

tic
%


if nargin < 1
    error('Need to act on SqueakSpk Object');
end
if (nargin < 2)
    error('need to specify unit/channel');
end
if (nargin <3)
    bound =  [ max([min(SS.st_time) min(SS.time)]) min([max(SS.st_time) max(SS.time)])];
    
end
if (nargin<4)
    dur =20;
end

%all =0;
% Make sure the data actual has stimulation entries
if isempty(SS.st_time)
    warning('You must provide stimulus timing information to form a perispike raster. Now exiting...')
    return
end

    goodstim = find(SS.st_time >= bound(1) & SS.st_time <= bound(2));

st_time = SS.st_time(goodstim);
st_chan = SS.st_channel(goodstim);

if ~isempty(SS.unit)
    goodspike = find((SS.time >= bound(1) & SS.time <= bound(2))&(SS.unit==unit));
else
    goodspike = find((SS.time >= bound(1) & SS.time <= bound(2))&(SS.channel==unit));
end

sp_time = SS.time(goodspike);
sp_chan = SS.channel(goodspike);


 i = 1:64;
%     if all
%         subplot(8,8,i); axis([0 dur bound(1) bound(2)]);
%     end
    r = 9-ceil(i/8);
    c = ceil(mod(i-1,8))+1;
    colors = [c/8 ;1-r/8 ;1-c/8]';
%     plot(1,10,'*','markersize',45,'color',colors(i,:));
    

% if ~all
% axis([0 dur bound(1) bound(2)]);
% end

%looking at responses to just one channel
h2 = waitbar(0,'generating perispike raster');
xoffset = dur;
yoffset = bound(2)-bound(1);


x = NaN(length(st_time),1);
y = NaN(length(st_time),1);
cl = NaN(length(st_time),1);
ind = 1;
for i = 1:length(sp_time)
    
   %find the indices of stimuli we are interested in.
    tmpinds =  (st_time-sp_time(i)>-dur/1000) & (st_time-sp_time(i)<0);
    
    
    if ~isempty(tmpinds)
        tmpx = st_time(tmpinds);
        
            tmpy = sp_time(i)-bound(1);
            tmpx = tmpx-sp_time(i);
            tmpx = tmpx*1000;
            tmpc = st_chan(tmpinds);
        
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
        waitbar(i/length(sp_time),h2);
    end
%pause
end
toc
h = figure;
set(h,'visible','off');%hold on;
subplot(1,3,3);
if ~isempty(SS.unit)
    tmp = find(SS.unit==unit);
else
    tmp = find(SS.channel ==unit);
end
waves = SS.waveform(:,tmp(ceil(rand(30,1)*length(tmp))));
plot(waves);hold on;
if ~isempty(SS.avgwaveform)
plot(SS.avgwaveform(:,unit),'linewidth',4,'color','k');
end
axis tight;
xlabel('sample no.')
ylabel('uV')

b = subplot(1,3,[1 2]);

    set(b,'XLim',[-xoffset 0],'YLim',[0 yoffset]);


set(b,'ColorOrder',colors(cl(1:ind-1),:));
%,'.','markersize',1
lout =line([x(1:ind-1)';x(1:ind-1)'],[y(1:ind-1)';y(1:ind-1)']);

set(lout,'MarkerSize',6,'LineStyle','.');



set(gca,'XTick',[-xoffset 0],'YTick',[0 yoffset],'YTickLabel',bound);
xlabel('msec before spike')
ylabel('seconds into experiment')


    title(['PeriSpike Rasterplot, response on unit ' num2str(unit)]);


set(h,'visible','on');




close(h2);

toc

end