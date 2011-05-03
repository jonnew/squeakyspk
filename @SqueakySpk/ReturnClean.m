function sqycln = ReturnClean(SS, bound)
% SQYCLN = RETURNCLEAN(SS) return the clean data. Returns an array of the
% format of the orginal main spike data containing those data indicies that
% have survived the cleaning process. The optional argument BOUND = [t0 t1]
% allows the user to return spike within a specific time window.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Aug 2, 2010
%       Last modified: May 2, 2011
%
% 	Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

sqycln = {};
if nargin <2 || isempty(bound)
    withinbound = ones(size(SS.time));
else
    withinbound = SS.time >= bound(1) & SS.time <= bound(2);
end
sqycln.time = SS.time(logical(SS.clean) & withinbound);
sqycln.channel = SS.channel(logical(SS.clean) & withinbound);
sqycln.waveform = SS.waveform(:,logical(SS.clean) & withinbound);
if ~isempty(SS.unit)
    sqycln.unit = SS.unit(logical(SS.clean) & withinbound);
end

end