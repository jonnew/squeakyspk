function PkVelocity(SS,th)
% PKVELOCITY(SS,th)
% threshold the velocity at the peaks
% th uV/sec -find empirically, 6-8e5 uV/sec seems to work well
% Written by: NK
if nargin < 2 || isempty(th)
    th = 8e5; %uV/sec
end
[maxs maxi] = max(SS.waveform);[mins mini] = min(SS.waveform);
vel = diff(SS.waveform);
maxi(maxi<2)=2;maxi(maxi==size(SS.waveform,1))=size(SS.waveform,1)-1;
mini(mini<2)=2;mini(mini==size(SS.waveform,1))=size(SS.waveform,1)-1;
pv = abs(vel(maxi-1:maxi,:));tv = abs(vel(mini-1:mini,:));%1 before, 1 after
pv(pv<eps)=nan;tv(tv<eps)=nan;
pkvel = nanmean(pv,1)*SS.fs;trvel = nanmean(tv,1)*SS.fs;
tmp = (pkvel<th) & (trvel<th);
SS.clean = SS.clean&(tmp');
SS.methodlog = [SS.methodlog '<PkVelocity>'];
end
