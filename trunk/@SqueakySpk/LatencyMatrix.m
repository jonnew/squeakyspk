%latmat = LatencyMatrix(bound,duration)
%generates a 54xN matrix with all the possible directly evoked action
%potentials.  
%inputs:
%bound- bound(0) time in seconds to start looking for dAP
%       bound(1) time in seconds to stop looking for dAPs
%dur- time in ms to look after each stimulus
%outputs:
%latmat(1,:) unit information (or channel, if no unit info is available)
%latmat(2,:) dAP latency in seconds
%latmat(3,:) stimulus channel
%latmat(4,:) stimulus time
%latmat(5:54,:) waveform (not harvested if no waveform data is available)

function latmat = latencyMatrix(SS,bound,dur)
tic
%creates a 3 d array with time, latency, and unit information for each detected
%spike
if isempty(SS.st_time)
    warning('You must provide stimulus timing information to form a peristimulus raster. Now exiting...')
    return
end

goodstim = find(SS.st_time >= bound(1) & SS.st_time <= bound(2));

st_time = SS.st_time(goodstim);
st_chan = SS.st_channel(goodstim);

goodspike = find((SS.time >= bound(1) & SS.time <= bound(2))&SS.clean);
sp_time = SS.time(goodspike);
if isempty(SS.unit)
    sp_unit = SS.channel(goodspike);
else
    sp_unit = SS.unit(goodspike);
end
sp_channel = SS.channel(goodspike);
wave = (size(SS.waveform,2)>0);
if wave
    sp_wave = SS.waveform(:,goodspike);
end

h2 = waitbar(0,'calculating peristimulus latencies');

%stim time
%latency
%channel/unit
latmat1 = cell(3,length(st_time));

nospikes = 0;

for i = 1:length(st_time)
    
  
    %absolute times for all the relevant spikes
    inds = (sp_time-st_time(i)<dur/1000) & (sp_time-st_time(i)>0);
    tmpx = sp_time(inds);

    if ~isempty(tmpx)

        %latency for all relevant spikes
        tmpx = tmpx-st_time(i);
        tmpc = sp_channel(inds);
        tmpu = sp_unit(inds);
        if wave
            tmpw = sp_wave(:,inds);
        end
        
        %tmpx = tmpx(tmpu~=0);
%         tmpu= tmpu(tmpu~=0);
%         tmpc = tmpc(tmpu~=0);
%         tmpw = tmpw(:,tmpu~=0);
        
        latmat1{1,i} = tmpu;
        latmat1{2,i} = tmpx;
        latmat1{3,i} = tmpc;
        latmat1{4,i} = ones(size(tmpx))*st_time(i);
        if wave
            latmat1{5,i} = tmpw;
        end
        nospikes = nospikes+length(tmpx);
    end
    


    if (mod(i,40)==0)
        waitbar(i/length(st_time)/2,h2);
    end
%pause
end
if wave
    latmat = NaN(54,nospikes);
else
    latmat = NaN(4,nospikes);
end
ind =1;
for i = 1:length(st_time)
    if ~isempty(latmat1{1,i})
        inds = ind+(0:length(latmat1{1,i})-1);
        latmat(1,inds) = latmat1{1,i};
        latmat(2,inds) = latmat1{2,i};
        latmat(3,inds) = latmat1{3,i};
        latmat(4,inds) = latmat1{4,i};
        if wave
        latmat(5:54,inds) = latmat1{5,i};
        end
        ind = ind+length(latmat1{1,i});
    end
     if (mod(i,40)==0)
        waitbar(i/length(st_time)/2+0.5,h2);
    end
end


close(h2);

toc




end