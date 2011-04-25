function PlotUnitWisePSH(SS,frmax,include0)
% PLOTUNITWISEPSH plots the results of UnitWisePSH.
% 
%     PLOTUNITWISEPSH(SS,FRMAX) takes information from the upsh property to
%     display data as image wherein the firing rate of each unit is shown
%     in grey scale from 0 to FRMAX Hz. FRMAX is set to the maximal
%     detected firing rate by default. INCLUDE0 is a boolean that
%     determines whether the 0 unit should be included in the plot. Its
%     default value is false.
% 
%     Created by: Jon Newman (jnewman6 at gatech dot edu) Location: The
%     Georgia Institute of Technology 
%     Created on: April 24, 2011 
%     Last modified: April 24, 2011
%
%     Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt


if isempty(SS.upsh)
    warning('You need to calculate the upsh before plotting it. Run SS.UnitWisePSH.');
    return;
end

if nargin < 3 || isempty(include0)
    include0 = false;
end
if nargin < 2 || isempty(frmax)
    frmax = inf;
end

figure()

% Decide if unit 0 should be included
if include0
    img = SS.upsh.hist';
else
    img = SS.upsh.hist(:,SS.upsh.unit ~= 0)';
end
    
% Create a color map that is good at displaying a wide range of data
cmp = gray(200);
cmp = flipud(cmp.^3);

if sum(sum(img > frmax)) > 0
    img(img > frmax ) = frmax;
elseif frmax ~= inf
    img(end) = frmax;
end

% Make the image
q = imagesc(img);
c = colorbar();
ylabel(c,'Firing Rate (Hz)')
colormap(cmp);

% fix the x-axis
xt = get(gca,'XTick');
idx = round(length(SS.upsh.t)*(xt/max(xt)));
set(gca,'XTickLabel',SS.upsh.t(idx));

% labels
xlabel('Time (sec)')
ylabel('Unit (sorted by response efficacy)')
set(gca,'YDir','normal')
end