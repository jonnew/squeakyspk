function xcorrmat = CalcXCorr(SS, varargin)
%CALCXCORR calculates the cross correlation of spikes and stims
%   CALCXCORR(SS) calculates the cross correlation of SS.afpars.channelrels
%   channel pairs.
%   CALCXCORR(..., afpars) specifies the afpars struct. See
%   SS.extractafpars documentation for more info

    if nargin > 1
        [trange, rez, spktype, ~, channels] = ...
            SS.extractafpars(varargin{1}, 1);
    else
        [trange, rez, spktype, ~, channels] = ...
            SS.extractafpars(SS.afpars, 1);
    end
    
    %get ranged data
    [spike stim] = SS.ReturnRanged(trange, spktype);
    
    csize = size(channels, 1);

    %main calc loops
    %figure out which stim and spike tseries need to be loaded
    stimlist = [];
    spikelist = [];
    
    stimhist = zeros(csize, (trange(2)-trange(1))*1000*rez);
    spikehist = zeros(csize, (trange(2)-trange(1))*1000*rez);
    
    %make cross correlation matrix
    xcorrmat = zeros(csize, size(stimhist, 2)*2-1);
    
    histbins = .5:1:(size(stimhist, 2)-.5);
    
    disp('sorting spikes and stims');
    for x=1:csize
        if channels(x, 3) == 0
            spikelist = [spikelist channels(x, 1) channels(x, 2)];
        elseif channels(x, 3) == 1
            spikelist = [spikelist channels(x, 1)];
            stimlist = [stimlist channels(x, 2)];
        elseif channels(x, 3) == 2
            spikelist = [spikelist channels(x, 2)];
            stimlist = [stimlist channels(x, 1)];
        else
            error('Invalid channel combination');
        end
    end
    
    spikelist = unique(spikelist);
    stimlist = unique(stimlist);
    
    parfor x=1:length(spikelist)
        spikehist(x, :) = hist(spike.time(spike.channel == spikelist(x))*1000*rez, histbins);
    end
 
    parfor x=1:length(stimlist)
        stimhist(x, :) = hist(stim.time(stim.channel == stimlist(x))*1000*rez, histbins);
    end
    
    %calculate xcorrs
    disp('calculating xcorrs')
    parfor x=1:csize
        if channels(x, 3) == 0
            xcorrmat(x, :) = xcorr(spikehist(spikelist == channels(x, 1), :), spikehist(spikelist == channels(x, 2), :));
        elseif channels(x, 3) == 1
            xcorrmat(x, :) = xcorr(spikehist(spikelist == channels(x, 1), :), stimhist(stimlist == channels(x, 2), :));
        elseif channels(x, 3) == 2
            xcorrmat(x, :) = xcorr(stimhist(stimlist == channels(x, 1), :), spikehist(spikelist == channels(x, 2), :));
        else 
            error('Invalid channel combination');
        end
    end
end