function catmat = CAT(SS,trange, movtimebin, timewindow, bmode,varargin)
%CAT creates calculated the center of activity trajectory
%   CATMAT = CAT(SS, TRANGE, MOVTIMEBIN, TIMEWINDOW, BMODE) calculates
%   the center of activity every MOVTIMEBIN seconds for TIMEWINDOW seconds,
%   BMODE is a logical which indicates whether to set the center of
%   activity (CA) at [0 0] or to set the CA to the previous CA when there
%   are no spikes within a timewindow seconds.
%   CATMAT is an N x 2 matrix of
%   center of activities, where N is TRANGE(2)-TRANGE(1) / MOVTIMEBIN
%   Calculates center of activity every movtimebin seconds for
%   timewindow seconds

    if nargin >= 6
        
        [trange, ~, spktype, ~, channels] = ...
            SS.ReturnAnalysisPars(0,varargin);
    else
       SS.analysispars;
        [~, ~, spktype, ~, channels] = ...
            SS.ReturnAnalysisPars(0,SS.analysispars);
    end
    
    
    if nargin<5
        bmode = 1;
    end
    if nargin<4
        timewindow = 50e-3;
    end
    if nargin<3
        movtimebin = 5e-3;
    end
    if nargin<2
        trange = [min(SS.time) max(SS.time)];
    end
    
    %gets spike and stim data and slices to trange
    [spike stim] = SS.ReturnRangedData(trange, spktype);
    
    %main catmat vector. subvectors are copied into this
    
    catmat = zeros((trange(2)-trange(1))/movtimebin+1, 2);
    
   % catmat(1, :) = [4.5 4.5];
   
    
    cmind = 2; %catmat index  
    t = (0:movtimebin:(trange(2)-trange(1)))+movtimebin/2;
   h = zeros(length(t),64);
   map =zeros(64,2);
   
    for i = 1:60
        h(:,i) = hist(spike.time(spike.channel ==(i-1))-trange(1),t);
        map(i,2) = (ceil(i/8))-4.5;%mod(hw2crd(i),10)-4.5;%
        map(i,1) = (mod(i-1, 8)+1)-4.5;%ROW=mod(CR,10);%floor((hw2crd(i))/10) -4.5;%
            %COL=(CR-ROW)/10;
    end
   % map
%     size(h*map)
%     size(sum(h,2))
%     size(h)
hi = sum(h,2);
hi(hi==0) = ones(sum(hi==0),1);
    hi2 = [hi hi];
    cat = h*map./hi2;
    %figure;plot(cat);
    %cat = cat./hi2;
    %figure;plot(cat);
    %size(cat)
    %figure;plot(cat(:,1));hold on;plot(cat(:,2),'r');
    %catmat = cat;
    mask = ones(ceil(timewindow/movtimebin),1)./(ceil(timewindow/movtimebin));
    catmat = convn(cat,mask);
    %catmat = catmat+ones(size(catmat))*4.5;
%     for x=trange(1):movtimebin:trange(2)-timewindow
%         %get channels in timewindow
%         a = find(spike.time >= x, 1);
%         b = find(spike.time < x+timewindow, 1, 'last');
%         binc = spike.channel(a:b);
%         
%         
%             %if there are no spikes, set CA to either center of dish, 4.5 4.5,
%             %or to previous CA
%             if sum(binc) == 0
%                 if bmode
%                     catmat(cmind, :) = [4.5 4.5];
%                 else
%                     catmat(cmind, :) = catmat(cmind-1, :);
%                 end
%             else
%                 catmat(cmind, :) = [sum(ceil(binc/8)) ...
%                         sum(mod(binc-1, 8)+1)] / length(binc);
%             end
%             
%         
%         cmind = cmind + 1;
%     end
    %size(catmat)
    %catmat = catmat(2:cmind-1, :);
end

