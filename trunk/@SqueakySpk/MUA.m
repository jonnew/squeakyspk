function MUA(SS)
% MUA(SS) all units on the same channel are combined to create
% Multi-Unit Activity (MUA)
% Written by: NK
SS.unit = SS.clean.*SS.channel;
SS.methodlog = [SS.methodlog '<MUA>'];
end
