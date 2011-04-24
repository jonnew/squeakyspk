function MinCheck(SS,mintime)
% MINCHECK(SS,mintime)
% check that the minimum value is past a certain sample
% you need to know when/where your threshold was
% this is currently only relevant for a negative threshold -only scheme
% Written by: NK
if nargin < 2 || isempty(mintime)
    mintime = [500]; %usec, peak-trough
end
[dum trt] = min(SS.waveform);
tmp = (trt/SS.fs*1e6)<mintime;
SS.clean = SS.clean&(tmp');
SS.methodlog = [SS.methodlog '<MinCheck>'];
end
