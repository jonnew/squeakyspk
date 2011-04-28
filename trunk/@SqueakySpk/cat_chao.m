function catmat = cat_chao(SS, movtimebin, timewindow, bmode, varargin)
%CAT_CHAO creates calculated the center of activity trajectory
%   CATMAT = CAT_CHAO(SS, TRANGE, MOVTIMEBIN, TIMEWINDOW, BMODE) calculates
%   the center of activity every MOVTIMEBIN seconds for TIMEWINDOW seconds,
%   BMODE is a logical which indicates whether to set the center of
%   activity (CA) at [0 0] or to set the CA to the previous CA when there
%   are no spikes within a timewindow seconds.
%   CATMAT is an N x 2 matrix of
%   center of activities, where N is TRANGE(2)-TRANGE(1) / MOVTIMEBIN
%   Calculates center of activity every movtimebin seconds for
%   timewindow seconds

    if nargin > 4
        [trange, ~, spktype, ~, channels] = ...
            SS.extractafpars(varargin{1}, 0);
    end
    
    %gets spike and stim data and slices to trange
    [spike stim] = SS.ReturnRanged(trange, spktype);
    
    %main catmat vector. subvectors are copied into this
    catmat = zeros((trange(2)-trange(1))/movtimebin+1, 2);
    catmat(1, :) = [4.5 4.5];
    
    
    cmind = 2; %catmat index   
    for x=trange(1):movtimebin:trange(2)-timewindow
        %get channels in timewindow
        a = find(spike.time >= x, 1);
        b = find(spike.time < x+timewindow, 1, 'last');
        binc = spike.channel(a:b);
        
        %if there are no spikes, set CA to either center of dish, 4.5 4.5,
        %or to previous CA
        if sum(binc) == 0
            if bmode
                catmat(cmind, :) = [4.5 4.5];
            else
                catmat(cmind, :) = catmat(cmind-1, :);
            end
        else
            catmat(cmind, :) = [sum(ceil(binc/8)) ...
                    sum(mod(binc-1, 8)+1)] / length(binc);
        end
        cmind = cmind + 1;
    end
    catmat = catmat(2:cmind-1, :);
end

