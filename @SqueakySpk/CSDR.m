function q = CSDR(SS,frmax)
% CSDR(SS) Channel Spike Detection Rate. Takes information from the asdr
% property the SDR for each channel. Data is displayed as an image and the
% plot handle is returned.
%
% p = RandScat(SS) returns the plot handle.
%
% This function is ported from:
% matlab/randscat88.m: part of meabench, an MEA recording and analysis tool
% Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)

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