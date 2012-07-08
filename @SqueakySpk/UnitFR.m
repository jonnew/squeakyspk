function UnitFR(SS,bound,units)
% UNITFR(SS) Calculate the average firing rate of the recorded units. This
% function operates on clean spikes only. When finished, it populates the
% unitfr matrix in the SqueakySpk object. This is a NX2 matrix with the
% first colum populated with unit numbers and the second column populated
% with the corresponding firing rate.
%
% UNITFR(SS,BOUND,UNITS) Calculates the average firing rate of the recorded
% units over the BOUND = [T1 T2] in the recording. T1 and T2 are in
% seconds. UNITS is a vector arguement that forces the firing rate
% calculation to be carried out on only the units provided in the UNITS
% vector.
% 
%       Created by: Jon Newman (jnewman6 at gatech dot edu) Location: The
%       Georgia Institute of Technology Created on: June 6, 2012 Last
%       modified: June 6, 2012 Licensed under the GPL:
%       http://www.gnu.org/licenses/gpl.txt

if isempty(SS.unit)
    warning('You need to perform spike sorting before running this function.');
    return;
end

if (nargin < 2 || isempty(bound))
    tend = SS.time(end);
    bound = [0 tend];
end

dat = SS.ReturnClean;

if (nargin < 3 || isempty(units))
    uu = unique(dat.unit);
else
    uu = units;
    if size(uu,2) > 1
        uu = uu';
    end
end
fr = zeros(size(uu));

for i = 1:length(uu)
   fr(i) =  sum(SS.unit(SS.time > bound(1) & SS.time < bound(2)) == uu(i))/(bound(2) - bound(1));
end

SS.unitfr = [uu fr];

end