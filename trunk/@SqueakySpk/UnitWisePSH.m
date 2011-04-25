function UnitWisePSH(SS,dt,histrange,whichstim,whichunit,effrange,ploton)
%UNITWISEPSH create the UPSH for an SS object.
%
%   	PERISTIMTIMEHISTOGRAM(SS,DT,HISTRANGE,WHICHSTIM,
%   	WHICHUNIT,EFFRANGE,PLOTON) calculates the peristimulus histogram
%   	with time resolution DT (msec) for a time window around the
%   	conditioning stimulus event defined by HISTRANGE = [t1 t2] in
%   	milliseconds.
% 
%       WHICHSTIM is a logical array withdimesions equal to SS.st_time,
%       defining which stimuli the PSH should be calculated for. The
%       default value is WHICHSTIM = true(size(SS.st_time)).
%
%       WHICHUNIT is an integer array equal to size(unique(SS.unit)),
%       defining which units the PSH should be calculated for. The default value
%       is WHICHUNIT = unique(SS.unit)
% 
%       The UPSH is caculated for each unit and stored in the [M X N]
%       matrix psh.hist which reprsents the M sample long psh for each of N
%       units. PLOTON is a logical that controls whether or not the PSH
%       is plotted after the comptuation has finished.
% 
%       The algorithm then sorts the upsh.unit and upsh.hist matrix based
%       on stimulus efficacy and creates a new field, upsh.eff which stores
%       the efficacy measures. Efficacy is determined by integrating the
%       the unit-wise psh for the first EFFRANGE (milliseconds) and then
%       sorting by this value in increasing order. This is identical to the
%       definition employed in:
% 
%       Wagenaar, DA et al Effective parameters for stimulation
%       of dissociated cultures using multi-electrode arrays J. Neurosci Meth,
%       2004
%
%       Finally, the peak average response value and latency, in seconds,
%       is stored in upsh.peak which is a [2 X N] matrix, the first row
%       being latencies, the second being the peak average response.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu) Location: The
%       Georgia Institute of Technology 
%       Created on: April 24, 2011 
%       Last modified: April 24, 2011
%
%       Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

% check number and whichstim of arguments
if isempty(SS.unit) || length(SS.unit) ~= length(SS.time)
    warning(['You have not performed spike sorting yet or the unit property is not correctly populated.', ...
        ' Exiting UNITWISEPSH.']);
    return;
end

if nargin < 7 || isempty(ploton)
    ploton = 1; % Whole recording
end
if nargin < 6 || isempty(effrange)
    effrange = 20; %  msec, as in paper above.
end
if nargin < 5 || isempty(whichunit)
    whichunit = unique(SS.unit); % All units
end
if nargin < 4 || isempty(whichstim)
    whichstim = true(size(SS.st_time)); % All stimuli
end
if nargin < 3 || isempty(histrange)
    histrange = [-100 500]; % Default range of histogram (msec)
end
if nargin < 2 || isempty(dt)
    dt = 1; % Default time resolution of 5 msec
end
if nargin < 1
    error('Need to act on SqueakSpk Object');
end

% Make sure the data actual has stimulation entries
if isempty(SS.st_time)
    warning(['You must provide stimulus timing information to form a' , ...
        ' peristimulus histogram. Exiting UNITWISEPSH.']);
    return;
end

% Make sure the histogram bounds are correct
if histrange(1) > histrange(2)
    error('histrange(1) must be less than histrange(2)');
end

% convert to seconds
b = histrange/1000; dtsec = dt/1000;
numunit = max(size(whichunit));
goodtime = SS.st_time(whichstim);

upsh.t = b(1):dtsec:b(2);
upsh.unitcount = numunit;
upsh.stmcount = sum(whichstim);
upsh.unit = zeros(numunit,1);
upsh.hist = zeros(length(upsh.t),numunit);
upsh.std = zeros(size(upsh.hist));

% Start
disp('Calculating Peri-stimulus histogram ...')

% perform only on clean spks
dat = SS.ReturnClean();

% modify clean data to use only selected units
goodunit = ismember(dat.unit, whichunit);
upsh.unit = whichunit;
dat.unit  = dat.unit(goodunit);
dat.time  = dat.time(goodunit);

% caculate the PSH for each stim
for i = 1:sum(whichstim)
    t1 = b(1) + goodtime(i);
    t2 = b(2) + goodtime(i);
    
    % parse out the response from all the data
    inwindow = dat.time >= (t1-dtsec) & dat.time <= (t2+dtsec);
    spks = dat.time(inwindow);
    unt = dat.unit(inwindow);
    
    % Create the response matrix
    if ~isempty(spks)
        R = (b(1)-1)*ones(length(spks),numunit);
        for j = 1:numunit
            uspk = spks(unt == whichunit(j));
            if ~isempty(uspk)
                R(1:length(uspk),j) = uspk;
            end
        end
        
        % Histogram of response
        if size(R,1) ~= 1
            count = hist(R-goodtime(i),[upsh.t(1)-1 upsh.t]);
        else
            for k = 1:length(R)
                count = [];
                count(:,k) = hist(R(k)-goodtime(i),[upsh.t(1)-dt upsh.t]);
            end
        end
        
        % Get rid of leading edge since this junk from R
        count = count(2:end,:);
        
        % update PSH estimates
        upsh.hist = upsh.hist + count;
        upsh.std = upsh.std + count.^2;
    end
   
end

% Calculate RMS and normalize everything to firing rate
upsh.std = sqrt(upsh.std/upsh.stmcount)/dtsec;
SS.upsh.hist = upsh.hist/upsh.stmcount/dtsec;

% calculate efficacy
eff = sum(upsh.hist(upsh.t>0 & upsh.t<=effrange/1000,:),1);
[eff idx] = sort(eff);

% sort the whole thing based on efficacy
upsh.unit = upsh.unit(idx);
upsh.hist = upsh.hist(:,idx);
upsh.std = upsh.std(:,idx);
upsh.eff = eff;

% calculate peaks and latencies
[maxh idx] = max(upsh.hist,[],1);
peaklat = upsh.t(idx);
upsh.peak = [peaklat ; maxh];

% Save the psh
SS.upsh = upsh;

% Finish
disp('Finished calculating Peri-stimulus histogram.')

% Plot if the user wants it
if ploton
   SS.PlotUnitWisePSH(200);
end

% Add psh to method log
SS.methodlog = [SS.methodlog '<UnitWisePSH>'];

end

