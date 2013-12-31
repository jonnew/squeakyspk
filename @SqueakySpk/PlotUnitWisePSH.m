function [q, c] = PlotUnitWisePSH(SS,frmax,include0)
% PLOTUNITWISEPSH plots the results of UnitWisePSH.
% 
%     PLOTUNITWISEPSH(SS,FRMAX) takes information from the upsh property to
%     display data as image wherein the firing rate of each unit/channel is
%     shown in grey scale from 0 to FRMAX Hz. FRMAX is set to the maximal
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

% Decide if unit 0 should be included
if include0 || strcmp(SS.upsh.type,'channel-wise')
    img = SS.upsh.hist';
elseif strcmp(SS.upsh.type,'unit-wise')
    img = SS.upsh.hist(:,SS.upsh.which ~= 0)';
end
    
% Create a color map that is good at displaying a wide range of data
cmp = [spring(50); gray(200)];
cmp = flipud(cmp);


% cmp = flipud(cmp);

if sum(sum(img > frmax)) > 0
    img(img > frmax ) = frmax;
elseif frmax ~= inf
    img(end) = frmax;
end

% Make the image
q = image(size(cmp,1)*img/frmax);
% c = colorbar();
% ylabel(c,'Firing Rate (Hz)')
colormap(cmp);

% % fix the x-axis
% xt = get(gca,'XTick');
% idx = round(length(SS.upsh.t)*(xt/max(xt)));
% idx(idx == 0) = 1;
% set(gca,'XTickLabel',SS.upsh.t(idx));

% % Draw a line indicating time 0
% hold on
% idx = find(SS.upsh.t ==0);
% plot([idx idx],[0 size(img,1)],'b-','LineWidth',2)

% labels
% xlabel('Time (sec)')
if strcmp(SS.upsh.type,'unit-wise')
%     ylabel('Unit (sorted by response efficacy)')
else
%     ylabel('Channel (sorted by response efficacy)')
end
set(gca,'YDir','normal')
end