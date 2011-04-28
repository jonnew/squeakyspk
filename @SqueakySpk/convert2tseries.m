function tseries = convert2tseries(spikes, alength)
%CONVERT2TSERIES converts an array of spike times into tseries
%   SPIKES is an array of spike times in seconds
%   ALENGTH is length of tseries
%   TSERIES is an array of length ALENGTH which is created by sorting
%   spikes into a specific 'time bin', a length of time that is
%   calculated by dividing the length of TSERIES by the max time in
%   SPIKES. 

if isempty(spikes)
    tseries = zeros(1, alength);
    return;
end

tseries = zeros(1, alength);
spikes = spikes-min(spikes);
binsize = max(spikes) / alength;
temp = floor(spikes/binsize)+1;

for x=1:length(temp)
    tseries(temp(x)) = tseries(temp(x)) + 1;
end

end

