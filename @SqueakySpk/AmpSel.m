function AmpSel(SS,threshold)
% AMPSEL(SS,threshold) select waveforms based on amplitude
% Written by: NK
% Set default threshold if none is provided
if nargin < 2 || isempty(threshold)
    threshold = 50; %uV, p2p amplitude
end
tmp = ((max(SS.waveform) - min(SS.waveform)) > threshold);
SS.clean = SS.clean&(tmp');
SS.methodlog = [SS.methodlog '<AmpSel>'];
end
