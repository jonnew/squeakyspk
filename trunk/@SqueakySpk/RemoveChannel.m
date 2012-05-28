function RemoveChannel(SS,channel2remove)
% REMOVECHANNELS(SS,channel2remove) removes data collected on
% channels that the experimenter knows
% apriori are bad for some reason. channelstoremove is a
% 1-based, linearly indexed set of channel numbers to be
% removed from the data. The default channels to remove are [1
% 8 33 57 64] corresponding to the four unconnected channels
% and the ground on a standard MCS MEA.
% Written by: JN

if nargin < 2 || isempty(channel2remove)
    channel2remove = [1 8 33 57 64];
end

% Append the badchannel vector
SS.badchannel = unique([SS.badchannel channel2remove]);

dirty = ismember(SS.channel,channel2remove)';
if ~isempty(dirty)
    SS.clean = SS.clean&(~dirty');
end

SS.methodlog = [SS.methodlog '<RemoveChannel>'];
end