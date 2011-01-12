function tseries = convert2tseries(spikes, rez)
%CONVERT2TSERIES converts an array of spike times into tseries
%   SPIKES is an array of spike times in seconds
%   REZ is resolution of array in ms
%   TSERIES is an array of length ALENGTH which is created by sorting
%   spikes into a specific 'time bin', which is a length of time that is
%   calculated by dividing the length of TSERIES by the max time in
%   SPIKES. 

if isempty(spikes)
    tseries = zeros(1);
    return;
end
s = max(spikes);
tseries = zeros(1, floor(s*1000/rez)+1);

temp = floor(spikes*1000/rez)+1;
for x=1:length(temp)
    tseries(temp(x)) = tseries(temp(x)) + 1;
end

end

