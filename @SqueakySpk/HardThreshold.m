function HardThreshold(SS,highThreshold,lowThreshold)
% HARDTHRESHOLD(SS,highThreshold,lowThreshold) removes all 'spikes'
% with P2P amplitude greater/less than high/low threshold
% (dependent on whatever units you are measuring AP's with).
% Written by: JN and RZT

% Set default thresholds if non are provided
if nargin < 2 || isempty(highThreshold)
    highThreshold = 175; %uV
end
if nargin < 3 || isempty(lowThreshold)
    lowThreshold = 0; %uV
end

dirty = ((max(SS.waveform) - min(SS.waveform)) > highThreshold | (max(SS.waveform) - min(SS.waveform)) < lowThreshold);
if ~isempty(dirty)
    SS.clean = SS.clean&(~dirty');
end

SS.methodlog = [SS.methodlog '<HardThreshold>'];
end