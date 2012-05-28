function RemoveBySymmetry(SS,maxWaveSymmetry)
% REMOVEBYSYMMETRY(SS,maxWaveSymmetry) takes the ratio of the
% maximal postive and negative deflections of a waveform about
% its mean (DC) offset and compares this to maxWaveSymmetry
% (which is between 0 and 1). If the ratio is larger than
% maxWaveSymmetry, the spike is rejected.
% Written by: JN

if maxWaveSymmetry > 1 || maxWaveSymmetry <0
    error(' The arguement maxWaveSymmetry must be a ratio between 0 and 1')
end

meanAmplitude = mean(SS.waveform,1);
maxAmplitude = abs(max(SS.waveform,[],1) - meanAmplitude);
minAmplitude = abs(min(SS.waveform,[],1)  - meanAmplitude);
numeratorOverDenominator = sort([maxAmplitude; minAmplitude],1);
symRatio = numeratorOverDenominator(1,:)./numeratorOverDenominator(2,:);
dirty = symRatio > maxWaveSymmetry;

if ~isempty(dirty)
    SS.clean = SS.clean&(~dirty');
end
SS.methodlog = [SS.methodlog '<RemoveBySymmetry>'];
end