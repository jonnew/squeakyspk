function h = ASDR(SS,dt,bound,whichchan,loglin,ymax,returnplot)
% ASDR(SS) Array-wide spike detection rate using bins of width 1 second. 
% The function populates the asdr and csdr properties of the SS object.
% This analysis is only performed on clean spikes.
% 
%   SS.csdr.chan is an (MX1) vector describing the channels used to make
%   the csdr and the asdr. This defines the word 'array' in array-wide
%   spike detection rate
%   SS.csdr.bin is an (NX1) vector of time bins used to calculate the asdr.
%   SS.csdr.bin is an (NXM) matrix with the counts for individual
%   electrodes down the columns.
% 
%   SS.asdr.bin is an (NX1) vector of time bins used to calculate the asdr.
%   SS.asdr.asdr is an (NX1) vector of histogram counts where each of the N
%   indices correspond to a bin value. asdr is vector of corresponding
%   firing rates over all electrodes.
%   SS.asdr.mean is a scalar value representing the mean of asdr.asdr
%   SS.asdr.median is a scalar value representing the median of asdr.asdr
%   SS.asdr.var is a scalar value representing the variance of asdr.asdr
%   SS.asdr.skew is a scalar value representing the skewness of asdr.asdr
%   SS.asdr.kurt is a scalar value representing the kurtosis of asdr.asdr
% 
% ASDR(SS,dt,bound,whichchan) Allows the user to define a specific bin size DT,in
% seconds and a range BOUND = [t0 t1] over which the asdr is calculated.
% This is reflected in the bin fields of the asdr and csdr matracies.
% WHICHCHAN is a vector of channel numbers that are used to calcuate the
% csdr and asdr. This defines the 'array'. The default value for WHICHCHAN
% = unique(SS.channel).
% 
% ASDR(SS,...,loglin,ymax,returnplot) Allows the user to define aspects of the 
% ASDR figure. If loglin is set to false, then the plot returned by ASDR will have
% linear axes. ymax forces the maximal value of the ordinate axis.
% returnplot is a boolean value determining if a figure should be created
% and its handle returned by the function. Default values for these
% parameters are true, auto, and true, respectively.
% 
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Feb 2, 2011
%       Last modified: Feb 2, 2011
%       Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt


if nargin < 7 || isempty(returnplot)
    returnplot = 1;
end
if nargin < 6 || isempty(ymax)
    ymax = 'auto';
end
if nargin < 5 || isempty(loglin)
    loglin = 0;
end
if nargin < 4 || isempty(whichchan)
    whichchan = unique(SS.channel);
end
if nargin < 2 || isempty(dt)
    dt = 1; %seconds
end
if nargin < 3 || isempty(bound)
    bound = [0 SS.time(end) + dt];
end

dat = SS.ReturnClean;

% Define the array
SS.csdr.chan = whichchan;

% Calculate the csdr matrix
bins = bound(1):dt:bound(2);
SS.csdr.csdr = zeros(length(bins),length(whichchan));
SS.csdr.bin = bins';
for i = 1:length(whichchan)
    times  = dat.time(dat.time >= bound(1) & dat.time <= bound(2));
    ch = dat.channel(dat.time >= bound(1) & dat.time <= bound(2));
    asdr_tmp = hist(times(ch == whichchan(i)),bins);
    if size(asdr_tmp,2) == 1;
        SS.csdr.csdr(:,i) = asdr_tmp./dt;
    else
        SS.csdr.csdr(:,i) = asdr_tmp'./dt;
    end
end

% Calculate ASDR
SS.asdr.bin = bins';
SS.asdr.asdr = sum(SS.csdr.csdr(:,2:end),2);
SS.asdr.mean = mean(SS.asdr.asdr);
SS.asdr.median = median(SS.asdr.asdr);
SS.asdr.var = var(SS.asdr.asdr);
SS.asdr.skew = skewness(SS.asdr.asdr,0);
SS.asdr.kurt = kurtosis(SS.asdr.asdr,0);

% Plot results
if(returnplot)
    h = figure();
    if loglin
        asdrp_b = SS.asdr.bin(SS.asdr.asdr > 0,:);
        asdrp_a = SS.asdr.asdr(SS.asdr.asdr > 0,:);
        semilogy(asdrp_b, asdrp_a, 'k');
        if ~strcmp(ymax,'auto')            
            ylim([1 ymax])
        end
    else
        plot(SS.asdr.bin,SS.asdr.asdr,'k');
    end
    xlabel('Time (sec)')
    ylabel('s^-1')
end

end