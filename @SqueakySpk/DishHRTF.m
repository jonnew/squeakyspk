function [dh] = DishHRTF(SS,fs,pbloc,times,chind)
% function [dh] = DishHRTF(SS,fs,pbloc,times,chind)
% Stereo virtualization of point sources using HRTFs
% D = SS.raw: channels x time, input data, linearly indexed by row
% fs: sampling frequency
% pbloc: 'point-bot' location, where your head is in the network (mm from center)
% time: time range to analyze (sec)
% chind: channel index (1:64, ie this code only supports an 8x8 grid currently)
% dh.S: stereo signal, time x L,R
% dh.fs: sampling rate
% Written by: Nathan Killian 110214

if nargin < 5, chind=1:size(D,1);end
if nargin < 4, times =[0 10];end
if nargin < 3, pbloc = [0 0];end
if nargin < 2, fs    =   1e3;end
D = SS.raw;
% todo, for merging with NeuroSound
% chan = SS.channel(SS.clean);
% spktime = SS.time(SS.clean);

time = 0:1/fs:size(D,2)/fs;
tind = nearest(time,times(1)):nearest(time,times(2));
D = D(:,tind);

fs1 = fs;
fs2 = 44.1e3;
D2 = [];
for k = 1:size(D,1)
    % D2(k,:) = resample(D(k,:),fs2,fs1);
    D2(k,:) = interp(D(k,:),round(fs2/fs1));
end
D = D2;
D = D-repmat(nanmean(D,2),1,size(D,2));%remove mean from each channel
D = D./repmat(max(abs([max(D');min(D')]))',1,size(D,2));%normalize each channel from -1 to 1
scalebydist = 0; %option to scale inputs by distance
gridsize  = [8 8];center = [4.5 4.5];space = 0.2;% spatial params (mm)
tmp = ones(gridsize);dum = find(tmp);tmp(dum) = 1:prod(gridsize);
chans = tmp';%col to row-based linear
[I J] = find(chans);
xy = zeros([gridsize 2]);
for k = 1:length(I)
    xy(I(k),J(k),:) = [(J(k)-center(2))*space -(I(k)-center(1))*space]; %x,y value
end
% convert to 'single column' format
chans2 = reshape(chans',numel(chans),1);
xy2(:,1) = reshape(xy(:,:,1)',numel(chans),1);
xy2(:,2) = reshape(xy(:,:,2)',numel(chans),1);
xy0 = xy;
chans = chans2(chind,1);xy = xy2(chind,:);

% polar values, not necessary
% rtlocs(:,:,1) = sqrt(xylocs(:,:,1).^2+xylocs(:,:,2).^2);% radius
% rtlocs(:,:,2) = atan2

%%
pbloc = [0 0];% point-bot location = location of your head in the dish, in mm
% azim is degrees to the right (and left after abs(.)) of heading/artificial due North (0-180 degrees)
% -->wrap at 180 and take abs(.)
% e.g. if actual is b/w 0 and 360, deg_new = 360-actual
heading = 0;%heading = your head's angle deviation from 90deg/North, counter-clockwise

%todo: movement trajectories
% pts = [1 8 64 57 1];
% locs = xy0(pts,:);
% numeach = floor(size(D,2)/length(pts-1));
% traj = [];
% for k = 1:length(pts)-1
% xyt = [xyt [linspace(locs(k,1),locs(k+1,1),numeach);linspace(locs(k,2),locs(k+1,2),numeach)]];
% end
% get azim and dist to all sources
% get HRTFs for all locations
nhrtf = 512; %number of points in the HRTFs
L = zeros(nhrtf,length(chans));R = L;
% azimuth is ultimately specified as degrees clockwise from straight-ahead (+'ve is toward the right)
% ie using head-based, not sound-based indexing
% this has been accounted for in the code here to make sense
azim = zeros(1,length(chans));% degrees counter-clockwise from straight-ahead
dist = azim;elev = dist;
% snipi = 1;S=[];
% need to mark when to change positions, 
% perhaps you can write a function to specify position over time
% and then get out the interpolated hrtfs so you have a continuously changing hrtf of 
% strung together impulse responses?
% OR, take all impulse responses, and calculate all results, and interpolate/stich the results?
% for kk = 1:numsnips
for k = 1:length(chans)
    elev(k) = 0;
    dist(k) = sqrt((xy(k,1)-pbloc(1))^2+(xy(k,2)-pbloc(2))^2);
    %get azimuth using normal counter-clockwise orientation
    azim(k) = wrapTo180(round((atan2(xy(k,2)-pbloc(2),xy(k,1)-pbloc(1))*180/pi-90-heading)/5)*5);
    if azim(k) <0 % right hemisphere of head
        h = readhrtf(elev(k),abs(azim(k)),'L');   %   assume 'L' ear is symmetric
        L(:,k) = h(1,:)';        R(:,k) = h(2,:)';
    else % left hemisphere of head
        h = readhrtf(elev(k),abs(azim(k)),'L');
        L(:,k) = h(2,:)';        R(:,k) = h(1,:)';
    end
    if scalebydist
        L(:,k) = L(:,k)/dist(k);R(:,k) = R(:,k)/dist(k);
    end
end
%% filter data from each channel with L and R HRTFs for each channel and superpose
dl = zeros(size(D,1),size(D,2)+nhrtf-1);
dr = zeros(size(D,1),size(D,2)+nhrtf-1);
for k = 1:length(chans)
    d = D(k,:);
    dl(k,:) = conv(d,L(:,k)');
    dr(k,:) = conv(d,R(:,k)');
end
% S = [S; nanmean(dl(:,nhrtf:end-nhrtf+1),1)' nanmean(dr(:,nhrtf:end-nhrtf+1),1)'];
S = [nanmean(dl(:,nhrtf:end-nhrtf+1),1)' nanmean(dr(:,nhrtf:end-nhrtf+1),1)'];
% snipi = snipi + 1;
% end
%%
soundsc(S,fs2);
% wavwrite(S,fs2,'hrtf_test_center.wav')

dh.S = S;
dh.fs = fs2;
