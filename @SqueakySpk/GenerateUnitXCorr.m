function GenerateUnitXCorr(SS,bound,dt,maxlag,units,useGPU,showplot)
% GENERATEUNITXCORR(SS) Generate the unit-unit firing cross correlation
% matrix and plot the average unit-unit cross correlation function. This
% method modifies the SS.unit_xc property, which contains
%
% SS.unit_xc.lags:   (LX1) vector of lags for which the correlation
%                    function is calculated in seconds 
% SS.unit_xc.xc:     (NXL) matrix containing N = [n*(n-1)]/2 correlation 
                     funtions from n units.
% SS.unit_xc.uxc:    (LX1) vector containging the average cross-correlation
%                    function
% SS.unit_xc.combos: (NX2) vector containing the N = [n*(n-1)]/2 combinations
%                    of n units used to produce the cross correlation functions
%
% GENERATEUNITXCORR(SS,bound,dt,maxlag,units) Calculates the
% cross-correlation matrix using data bounded within the time domain
% defined by the 2-element vector, BOUND = [t0 t1], using time-granularity
% DT seconds over a maximal lag of MAXLAG seconds for the units present in
% the nX1 dimensional vector UNITS.
% 
% GENERATEUNITXCORR(SS,...,useGPU,showplot) Provides the ability to
% calculate the cross correlation function using the GPU(if available).
% Setting SHOWPLOT to 1 will produce a plot of the average cross
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

if nargin < 3 || isempty(bound)
    dt = 0.01; % seconds
end

if nargin < 4 || isempty(bound)
    maxlag = 0.25; % seconds
end

if nargin < 5 || isempty(bound)
    units = unique(SS.unit);
end

if nargin < 6 || isempty(useGPU)
    useGPU = 0;
end

if nargin < 7 || isempty(showplot)
    showplot = 0;
end

% Check that spike sorting is done
if numel(unique(SS.unit)) < 2
    error('Spike sorting has not been performed, so the unit-unit XCorr function cannot be calculated.')
end

l = ceil(maxlag/dt); % samples in xcorr
t = 0:dt:diff(bound); % normalized time
combos = nchoosek(units,2); % unit pairs
SS.unit_xc.combos = combos;
XC =  zeros(length(combos),2*l+1);

for j=1:length(combos)
    
    % Get spike times for units in combo(j) that occured within the time bound
    b1 = SS.time > bound(1) & SS.time <= bound(2) & SS.unit == combos(j,1);
    b2 = SS.time > bound(1) & SS.time <= bound(2) & SS.unit == combos(j,2);
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

SS.unit_xc.xc = XC;
SS.unit_xc.uxc = uXC;
SS.unit_xc.lags = dt*lags;

% Plot the results
if showplot
    plot(dt*lags,sqrt(uXC),'k-');
    xlim([-maxlag maxlag])
    ylabel('Firing rate')
    xlabel('Lag (sec)')
end

end