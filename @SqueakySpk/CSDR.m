function PlotCSDR(SS,frmax)
% CSDR(SS,FRMAX) Channel Spike Detection Rate. Takes information from the csdr
% property to display data as image wherein the firing rate on each channel
% is shown in grey scale from 0 to FRMAX Hz. FRMAX is set to the maximal detected
% firing rate by default.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Feb 2, 2011
%       Last modified: Feb 2, 2011
% 	Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if isempty(SS.asdr)
    warning('You need to calculate the ASDR before calculating the CSDR');
    return;
end

if nargin < 2 || isempty(frmax)
    frmax = inf;
end

figure()
img = SS.csdr(:,2:end)';

% Create a color map that is good at displaying a wide range of data
cmp = gray(200);
cmp = flipud(cmp.^3);

% Smooth along each channel
for i = 1:size(img,1)
    img(i,:) = smooth(img(i,:),3);
end

if sum(sum(img > frmax)) > 0
    img(img > frmax ) = frmax;
elseif frmax ~= inf
    img(end) = frmax;
end

% Blur the image with a Gaussian Filter
q = imagesc(img);
c = colorbar();
ylabel(c,'Firing Rate (Hz)')
colormap(cmp);

% labels
xlabel('Time (sec)')
ylabel('Channel')
set(gca,'YDir','normal')
end
