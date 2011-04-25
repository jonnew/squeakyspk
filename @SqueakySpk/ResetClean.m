function ResetClean(SS)
% RESETCLEAN(SS) Resets the clean, badunit and badchannel arrays
% so nothing is marked as dirty, and the clean array = true(size(SS.time));
% 
%   Created by: Jon Newman (jnewman6 at gatech dot edu)
%   Location: The Georgia Institute of Technology
%   Created on: July 30, 2009
%   Last modified: Aug 05, 2010
%
%   Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

SS.clean = true(length(SS.time),1);
SS.badchannel = [];
SS.badunit = [];
SS.methodlog = [SS.methodlog '<ResetClean>'];
