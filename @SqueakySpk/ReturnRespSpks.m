function spktrains = ReturnRespSpks(SS, spike, stim, ...
                channelpair, rez, varargin)
%RETURNRESPSPKS returns response spike trains
%   SPKTRAINS = RETURNRESPSPKS(SS, spike, stim, channelpair, rez, 
%   varargin) 
%   returns a matrix of spike trains of channel channelpair(2) in 
%   response to stimulation of channel channelpair(1).

    %default to SS.afpars resprange field, or set to user-defined
    %value if given
    resprange = SS.afpars.resprange;
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
        spikes = SS.RSIR(spks, stims(x), resprange)*1000*rez;
        spktrains(x, :) = hist(spikes, ...
            .5:1:bins-.5);
    end
end