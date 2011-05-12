function spktrains = ReturnPeriStimSpkTrains(SS, spike, stim, ...
                channelpair, rez, varargin)
%RETURNSPKTRAINS returns spike trains
%   SPKTRAINS = RETURNSPKTRAINS(SS, spike, stim, channelpair, rez, 
%   varargin)
%   returns a matrix of spike trains of channel channelpair(2) in 
%   response to stimulation of channel channelpair(1).
%   SPKTRAINS is an NxM matrix of N stimulations and of length M

    %default to SS.analysispars resprange field, or set to user-defined
    %value if given
    
    resprange = SS.analysispars.resprange;
    if nargin > 5 && ~isempty(varargin{1})
        resprange = varargin{1};
    end

    %get stims, spikes, number of bins, and initialize spktrains
    stims = stim.time(stim.channel == channelpair(1));
    spks = spike.time(spike.channel == channelpair(2));
    bins = resprange*1000*rez;
    spktrains = zeros(length(stims), bins);

    %get spikes within resprange, create histogram for each
    %spike train
    for x=1:length(stims)
        spikes = return_spksinrange(spks, stims(x), resprange)*1000*rez;
        spktrains(x, :) = hist(spikes, ...
            .5:1:bins-.5);
    end
end
function spks = return_spksinrange(SS, spikes, stim, resprange)
    %SPKS = ReturnSpksInRange(SS, SPIKES, STIM, RESPRANGE) returns all spikes in
    %the vector SPIKES whose times are greater than STIM and less 
    %than or equal to STIM + RESPRANGE. RESPRANGE is in sec. All 
    %times in SPKS will be less than or equal to RESPRANGE.

    %utilizes faster logical indexing
    a = find(spikes > stim, 1);
    b = find(spikes <= stim + resprange, 1, 'last');
    spks = spikes(a:b) - stim;
end