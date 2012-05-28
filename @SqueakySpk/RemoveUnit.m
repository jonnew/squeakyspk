function RemoveUnit(SS,unit2remove)
% REMOVEUNIT(unit2remove) removes all a spikes with ID in the
% unit2remove vector from the clean array. Default is to remove
% all unsorted 'spikes'.
% Written by: JN

if nargin < 2 || isempty(unit2remove)
    unit2remove = 0;
end
if isempty(SS.unit)
    warning('You have not clustered your data yet and unit information is not available. Cannot remove units')
    return
end

% Append the badunit vector
SS.badunit = [SS.badunit unit2remove];

dirty = ismember(SS.unit,unit2remove);
if ~isempty(dirty)
    SS.clean = SS.clean&(~dirty);
end
SS.methodlog = [SS.methodlog '<RemoveUnit>'];
end