function ns = NeuroSound(SS,tbound,pbspeed,ampscale,basefreq,scale, fid)
% NEUROSOUND audio output event-based recording that really makes a
% SqueakySpk Squeak.  Each channel is given a different key on a
% synthesizer- whenever an action potential is detected on that electrode,
% the key is depressed for a 10th of a second and a note is played.
%
% NS = NEUROSOUND(SS,tbound,pbspeed,ampscale,basefreq,scale)
%
%       Inputs:
%       SS = SqueakySpk object
%       TBOUND = [t1 t2] defines the time window, in seconds, of the
%       recording that you want to hear.
%       PBSPEED = scale factor for the playback speed. May be helpful in
%       detecting patterns that occur on different time scales. Increase to
%       make the playback faster. PBSPEED = 1 is real-time, PBSPEED = 1/2 
%       slowed down by a factor of 2.
%       AMPSCALE = Scale factor to keep sound signal within the dynamic
%       range of your speakers [+-1 volt]. Adjust up to stretch dynamic
%       range over [+-1 volt] (e.g. you can't discriminate events in the
%       recording from background noise) and down if you are getting
%       saturation. This option is available only for
%       continuous waveforms and will be ignored otherwise. A value of 1
%       volt here is usually safe.
%       BASEFREQ = Lowest frequency to make make a scale of notes
%       corresponding to units or channels.  The lowest frequency a human
%       can hear is roughly 20 hz.
%       SCALE = musical scale used for this neurosound object.  Currently,
%       you can choose from 'major', 'minor', 'diminished', 'pentatonic',
%       or 'chromatic'.  The BASEFREQ is the tonic note for the lowest
%       octace used.  Note that different scales will use different ranges
%       of notes- the highest frequency used by a 'pentatonic' scale will
%       be much higher than the highest frequency used by a 'chromatic'
%       scale, even if they use the same BASEFREQ.  Make sure you aren't
%       hitting notes that can't be heard or can't be processed by your
%       sound system!
%       FID = optional file name argument if you want to save your
%       neurosound as a .WAV file 
%
%       Outputs:
%       NS = Neurosound audio object. This oject has the following methods
%       associated with it:
%           play(ns) - play the neurosound
%           stop(ns) - stop the neurosound
%           pause(ns) - pause the neurosound
%           resume(ns) - resume the neurosound after a pause
%
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Generally screwed around with by: Riley Zeller-Townson (rtzt3 at
%       gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Apr 24, 2010
%       Last modified: Feb 10, 2011
%
%       Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

% check number and type of arguments

if( nargin < 3)|| isempty(tbound)
    tbound = [];
end
if( nargin < 3)|| isempty(pbspeed)
    pbspeed = 1;
end
if(nargin < 4) || isempty(ampscale)
    ampscale = 1;
end
if(nargin < 5) || isempty(basefreq)
    basefreq = 20;
end
if (nargin <6) || isempty(scale)
    scale = 'major';
end


%intervals between notes for different scales
%a little crash course in music theory (from someone who took a class in 
%high school like 6 years ago)- every note has it's own frequency.
%If you double a frequency, you go up an octave (like going from middle c
%to a higher c note).  There are twelve tones in an octave (all the black
%keys and white keys included)- each one is just going up 2^(1/12) times
%the frequency of the previous tone (these intervals are called 'half
%steps').  A scale is defined by the 'tonic' note (ie, C for Cmaj, E for
%Emin), and the pattern of intervals you take as you go up the scale.  Your
%tonic is defined by the BASEFREQ argument, the pattern of intervals
%defined by the SCALE variable
diminished = [2 1 2 1 2 1 2 1];
major = [2 2 1 2 2 2 1];
minor = [1 2 2 2 1 2 2];
pentatonic = [ 2 2 2 2 2 2];
chromatic = [1 1 1 1 1 1 1 1 1 1 1 1];

switch scale
    case 'diminished'
        chosenscale = diminished;
        scalename = scale;
    case 'major'
        chosenscale = major;
        scalename = scale;
    case 'minor'
        chosenscale = minor;
        scalename = scale;
    case 'pentatonic'
        chosenscale = pentatonic;
        scalename = scale;
    otherwise
        chosenscale = chromatic;
        scalename = 'chromatic';
end


%if isempty(SS.unit)
    chan = SS.channel(SS.clean);
    spktime = SS.time(SS.clean);
    tonerep = 'channels';
%else
%     chan = SS.unit(SS.clean&SS.unit~=0);
%     spktime = SS.time(SS.clean);
%     tonerep = 'units';
% end

% Create continuous waveform from the discrete events
if isempty(tbound)
    times = spktime; % sorted times, in seconds, referenced to t=0.
else
    times = spktime(spktime>tbound(1)&spktime<tbound(2));% sorted times, in seconds, referenced to t=0.
    times = times - tbound(1);
    chan = chan(spktime>tbound(1)&spktime<tbound(2));
end
%sortedtimes(sortedtimes==0) = []; % get rid of any time that is zero
%maxT = tbound(2); % length of sound will be the time of the final event + 1 sec
outrate = 44100;


eventInd = ceil(outrate*times/pbspeed);

% Create 10 ms tone snips for each channel
numchan = 64;%max(chan);
snipdur =length(1/outrate:1/outrate:0.1);
snip = zeros(numchan,snipdur,2);
tmp = zeros(length(1/outrate:1/outrate:0.1),1);
N = ceil(outrate*(tbound(2)-tbound(1))/pbspeed);
wave = zeros(N,2);


multiple = 1;
note = 1;
left = 0.1;
right = 1;


envelope = pdf('chi2',(1:snipdur)/snipdur*10,3);%pdf('Normal',-5:10/snipdur:5-1/snipdur,0,2);

for k = 1:numchan
    c_freq = basefreq*2^((multiple-1)/12);
    c_amp = 2^-((multiple-1)/24);
    tmp = sin(c_freq*pi*(1/outrate:1/outrate:0.1))*c_amp;
    lastlow = find(snip(k,:)<0,1,'last');
    tmp(lastlow:length(1/outrate:1/outrate:0.1)) = 0;
    multiple = multiple+chosenscale(note);
    note = note +1;
    if note>length(chosenscale)
        note = 1;
    end
    c = ceil(k/8);
    r = k-(c-1)*8;

    left = ((c-8)^2 + (r-8)^2)^0.5;
    right = ((c-1)^2 + (r-1)^2)^0.5;
    envelope = pdf('chi2',(1:snipdur)/snipdur*10,2);
    snip(k,:,1) = tmp*right.*envelope;
    snip(k,:,2) = tmp*left.*envelope;
    
end
%figure;plot(reshape(snip,64
%figure;mesh(snip)


for k = 1:length(eventInd)
%     size(wave(eventInd(k):eventInd(k)+length(snip)-1))
%     size(snip(chan(k),:))
   start = eventInd(k);
   stop = eventInd(k)+length(snip)-1;
   if stop>length(wave) 
       stop = length(wave);
   end
  % start
  % stop
  % k
    wave(start:stop,:) = reshape(snip(chan(k),1:stop-start+1,:),stop-start+1,2)+ wave(start:stop,:);
end
wave(:,1) = wave(:,1)./max(wave(:,1))*ampscale;
wave(:,2) = wave(:,2)./max(wave(:,2))*ampscale;

%wave = logscale(wave);

if ((nargin >=7) && ~isempty(fid))
    
   % filename = [SS.name num2str(tbound(1)) 'to' num2str(tbound(2)) 'at' num2str(pbspeed) 'in' scale '.wav'];
    wavwrite(wave,outrate,fid)
end

figure;
subplot(3,1,[1 2]);plot(eventInd,chan(1:length(eventInd)),'r.');xlim([1 N]);
subplot(3,1,3);plot(wave);xlim([1 N]);
ns = audioplayer(wave,outrate);

% Instructions for use
disp(' ');
disp('You have created a neurosound object with the following properties:');
disp(['Playback speed: ' num2str(pbspeed) ' X real-time']);
disp(['Amplitude scale factor: ' num2str(ampscale)]);
disp(['scale is ' scalename ', using frequencies from ' num2str(basefreq) ' to ' num2str(basefreq*2^((multiple-1)/12)) 'hz']);
disp(['sampling rate is ' num2str(outrate) 'hz']);
disp(['Tones represent different' tonerep])
disp(' ');
disp('Use the following commands to control playback: ');
disp('[1]: "play(ns)" to stop the playback');
disp('[2]: "stop(ns)" to stop the playback');
disp('[3]: "pause(ns)" to pause the playback');
disp('[4]: "resume(ns)" to resume the playback');

end


function out = logscale(in)
sign = in./abs(in);

out = log(abs(in)*20+1).*sign/10;
out(out==NaN) =0;
end