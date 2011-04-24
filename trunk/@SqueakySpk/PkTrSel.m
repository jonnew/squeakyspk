function PkTrSel(SS,width)
% PKTRSEL(SS,width) select waveforms based on peak-trough time
% Written by: NK
% Set default min/max widths if none are provided
if nargin < 2 || isempty(width)
    width = [0 500]; %usec, peak-trough
end
[dum pt] = max(SS.waveform);[dum trt] = min(SS.waveform);
tmpw = abs(pt-trt)/SS.fs*1e6;
tmp = tmpw>=width(1) & tmpw<=width(2);
SS.clean = SS.clean&(tmp');
SS.methodlog = [SS.methodlog '<PkTrSel>'];
end
