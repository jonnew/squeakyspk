function PeriStimHistogram(SS,dt,histrange,whichstim,ploton)
% PERISTIMHISTOGRAM create the PSH for an SS object.
%
%   	PERISTIMHISTOGRAM(SS,DT,HISTRANGE,WHICHSTIM,PLOTON) calculates the
%   	peristimulus histogram with time resolution DT (msec) for a time
%   	window around the conditioning stimulus event defined by HISTRANGE
%   	= [t1 t2] in milliseconds. WHICHSTIM is a logical array with dimesions
%   	equal to SS.st_time, defining which stimuli the PSH should be
%   	calculated for. The default value is WHICHSTIM = true(size(SS.st_time)).
%       The PSH is caculated for each channel and stored in the [N x M]
%       matrix psh.hist which represents the M sample long psh for each of N
%       channels. PLOTON is a logical that controls whether or not the PSH
%       is plotted after the comptuation has finished.
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu) Location: The
%       Georgia Institute of Technology 
%       Created on: Feb 2, 2011 
%       Last modified: Apr 26, 2011
% 
%       Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

% check number and whichstim of arguments
if nargin < 5 || isempty(ploton)
    ploton = 1; % Whole recording
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
    warning('You must provide stimulus timing information to form a peristimulus histogram. Now exiting...')
    return
end

% Make sure the histogram bounds are corre
if histrange(1) > histrange(2)
    error('histrange(1) must be less than histrange(2)')
end

% convert to seconds
b = histrange/1000; dtsec = dt/1000;

goodtime = SS.st_time(whichstim);
goodchan = SS.st_channel(whichstim);

psh.t = b(1):dtsec:b(2);
psh.stimcount = zeros(max(goodchan),1);
psh.hist = zeros(max(goodchan),length(b(1):dtsec:b(2)));
psh.std = zeros(max(goodchan),length(b(1):dtsec:b(2)));

disp('Calculating Peri-stimulus histogram ...')

% perform only on clean spks
clean_spk = SS.time(SS.clean);

for i = 1:sum(whichstim)
    t1 = b(1) + goodtime(i);
    t2 = b(2) + goodtime(i);
    
    spks = clean_spk(clean_spk >= (t1-dtsec) & clean_spk <= (t2+dtsec));
    count = hist(spks-goodtime(i),psh.t);
    
    if size(count,2) ~= 1
        psh.hist(goodchan(i),:) = psh.hist(goodchan(i),:) + count;
        psh.std(goodchan(i),:) = psh.std(goodchan(i),:) + count.^2;
        psh.stimcount(goodchan(i)) = psh.stimcount(goodchan(i)) + 1;
    end
       
end

% Calculate RMS and normalize everything to firing rate
for i = 1:max(goodchan)
    psh.std(i,:) = sqrt(psh.std(i,:)/psh.stimcount(i))/dtsec;
    psh.hist(i,:) = psh.hist(i,:)/psh.stimcount(i)/dtsec;
end

% Save the psh
SS.psh = psh;

% Plot if the user wants it
if ploton
    SS.PlotPeriStimHistogram;
end

% Finish
disp('Finished calculating Peri-stimulus histogram.')

% Add psh to method log
SS.methodlog = [SS.methodlog '<PeriStimHistogram>'];

end

