function q = RandScat(SS,bound,forcechannel,sortu,sortbound)
% RANDSCAT(SS, BOUND, FORCECHANNEL, MAKEFIG) plots scatter plots of the
% clean spikes that occured within bound = [t0 t1] in SS. It stacks thin
% horizontal raster plots for each channel/unit. Within each plot, spikes
% are randomly positioned vertically for clarity. FORCECHANNEL = 1 forces
% the ordinate axis to display channel number in the case that your data is
% spike sorted. SORTU determines whether units are sorted by their firing
% rate in the figure. SORTBOUND determins the recording range over which to
% calculate the firing rate values to come up with unit sorting.
%
% p = RandScat(SS) returns the plot handle.
% 
% This function is ported from:
% matlab/randscat88.m: part of meabench, an MEA recording and analysis tool
% Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)

if nargin < 5 || isempty(sortbound)
    sortbound = [0 SS.time(end)];
end
if nargin < 4 || isempty(sortu)
    sortu = 0;
end
if nargin < 3 || isempty(forcechannel)
    forcechannel = 0;
end
if nargin < 2 || isempty(bound)
    bound = [0 max(SS.time)];
end

dat = SS.ReturnClean;
idx = dat.time>bound(1)&dat.time<bound(2);

% sort the image by integrated unit firing rate?
if sortu
    uu = unique(dat.unit);
    tmp = dat.unit(dat.time >= sortbound(1) & dat.time < sortbound(2),:)';
    nu = zeros(length(uu),1);
    for i = 1:length(uu)
        nu(i) = sum(tmp == uu(i));
    end
    [x idx2] = sort(nu);
    du = dat.unit;
    for i = 1:length(idx2)
        dat.unit(du == idx2(i)) = i;
    end
end
    

if ~isfield(dat,'unit') || forcechannel
    p=plot(dat.time(idx)-bound(1), dat.channel(idx) + 0.7*rand(size(dat.channel(idx))) - 0.35,'k.');
    ylabel 'Channel'
else
    p=plot(dat.time(idx)-bound(1), dat.unit(idx) + 0.7*rand(size(dat.unit(idx))) -.35,'k.');
    ylabel 'Unit'
end

set(p,'markersize',2);
xlabel 'Time (s)'
xlim([0 bound(2)-bound(1)]);
axis tight

if nargout>0
  q=p;
end
