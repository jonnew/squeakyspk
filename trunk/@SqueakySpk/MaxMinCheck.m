function MaxMinCheck(SS,th)
% MAXMINCHECK(SS,th)
% no max or min at first 2 or last 2 samples is allowed
% with +/- uV thresholding
% Written by: NK
if nargin < 2 || isempty(th)
    th = 150; %uV, p2p amplitude
end
[maxs maxi] = max(SS.waveform);[mins mini] = min(SS.waveform);
tmp = (maxi>2 & maxi<(size(SS.waveform,1)-1)) & (mini>2 & mini<(size(SS.waveform,1)-1)) & ...
    (maxs<th)&(mins>-th);
SS.clean = SS.clean&(tmp');
SS.methodlog = [SS.methodlog '<MaxMinCheck>'];
end
