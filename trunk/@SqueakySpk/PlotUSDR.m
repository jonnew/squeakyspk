function PlotUSDR(SS,frmax,sortu,sortbound)
% PlotUSDR(SS,FRMA,SORTBOUND)Plots the Unit Spike Detection Rate. Takes
% information from the usdr property to display data as image wherein the
% firing rate for each unit is shown in grey scale from 0 to FRMAX Hz.
% FRMAX is set to the maximal detected firing rate by default. SORTBOUND
% defines the region, in time, over which to calculate indivudual unit
% firing rates such that the resulting figure shows units in order of
% descending firing rate.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Feb 2, 2011
%       Last modified: Feb 2, 2011
% 	Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if isempty(SS.asdr)
    warning('You need to calculate the ASDR before plotting the USDR');
    return;
end

if nargin < 4 || isempty(sortbound)
    sortbound = [0 SS.time(end)];
end
if nargin < 3 || isempty(sortu)
    sortu = 1;
end
if nargin < 2 || isempty(frmax)
    frmax = inf;
end

img = SS.usdr.usdr';

% sort the image by integrated unit firing rate?
if sortu
    imgt = SS.usdr.usdr(SS.usdr.bin >= sortbound(1) & SS.usdr.bin < sortbound(2),:)';
    int = sum(imgt,2);
    [x ind] = sort(int);
    img = img(ind,:);
end

% Create a color map that is good at displaying a wide range of data
cmp = gray(200);
cmp = flipud(cmp.^3);

% set FR max by setting a single pixel to this value and then using imagesc
if sum(sum(img > frmax)) > 0
    img(img > frmax ) = frmax;
elseif frmax ~= inf
    img(end) = frmax;
end

% Make the image
imagesc(img);
c = colorbar('Location','EastOutside');
ylabel(c,'Firing Rate (Hz)')
colormap(cmp);

% label
xtickval = get(gca,'XTick');
xticktime = xtickval * SS.asdr.dt;
set(gca,'XTickLabel', num2str(xticktime'));
set(gca,'YTick',[1 size(img,1)]);
xlabel('Time (sec)')
ylabel('Unit #')
set(gca,'YDir','normal')
end
