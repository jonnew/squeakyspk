function q = UnitWisePSH(SS,dt,histrange,whichstim,which,effrange,forcechan,ploton)
%UNITWISEPSH create the UPSH for an SS object.
%
%   	UNITWISEPSH(SS,DT,HISTRANGE,WHICHSTIM,WHICH,EFFRANGE,FORCECHAN,PLOTON)
%       calculates the peristimulus histogram with time resolution DT (msec)
%       for a time window around the conditioning stimulus event defined by
%       HISTRANGE = [t1 t2] in milliseconds for each unit or channel in the
%       specified.
%
%       WHICHSTIM is a logical array withdimesions equal to SS.st_time,
%       defining which stimuli the PSH should be calculated for. The
%       default value is WHICHSTIM = true(size(SS.st_time)).
%
%       WHICH is an integer array, defining which units or channels the
%       PSH should be calculated for. The default value is WHICH =
%       unique(SS.unit) if spike sorting has been performed and WHICH =
%       unique(SS.channel), otherwise.
%
%       The UPSH is caculated for each unit/channel and stored in the [M X
%       N] matrix psh.hist which represents the M sample long psh for each
%       of N units/channels. PLOTON is a logical that controls whether or
%       not the PSH is plotted after the comptuation has finished.
%
%       The algorithm then sorts the upsh.which and upsh.hist matrix based
%       on stimulus efficacy and creates a new field, upsh.eff which stores
%       the efficacy measures. Efficacy is determined by integrating the
%       the unit-wise psh for the first EFFRANGE (milliseconds) and then
%       sorting by this value in increasing order. This is identical to the
%       definition employed in:
%
%       Wagenaar, DA et al Effective parameters for stimulation of
%       dissociated cultures using multi-electrode arrays J. Neurosci Meth,
%       2004
%
%       Finally, the peak average response value and latency, in seconds,
%       is stored in upsh.peak which is a [2 X N] matrix, the first row
%       being latencies, the second being the peak average response.
%
%       FORCECHAN forces the UNITWISEPSH  to be calculated over channels
%       instead of units, even if sorting has been performed.
%
%       This fucntion popopulates the UPSH property of the current SS
%       object, SS.upsh. This has the following fielDs:
%
%       upsh.type = 'unit-wise' or 'channel-wise'
%       upsh.stimcount = number of stimuli used to calculate the upsh
%       upsh.which or upsh.channel = the N units or channels defined in WHICH
%       upsh.t = the bins used to calculate the upsh
%       upsh.psh.hist = M sample long psh for each of N units/channels
%       upsh.psh.std = M sample long rms of the psh for each of N units/channels
%       upsh.psh.eff = The efficacy measure for each of the N unit/channel
%       upsh.psh.peak.lat = latency to the peak mean psh for each unit/channel
%       upsh.psh.peak.peak = peak mean psh for each unit/channel
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu) Location: The
%       Georgia Institute of Technology
%       Created on: April 24, 2011
%       Last modified: April 24, 2011
%
%       Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if nargin < 8 || isempty(ploton)
    ploton = 1; % Whole recording
end
if nargin < 7 || isempty(forcechan)
    forcechan = 0; % Whole recording
end
if nargin < 6 || isempty(effrange)
    effrange = 20; %  msec, as in paper above.
end
if nargin < 5 || isempty(which)
    if ~forcechan
        which = unique(SS.unit); % All units
    else
        which = unique(SS.channel); % All channels
    end
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

% check number and whichstim of arguments
if ~forcechan && (isempty(SS.unit) || length(SS.unit) ~= length(SS.time))
    warning(['You have not performed spike sorting yet or the unit property is not correctly populated.', ...
        ' performing the unitwisepsh across channels']);
    forcechan = true;
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
numunit = max(size(which));
goodtime = SS.st_time(whichstim);

% make storage
if ~forcechan
    upsh.type = 'unit-wise';
else
    upsh.type = 'channel-wise';
end
upsh.t = b(1):dtsec:b(2);

upsh.stmcount = sum(whichstim);
upsh.which = zeros(numunit,1);
upsh.hist = zeros(length(upsh.t),numunit);
upsh.std = zeros(size(upsh.hist));

% Start
disp('Calculating Peri-stimulus histogram ...')

% perform only on clean spks
b0 = min(SS.st_time(whichstim) - histrange(1)/1000 - dt);
b1 = max(SS.st_time(whichstim) + histrange(2)/1000 + dt);
dat = SS.ReturnClean([b0 b1]);

% modify clean data to use only selected units
if ~forcechan
    goodunit = ismember(dat.unit, which);
    upsh.which = which;
    dat.unit  = dat.unit(goodunit);
    dat.time  = dat.time(goodunit);
else
    goodchan = ismember(dat.channel, which);
    upsh.which = which;
    dat.unit  = dat.channel(goodchan);
    dat.time  = dat.time(goodchan);
end

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
            uspk = spks(unt == which(j));
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
upsh.hist = upsh.hist/upsh.stmcount/dtsec;

% calculate efficacy
eff = sum(upsh.hist(upsh.t>0 & upsh.t<=effrange/1000,:),1);
[eff idx] = sort(eff);

% sort the whole thing based on efficacy
upsh.which = upsh.which(idx);
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
    q = SS.PlotUnitWisePSH(100);
else
    q = 0;
end

% Add psh to method log
SS.methodlog = [SS.methodlog '<UnitWisePSH>'];

end

