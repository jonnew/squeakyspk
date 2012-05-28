function RemoveSpkWithBlank(SS)
% REMOVESPKWITHBLANK(SS) Removes all 'spikes' that have more that have 5 or more
% voltage values in their waveform below 0.1 uV inidcating that a
% portion of the waveform is blanked. This is extremely
% unlikely otherwise.
% Written by: JN

dirty = (sum(abs(SS.waveform) <= 0.1,1) >= 5);
if ~isempty(dirty)
    SS.clean = SS.clean&(~dirty');
end
SS.methodlog = [SS.methodlog '<RemoveSpkWithBlank>'];
end