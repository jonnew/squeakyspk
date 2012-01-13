function CalculateAvgWaveform(SS)
% CALCULATEAVGWAVEFORM(SS) Calculates the average waveforms for each
% unit.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Dec 13, 2011
%       Last modified: Dec 13, 2011
% 	Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if (isempty(SS.unit) || max(SS.unit) == 0)
    error('You have not performed spike sorting yet, or there are no valid units. Exiting CALCULATEAVGWAVEFORM.')
end

% Get all the unit numbers
uu = unique(SS.unit);

% Exclude unsorted data
uu = uu(uu ~= 0);

% Empty matrix to store average waveforms
SS.avgwaveform.avg = zeros(size(SS.waveform,1),length(uu));
SS.avgwaveform.std = zeros(size(SS.waveform,1),length(uu));

% For each detected unit, find the mean waveform
for i = 1:length(uu)
    wu = SS.waveform(:,SS.unit == uu(i));
    SS.avgwaveform.avg(:,i) = mean(wu,2);
    SS.avgwaveform.std(:,i) = std(wu,[],2);
end
end