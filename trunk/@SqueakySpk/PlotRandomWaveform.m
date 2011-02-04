function q = PlotRandomWaveform(SS,N,rangeV)
%PLOTRANDOMWAVEFORM plots N waveforms randomly choosen from the data in SS.
%This give a general idea of spike characteristics that does not depend on
%sorting

if nargin < 3 || isempty(rangeV)
    rangeV = 200; % uV
end
if nargin < 2 || isempty(N)
    N = 1000; % Default to 1000 waveforms
end

dat = SS.ReturnClean;

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
chs = (dat.channel(r))';

% Constants to find plot position
n = ceil(sqrt(max(dat.channel)));

% Calculate position of the waveforms
yoff = rangeV.*(n-ceil(chs/n)+0.5);
W = W + yoff(ones(size(W,1),1),:);

% Calculate posisitions of time axes
xoff = T(end,1)*mod(chs-1,8);
T = T + xoff(ones(size(W,1),1),:);

% Create grid
xgridy = [rangeV*(1:n);rangeV*(1:n)];
xgridx = [zeros(1,n); maxT*n*ones(1,n)];

ygridx = [maxT*(1:n);maxT*(1:n)];
ygridy = [rangeV*n*ones(1,n);zeros(1,n)];

% plot
q = figure();
hold on
plot(T,W,'b');
line(ygridx,ygridy,'color',[0 0 0]);
line(xgridx,xgridy,'color',[0 0 0]);
axis([0 n*maxT 0 n*rangeV]);
set(gca,'XTick',[maxT],'YTick',[rangeV]);
xlabel('msec')
ylabel('uV')
title([num2str(N) ' random waveforms from ' SS.name]);
end

