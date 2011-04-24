function Crossing(SS,th)
% CROSSING(SS,th)
% require a zero (or user-specified)-crossing of +/->=5 uV
% Written by: NK
if nargin < 2 || isempty(th)
    th = 0; %uV, p2p amplitude
end
tmp = max(SS.waveform)>=(th+5) & min(SS.waveform)<=(th+5);
SS.clean = SS.clean&(tmp');
SS.methodlog = [SS.methodlog '<Crossing>'];
end
