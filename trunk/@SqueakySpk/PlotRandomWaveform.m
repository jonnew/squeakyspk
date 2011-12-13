function PlotRandomWaveform(SS,plotall,N,rangeV,bound)
% PLOTRANDOMWAVEFORM plots N waveforms randomly choosen from the data in
% SS. This gives a general idea of spike-waveform characteristics and does
% not depend on sorting. This function does not employ subplot, so it is
% very fast for plotting many waveforms across many different channels.
% PLOTALL determines random waveforms are drawn from all spikes (1) or just
% clean ones (0), the default being 0. N is the number of waveforms to be
% plotted. RANGEV is the maximal voltage range to allocate for each channel
% (each box will be +-RANGEV). BOUND allows the user to specify a time
% block [t0 t1] from the recording to create the plot from.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu) Location: The
%       Georgia Institute of Technology Created on: Feb 2, 2011 Last
%       modified: Feb 2, 2011
% 	Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if nargin < 5 || isempty(bound)
    bound = [0 max(SS.time)];
end
if nargin < 4 || isempty(rangeV)
    rangeV = 200; % uV
end
if nargin < 3 || isempty(N)
    N = 1000; % Default to 1000 waveforms
end
if nargin < 2 || isempty(plotall)
    plotall = 0;
end

dat = SS.ReturnClean;
if(~plotall)
    dat.waveform = dat.waveform(:,dat.time > bound(1) & dat.time < bound(2));
    dat.channel = dat.channel(dat.time > bound(1) & dat.time < bound(2),:);
    if (~isempty(dat.unit))
        dat.unit = dat.unit(dat.time > bound(1) & dat.time < bound(2),:);
    end
    dat.time = dat.time(dat.time > bound(1) & dat.time < bound(2));
else
    dat.waveform = SS.waveform(:,dat.time > bound(1) & dat.time < bound(2));
    dat.channel = SS.channel(dat.time > bound(1) & dat.time < bound(2),:);
    if (~isempty(SS.unit))
        dat.unit = SS.unit(dat.time > bound(1) & dat.time < bound(2),:);
    end
    dat.time = SS.time(dat.time > bound(1) & dat.time < bound(2));
end



if N > length(dat.time)
    N = length(dat.time);
    if N > 0
        warning(['Number of waveforms requested is larger more than clean spikes comtained ' ...
            'in this SS object, setting N = ' num2str(N)]);
    else
        warning('No waveforms to plot');
        return
    end
end

% time matrix
T = ((1:size(dat.waveform,1))./SS.fs)';
T = T(:,ones(1,N))*1000; % conver to ms
maxT = T(end,1);

% Get the random set of waveforms
r = randperm(length(dat.time));
r = r(1:N);
W = dat.waveform(:,r);

chs = (dat.channel(r));
if (isempty(SS.unit) || max(SS.unit) == 0)
    
    % Create color matrix
    col = jet(max(SS.channel));
    col = col(chs,:);
else
    uni = (dat.unit(r));
    % Create color matrix
    jcol = jet(max(uni));
    jcol = jcol(randperm(size(jcol,1)),:);
    col = [[0 0 0]; jcol];
    col = col(uni+1,:);
end

% Constants to find plot position
n = ceil(sqrt(max(dat.channel)));

% Calculate position of the waveforms and time axes
if size(chs,1) > 1
    yoff = rangeV.*(n-ceil(chs'/n)+0.5);
    xoff = T(end,1)*mod(chs'-1,8);
else
    yoff = rangeV.*(n-ceil(chs'/n)+0.5)';
    xoff = T(end,1)*mod(chs'-1,8)';
end

% Apply offsets
W = W + yoff(ones(size(W,1),1),:);
T = T + xoff(ones(size(W,1),1),:);

% Create grid
xgridy = [rangeV*(1:n);rangeV*(1:n)];
xgridx = [zeros(1,n); maxT*n*ones(1,n)];

ygridx = [maxT*(1:n);maxT*(1:n)];
ygridy = [rangeV*n*ones(1,n);zeros(1,n)];

% plot
q = figure();
set(gca, 'ColorOrder', col);
hold all
plot(T,W);
line(ygridx,ygridy,'color',[0 0 0]);
line(xgridx,xgridy,'color',[0 0 0]);
axis([0 n*maxT 0 n*rangeV]);
set(gca,'XTick',[maxT],'YTick',[rangeV]);
xlabel('msec')
ylabel('uV')
title([num2str(N) ' random waveforms from ' SS.name]);
end

