function UpSamp(SS,us,pkalign,tpre,tpost,threshold)
% UPSAMP(SS,us,pkalign,tpre,tpost)
% upsample waveforms by integer factor and optionally
% change snippet time after align to (new) peaks
% us: upsampling rate, integer factor, default of 2
% pkalign: realign to peaks after upsampling
%           todo: need to take into account threshold, pos/neg peaks and pre/post wf time
%                     used by the user's recording system
% tpre: time preceding peak in usec
% tpost: time after peak in usec
% threshold: threshold information
% Written by: NK
disp('upsampling waveforms')
if nargin < 6, threshold = -1;end%align to negative peak by default
if nargin < 3, pkalign = 0;end
if nargin == 3,
    tpre = 200;tpost = 600;%usec, should provide integer multiple samples of 1/SS.fs
end
if nargin < 2,      us = 2;end
%             default_peak_index = 25*us+1;
default_peak_index = 8*us+1;
% do only clean waveforms to improve speed, need separate matrix though
SS.waveform_us = zeros(size(SS.waveform,1)*us,size(SS.waveform(:,SS.clean),2));
if pkalign
    wfpre   = SS.fs*tpre*1e-6;wfpost = SS.fs*tpost*1e-6;
    nwfpts  = (wfpre+wfpost)*us+1;
    wftime  = linspace(-tpre,tpost,nwfpts);%final, upsampled time, usecs
    wf      = zeros(nwfpts,size(SS.waveform_us,2));
end
%             if us>1,ttmp = interp(wftime,usfs);else ttmp = wftime;end
[~, i1] = min(abs(wftime-0));
[~, i2] = min(abs(wftime-150));
tind = i1:i2;%peak will only come after crossing
cleanwfs = find(SS.clean);
for k = 1:length(cleanwfs)
    SS.waveform_us(:,k) = interp(SS.waveform(:,cleanwfs(k)),us);
    if pkalign
        wftmp = SS.waveform_us(:,k);wftest = wftmp(tind);
        if threshold < 0,
            [dum pkind] = min(wftest);else %todo: incorporate NR threshold info
            [dum pkind] = max(wftest);
        end
        pkind = tind(1)+pkind-1;
        %                     try
        wf(:,k) = wftmp(pkind-wfpre*us:pkind+wfpost*us);
        %                     catch %todo: make this relevant
        %                         wf(:,k) = wftmp(default_peak_index-wfpre*us:default_peak_index+wfpost*us);
        %                     end
    end
end
if pkalign
    SS.waveform_us = wf;
    SS.waveform_us_t = wftime;
end
tmp = SS.waveform_us;
SS.waveform_us = zeros(nwfpts,size(SS.waveform,2));
SS.waveform_us(:,SS.clean) = tmp;
SS.methodlog = [SS.methodlog '<UpSamp>'];
end
