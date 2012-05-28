function MitraClean(SS)
% MITRA CLEAN(SS) removes all spikes that have multiple peaks
% effective at removing noise, many stimulus artifacts
% still get through
%
% probably not optimal code, but this will work
%
% needs edit so that it doesn't care about minor ripples in the
% main peak
%
%will remove compound APs if they are less than 1ms apart
% Written by: RZT

true_wave = ones(length(SS.waveform),1);

for ind = 1:length(SS.waveform)
    wave = SS.waveform(:,ind);%examine this particular waveform
    [d i] = max(abs(wave));
    d = wave(i); %get the peak amplitude, including the sign
    pos = (d>0);
    pos = pos*2-1;% -1 means negative, 1 means positive
    low =i-25;%need to specify the region of interest- 25 samples on either side of the peak
    if low<1;
        low = 1;
    end
    high = i+25;
    if high>75
        high = 75;
    end
    %look for peaks on either side of the main peak
    dt =diff(wave);
    
    %find the valleys on either side of the main peak
    up = dt(i+1:high-1);
    down = dt(low:i-1);
    bup = find(up*pos>0);
    bdown = find(-down*pos>0);
    
    %if a valley is found, check to see if other peaks after
    %this valley are equal to half the amplitude of the main
    %peak
    if ~isempty(bup)
        bu = bup(1);
        %plot(i+bu,wave(i+bu),'.b');
        if max(wave(i+bu:high)*pos)>d*pos/2
            true_wave(ind) = 0;
        end
    end
    
    %look to see if the first peak before the main peak exceeds
    %threhold:
    if ~isempty(bdown)
        bd = bdown(length(bdown));
        %plot(bd+low,wave(bd+low),'.m');
        if max(wave(low:bd+low)*pos)>d*pos/2
            true_wave(ind) = 0;
        end
    end
    %                 if true_wave(ind)
    %                     figure(1);hold on;plot(wave);
    %                 else
    %                     figure(2);hold on; plot(wave);
    %                 end
end
SS.clean = SS.clean&true_wave;
%                 size(SS.clean)
%                 size(true_wave)
SS.methodlog = [SS.methodlog '<Mitraclean>'];
end