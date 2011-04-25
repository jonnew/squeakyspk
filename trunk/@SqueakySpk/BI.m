function BI(SS,bound)
% BI(SS,BOUND) Burstiness index as described in Wagenaar et al
% (2006) J. Neurosci 25(3): 680;68. BOUND = [t0 tend] is an option arguement that
% allows one to calculate the BI over a particular time chunk. Since this
% operation involves a division by an esimated firing rate, it is possible
% to get an infinite value, in which case 'NA' is returned.


if isempty(SS.asdr)
    warning('You need to calculate the ASDR before calculating the BI. Now exiting BI.');
    return;
end
if nargin < 2
    bound = [0 SS.asdr(end,1)];
end

asdr_ToUse = SS.asdr(:,2);
asdr_ToUse = asdr_ToUse(SS.asdr(:,1) > bound(1) & SS.asdr(:,1) < bound(2));

sASDR = sort(asdr_ToUse,'descend');
l15 = ceil(0.15*length(asdr_ToUse));
f15n = sum(sASDR(1:l15));
f15d = sum(sASDR);
f15 = f15n/f15d;

if isnan(f15) || isinf(f15) || f15d == f15n;
    SS.bi = 'NA';
else
    SS.bi = (f15 - 0.15)/0.85;
end
end

