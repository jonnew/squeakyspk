function q=RandScat(SS,bound,forcechannel)
% RANDSCAT88(SS) plots scatter plots of the clean spikes that occured within bound 
% = [t0 t1] in SS. It stacks thin horizontal raster plots for each channel/unit. Within
% each plot, spikes are randomly positioned vertically for clarity.
%
% p = RandScat(SS) returns the plot handle.
% 
% This function is ported from:
% matlab/randscat88.m: part of meabench, an MEA recording and analysis tool
% Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)

if nargin < 3 || isempty(forcechannel)
    forcechannel = 0;
end
if nargin < 2 || isempty(bound)
    bound = [0 max(SS.time)];
end

dat = SS.ReturnClean;
idx = dat.time>=bound(1)&dat.time<bound(2);

figure()
if isempty(SS.unit) || forcechannel
    p=plot(SS.time(idx), SS.channel(idx) + 0.7*rand(size(SS.channel(idx))) - 0.35,'k.');
    ylabel 'Channel'
else
    p=plot(SS.time(idx), SS.unit(idx) + 0.7*rand(size(SS.unit(idx))) -.35,'k.');
    ylabel 'Unit'
end

set(p,'markersize',2);
xlabel 'Time (s)'
axis tight

if nargout>0
  q=p;
end
