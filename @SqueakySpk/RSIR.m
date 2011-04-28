function spks = RSIR(SS, spikes, stim, resprange)
    %SPKS = RSIR(SS, SPIKES, STIM, RESPRANGE) returns all spikes in
    %the vector SPIKES whose times are greater than STIM and less 
    %than or equal to STIM + RESPRANGE. RESPRANGE is in sec. All 
    %times in SPKS will be less than or equal to RESPRANGE.
    %RSIR = return spikes in range

    %utilizes faster logical indexing
    a = find(spikes > stim, 1);
    b = find(spikes <= stim + resprange, 1, 'last');
    spks = spikes(a:b) - stim;
end