function q = RandScat(SS,bound,forcechannel,makefig)
% RANDSCAT(SS, BOUND, FORCECHANNEL, MAKEFIG) plots scatter plots of the
% clean spikes that occured within bound = [t0 t1] in SS. It stacks thin
% horizontal raster plots for each channel/unit. Within each plot, spikes
% are randomly positioned vertically for clarity. FORCECHANNEL = 1 forces
% the ordinate axis to display channel number in the case that your data is
% spike sorted. MAKEFIG = 1 the scatter plot in a new figure, 0 in whatever
% axes are open. Default is 1.
%
% p = RandScat(SS) returns the plot handle.
% 
% This function is ported from:
% matlab/randscat88.m: part of meabench, an MEA recording and analysis tool
% Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)

if nargin < 4 || isempty(makefig)
    makefig = 1;
end
if nargin < 3 || isempty(forcechannel)
    forcechannel = 0;
end
if nargin < 2 || isempty(bound)
    bound = [0 max(SS.time)];
end

dat = SS.ReturnClean;
idx = dat.time>bound(1)&dat.time<bound(2);

if makefig
    figure()
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
