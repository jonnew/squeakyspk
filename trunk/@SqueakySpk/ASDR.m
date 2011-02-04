function ASDR(SS,dt,shouldplot)
% ASDR(SS,dt) Array-wide spike detection rate using time window
% dt in seconds. Returns a matix of the form [b A] where b are
% the time bins used to create the ASDR and A is matrix of
% firing rates where each colomn pertains to a single recording
% elecrode. This analysis is only performed on clean spikes.

if nargin < 3 || isempty(shouldplot)
    shouldplot = 1;
end
if nargin < 2 || isempty(dt)
    dt = 1; %seconds
end

% Calculate
bins = 0:dt:SS.time(end);
SS.csdr = zeros(length(bins),max(SS.channel)+1);
SS.csdr(:,1) = bins';
for i = 1:max(SS.channel)
    asdr_tmp = hist(SS.time(SS.clean&SS.channel==i),bins);
    if size(asdr_tmp,2) == 1;
        SS.csdr(:,i+1) = asdr_tmp./dt;
    else
        SS.csdr(:,i+1) = asdr_tmp'./dt;
    end
end

% Calculate ASDR
SS.asdr = [bins' sum(SS.csdr(:,2:end),2)];

% Plot results
if(shouldplot)
    figure()
    plot(SS.asdr(:,1),SS.asdr(:,2),'k');
    xlabel('Time (sec)')
    ylabel(['(' num2str(dt) 's)^-1'])
end

end