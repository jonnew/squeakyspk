function [result counts] = XCorrs(SS, mintime, maxtime, binlength, xcorlength, xcorrez)

xc_length = ceil(xcorlength*1000/xcorrez)*2+1;
channels_used = 1:64;%unique(SS.channel);
explength =ceil((maxtime-mintime)/binlength);
cause = length(channels_used)*2;
effect = length(channels_used);
result = NaN(explength, cause,effect , xc_length);
counts = zeros(explength,cause);
tasks = NaN(length(channels_used)^2*1.5,3);
index = 0;
%stim on spikes
for i = 1:length(channels_used)
    tasks(index+(1:length(channels_used)),1) = channels_used(i);
    
    
    tasks(index+(1:length(channels_used)),3) = channels_used;
    index = index+length(channels_used);
end

%spikes on spikes
used = 0;
for i = 1:length(channels_used)
    tasks(index+(1:length(channels_used)-used),2) = channels_used(i);
    tasks(index+(1:length(channels_used)-used),3) = channels_used(used+1:length(channels_used));
    index = index+length(channels_used)-used;
    used = used+1;
end
%h= waitbar(0,['running timeslice ' num2str(1)]);
fullspiketime = SS.time(SS.clean);
fullspikechannel=SS.channel(SS.clean);
%size(fullspiketime)
fullstimtime=SS.st_time;
fullstimchannel=SS.st_channel;
autoc = NaN(size(result,1),xc_length);
for t=1:size(result,1)
    subresult = zeros(cause,effect , xc_length);
    %convert
    starttime = (t-1)*binlength+mintime;
    stoptime = t*binlength+mintime;
    
    spiketime = fullspiketime((fullspiketime >=starttime)&(fullspiketime <stoptime));
    spikechannel = fullspikechannel((fullspiketime>=starttime)&(fullspiketime<stoptime));
    %size(spiketime )
    stimtime = fullstimtime((fullstimtime>=starttime)&(fullstimtime<stoptime));
    stimchannel = fullstimchannel((fullstimtime>=starttime)&(fullstimtime<stoptime));
    
    if isempty(stimtime)
        stimtime = NaN;
        stimchannel = NaN;
    end
    if isempty(spiketime)
        spiketime = NaN;
        spikechannel = NaN;
    end
    
    timestart = min([spiketime; stimtime']);
    spiketime = spiketime - timestart;
    stimtime = stimtime - timestart;
    
    timeend = max([spiketime; stimtime']);
    tseries_mat = zeros(length(channels_used)*2, timeend);
    %tmp_count = 0;
    for x=1:length(channels_used)
        %disp(x)
        %sum(spikechannel==x)
        spks = convert2tseries(spiketime(spikechannel == x), xcorrez);
        %disp(sum(spks))
        %disp(sum(stimchannel == x))
        %tmp_count= tmp_count+sum(spks);
        stms = convert2tseries(stimtime(stimchannel == x), xcorrez);
        %disp(sum(stms))
        tseries_mat(x, 1:length(spks)) = spks;
        tseries_mat(x+size(channels_used,1), 1:length(stms)) = stms;
                counts(t,x) = sum(spks);
        counts(t,x+64) = sum(stms);
        %disp(['channel ' num2str(x) ' spks: ' num2str(sum(spks)) ' stms: ' num2str(sum(stms))]);
    end
    %tmp_count
    %     figure;plot(spiketime,spikechannel,'.');hold on; plot(stimtime,stimchannel,'.r');
    %run tasks
    
    %     figure;imagesc(tseries_mat);set(gca,'YDir','normal');hold on;
    %      plot(spiketime.*1000, spikechannel, '.y');hold on;plot(stimtime.*1000,stimchannel+64,'.r');
    %      pause
    %waitbar(0,h,['running timeslice ' num2str(t)]);
    for x=1:size(tasks, 1)
        %       disp(num2str(tasks(x,:)))
        
        if isnan(tasks(x, 2))
            %stim on spike
            %             sum(tseries_mat(tasks(x, 3)+length(channels_used), :))
            %             figure(3);subplot(1,2,1);plot(tseries_mat(tasks(x, 1), :),'g');hold on;
            %             plot(tseries_mat(tasks(x, 3)+length(channels_used), :),'r');hold off
            %             title(num2str(tasks(x,[1,3])));
            
            
            causal_index = tasks(x, 1)+length(channels_used);
            effect_index = tasks(x, 3);
            reflexive = false;
        else
            causal_index = tasks(x, 2);
            effect_index = tasks(x, 3);
            reflexive = true;
        end
        causal_series = tseries_mat(causal_index, :);
        effect_series = tseries_mat(effect_index, :);
        
        if ((sum(causal_series)>0)&...
                (sum(effect_series)>0))
            
            xc = xcorr( effect_series,causal_series);
            if length(xc)<xc_length
                xstart = 1;
                xstop = length(xc);
                sstart = (xc_length-1)/2+1-floor(xc_length /2);
                sstop = (xc_length-1)/2+1+floor(xc_length /2);
            else
                xstart = (length(xc)-1)/2+1-floor(xc_length /2);
                
                xstop = (length(xc)-1)/2+1+floor(xc_length /2);
                sstart = 1;
                sstop = xc_length;
            end
            %                 xc_length
            %                 length(xc)
            %                 sstart
            %                 sstop
            %                 xstart
            %                 xstop
            %                 size(subresult(tasks(x, 1), tasks(x, 3), sstart:sstop))
            %                 size(xc(xstart:xstop))
            %             if tasks(x,1) ==tasks(x,3)
            %                 figure(3);title(num2str(tasks(x,1)));
            %                 subplot(3,1,1);
            %                 plot(tseries_mat(tasks(x, 1)+length(channels_used), :),'r');
            %                 hold on; plot(tseries_mat(tasks(x, 3),:));hold off;
            %                 subplot(3,1,2);
            %                 plot(xc(xstart:xstop));axis tight;
            %                 subplot(3,1,3);
            %                 plot(xc)
            %                 pause
            %             end
            subresult(causal_index, effect_index, sstart:sstop) = xc(xstart:xstop);
            if reflexive
                subresult(effect_index, causal_index, sstart:sstop) = xc(xstop:-1:xstart);
            end
            %              figure(3);subplot(1,2,2);plot(xc);
        end
        
        
        %waitbar(x/size(tasks,1),h);
    end
    
    %find activity autocorrelation during this period
    
    result(t,:,:,:) = subresult;
    %counts(t,:) = sum(tseries_mat,2);
    totalspikes = sum(tseries_mat);
   % sum(totalspikes)
    %figure;subplot(2,1,1);plot(totalspikes);subplot(2,1,2);imagesc(tseries_mat);
    xc = xcorr(totalspikes,totalspikes);
    %figure;plot(xc);
    xstart = (length(xc)-1)/2+1-floor(xc_length /2);
    xstop = (length(xc)-1)/2+1+floor(xc_length /2);
    
    autoc(t,:) = xc(xstart:xstop);
    %figure;imagesc(autoc);
    disp(t);
end
SS.xcorrmat = result;
SS.xcount = counts;
SS.xauto = autoc;
SS.xbin = binlength;
SS.xrez = xcorrez;
% close(h);


    function tseries = convert2tseries(spikes, rez)
        %CONVERT2TSERIES converts an array of spike times into tseries
        %   SPIKES is an array of spike times in seconds
        %   REZ is resolution of array in ms
        %   TSERIES is an array of length ALENGTH which is created by sorting
        %   spikes into a specific 'time bin', which is a length of time that is
        %   calculated by dividing the length of TSERIES by the max time in
        %   SPIKES.
       % disp('test');
       %length(spikes)
       
        if isempty(spikes)
            tseries = zeros(1);
            return;
        end
        s = max(spikes);
        tseries = zeros(1, floor(s*1000/rez)+1);
        
        temp = floor(spikes*1000/rez)+1;
        %length(temp)
        for ind=1:length(temp)
            tseries(temp(ind)) = tseries(temp(ind)) + 1;
        end
        %sum(tseries)
        %pause
    end
end
