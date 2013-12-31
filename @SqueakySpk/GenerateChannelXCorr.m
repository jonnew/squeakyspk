function GenerateChannelXCorr(SS,bound,dt,maxlag,channels,useGPU,showplot)
% GENERATECHANNELXCORR(SS) Generate the channel-channel firing cross correlation
% matrix and plot the average channel-channel cross correlation function. This
% method modifies the SS.chan_xc property, which contains
%
% SS.chan_xc.lags:  (LX1) vector of lags for which the correlation
%                   function is calculated in seconds 
% SS.chan_xc.xc:    (NXL) matrix 
%                   containing N = n*(n-1)/2 correlation funtions from n channels.
% SS.chan_xc.uxc:   (LX1) vector containging the average cross-correlation
%                   function
% SS.chan_xc.combos: (NX2) vector containing the N = n*(n-1)/2 combinations
%                    of n channels used to produce the cross correlation functions
%
% GENERATECHANNELXCORR(SS,bound,dt,maxlag,units) Calculates the
% cross-correlation matrix using data bounded within the time domain
% defined by the 2-element vector, BOUND = [t0 t1], using time-granularity
% DT seconds over a maximal lag of MAXLAG seconds for the units present in
% the nX1 dimensional vector UNITS.
% 
% GENERATECHANNELXCORR(SS,...,useGPU,showplot) Provides the ability to
% calculate the cross correlation function using the GPU (if available).
% Seetting SHOWPLOT to 1 will produce a plot of the average cross
% correlation function upon completion of the calculation.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: June 2, 2013
%       Last modified: June 2, 2013
%       Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if nargin < 2 || isempty(bound)
    bound = [min(SS.time) max(SS.time)];
end

if nargin < 3 || isempty(dt)
    dt = 0.01; % seconds
end

if nargin < 4 || isempty(maxlag)
    maxlag = 0.25; % seconds
end

if nargin < 5 || isempty(channels)
    channels = unique(SS.channel);
end

if nargin < 6 || isempty(useGPU)
    useGPU = 0;
end

if nargin < 7 || isempty(showplot)
    showplot = 0;
end


l = ceil(maxlag/dt); % samples in xcorr
t = 0:dt:diff(bound); % normalized time
combos = nchoosek(channels,2); % unit pairs
SS.chan_xc.combos = combos;
XC =  zeros(length(combos),2*l+1);

for j=1:length(combos)
    
    % Get spike times for units in combo(j) that occured within the time bound
    b1 = SS.time > bound(1) & SS.time <= bound(2) & SS.channel == combos(j,1);
    b2 = SS.time > bound(1) & SS.time <= bound(2) & SS.channel == combos(j,2);
    S1t = hist(SS.time(b1)-bound(1),t);
    S2t = hist(SS.time(b2)-bound(1),t);
    
    if sum(S1t) > 0 && sum(S2t) > 0
        if ~useGPU
            [XC(j,:), lags] = xcorr(S1t/dt,S2t/dt,l,'unbiased');
        else
            X1 = gpuArray(S1t/dt);
            X2 = gpuArray(S2t/dt);
            [xc, lags] = xcorr(X1,X2,l,'unbiased');
            XC(j,:) = gather(xc);
        end
    end
end
XC(XC<0) = 0;
uXC = nanmean(XC);

SS.chan_xc.xc = XC;
SS.chan_xc.uxc = uXC;
SS.chan_xc.lags = dt*lags;

% Plot the results
if showplot
    plot(dt*lags,sqrt(uXC),'k-');
    xlim([-maxlag maxlag])
    ylabel('Firing rate')
    xlabel('Lag (sec)')
end

end