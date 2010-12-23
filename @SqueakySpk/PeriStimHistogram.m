function PeriStimHistogram(SS,dt,histrange,bound)
%PERISTIMTIMEHISTOGRAM create the PSH for an SS object.
%
%   PERISTIMTIMEHISTOGRAM(SS, dt,histrange,bound) calculates the
%   peristimulus histogram with time resolution dt (msec) for a time window around
%   the conditioning stimulus event defined by histrange = [t1 t2] in
%   milliseconds, the range of data in seconds supplied by bound = [T1 T2]
%   in seconds. The PSH is caculated for each channel and stored in the [N
%   x M] matrix psh.hist which represend the M sample long psh for each of
%   N channels.

% check number and type of arguments
if nargin < 4 || isempty(bound)
    bound = [0 max(SS.time)]; % Whole recording
end
if nargin < 3 || isempty(histrange)
    histrange = [-100 500]; % Default range of histogram
end
if nargin < 2 || isempty(dt)
    dt = 5; % Default time resolution of 1 ms
end
if nargin < 1
    error('Need to act on SqueakSpk Object');
end

% Make sure the data actual has stimulation entries
if isempty(SS.st_time)
    warning('You must provide stimulus timing information to form a peristimulus histogram. Now exiting...')
    return
end

% Make sure the data actual has stimulation entries
if histrange(1) > histrange(2)
    error('histrange(1) must be less than histrange(2)')
end

% convert to seconds
b = histrange/1000; dtsec = dt/1000;

goodstim = find(SS.st_time >= bound(1) & SS.st_time <= bound(2));
goodtime = SS.st_time(goodstim);
goodchan = SS.st_channel(goodstim);

psh.t = b(1):dtsec:b(2);
psh.stimcount = zeros(max(goodchan),1);
psh.hist = zeros(max(goodchan),length(b(1):dtsec:b(2)));
psh.std = zeros(max(goodchan),length(b(1):dtsec:b(2)));

wait_h = waitbar(0,'Caclulating PSH');
steps2update = floor(length(goodstim)/100);

% perform only on clean spks
clean_spk = SS.time(SS.clean);

for i = 1:length(goodstim)
    t1 = b(1) + goodtime(i);
    t2 = b(2) + goodtime(i);
    
    spks = clean_spk(clean_spk > t1 & clean_spk <= t2);
    count = hist(spks-goodtime(i),psh.t);
    
    if size(count,2) ~= 1
        psh.hist(goodchan(i),:) = psh.hist(goodchan(i),:) + count;
        psh.std(goodchan(i),:) = psh.std(goodchan(i),:) + count.^2;
        psh.stimcount(goodchan(i)) = psh.stimcount(goodchan(i)) + 1;
    end
    
    if ~logical(mod(i,steps2update))
        waitbar(i/length(goodstim),wait_h)
    end
    
end

close(wait_h)

% Calculate RMS and normalize everything to firing rate
for i = 1:max(goodchan)
    psh.std(i,:) = sqrt(psh.std(i,:)/psh.stimcount(i))/dtsec;
    psh.hist(i,:) = psh.hist(i,:)/psh.stimcount(i)/dtsec;
end

% Save the psh
SS.psh = psh;

SS.PlotPeriStimHistogram;

% Add psh to method log
SS.methodlog = [SS.methodlog '<PeriStimHistogram>'];

end

