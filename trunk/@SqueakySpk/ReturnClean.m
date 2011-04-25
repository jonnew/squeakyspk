function sqycln = ReturnClean(SS)
% SQYCLN = RETURNCLEAN(SS) return the clean data. Returns an array
% of the format of the orginal main spike data containing those
% data indicies that have survived the cleaning process.
% 
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Aug 2, 2010
%       Last modified: Aug 2, 2010
% 
% 	Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

sqycln = {};
sqycln.time = SS.time(logical(SS.clean));
sqycln.channel = SS.channel(logical(SS.clean));
sqycln.waveform = SS.waveform(:,logical(SS.clean));
if ~isempty(SS.unit)
    sqycln.unit = SS.unit(logical(SS.clean));
end

end