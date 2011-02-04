function BI(SS)
% BI(SSt) Burstiness index as described in Wagenaar et al
% (2006) J. Neurosci 25(3): 680�68

if isempty(SS.asdr)
    warning('You need to calculate the ASDR before calculating the BI');
    return;
end

sASDR = sort(SS.asdr(:,2),'descend');
l15 = ceil(0.15*length(SS.asdr));
f15n = sum(sASDR(1:l15));
f15d = sum(sASDR);
f15 = f15n/f15d;

if isnan(f15) || isinf(f15) || f15d == f15n;
    SS.bi = 'NA';
else
    SS.bi = (f15 - 0.15)/0.85;
end
end

