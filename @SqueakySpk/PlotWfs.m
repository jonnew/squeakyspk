function PlotWfs(SS,maxwfs,chan)
% PLOTWFS(SS,maxwfs,chan)
% plot maxwfs waveforms on specified channel (ie for debugging purposes)
% Written by: NK
if nargin < 3 || isempty(chan)
    chan = 2;
end
if nargin < 2 || isempty(maxwfs)
    maxwfs = 10000; %usec, peak-trough
end
if strfind(SS.methodlog,'UpSamp'),
    wfs = SS.waveform_us(:,SS.clean&SS.channel==chan);
    time = SS.waveform_us_t;
else
    wfs = SS.waveform(:,SS.clean&SS.channel==chan);
    time = [1:size(wfs,1)]/SS.fs;
end
if isempty(wfs), disp('no waveforms');else
    n = min([size(wfs,2) maxwfs]);
    wfi = randsample(size(wfs,2),n);
    plot(time,wfs(:,wfi),'b');hold on;
    plot(time,nanmean(wfs,2),'k','linewidth',2)
    title(['ch' num2str(chan) ', n = ' num2str(length(find(SS.clean)))]);
    SS.methodlog = [SS.methodlog '<PlotWfs>'];
end
end