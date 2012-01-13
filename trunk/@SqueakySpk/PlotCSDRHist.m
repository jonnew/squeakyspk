function PlotCSDRHist(SS,binsize,maxdr)
% PLOTCSDRHIST(SS,BINSIZE, MAXDR) plots the Channel Spike Detection Rate histogram.
% Takes information from the csdr property to display the detection rate
% counts for each channel and across all channels. For the first plot, the
% count for a paticular detection rate is a color from a grey scale. For
% the second plot, the combined histogram is shown. BINSIZE is the
% detection rate increment for one histogram bin. The default is 10 Hz.
% MAXDR is the maximal detection rate considered in the histogram. Default
% is 1000 Hz.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: April 25, 2011
%       Last modified: April 25, 2011
% 
% 	Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if isempty(SS.asdr)
    warning('You need to calculate the ASDR before plotting the CSDR histogram');
    return;
end

if nargin < 3 || isempty(maxdr)
    maxdr = 500;
end
if nargin < 2 || isempty(binsize)
    binsize = 10;
end

figure()
X = SS.csdr.csdr(:,2:end)';
totaltime = SS.csdr.bin(end,1); % in seconds

% Create a color map that is good at displaying a wide range of data
cmp = gray(200);
cmp = flipud(cmp);

% Caclulate histogram
[h b] = hist(X',0:binsize:maxdr);
h = h/totaltime/length(unique(SS.channel(SS.clean)));
htot = sum(h,2);
h(1,:) = zeros(size(h(1,:))); % get ride of 0 response since it ruins scaling

% Make the image
subplot(122)
imagesc(h');
ylabel('Channel #')
xlabel('Detection Rate (Hz)')
xt = str2num(get(gca,'XTickLabel'));
tl = b(ceil(length(b)*(xt./max(xt))));
set(gca,'XTickLabel',tl);
c = colorbar();
ylabel(c,'P[Det. Rate]')
colormap(cmp);
set(gca,'YDir','normal')
title('Per-channel Detection Dists.')

subplot(121)
stairs(b,htot,'-k','LineWidth',2);
xlabel('Detection Rate (Hz)')
ylabel('P[Det. Rate]')
title('Array-Wide Detection Dist.')
ylim([0 1])

end
