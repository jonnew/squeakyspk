function ISIDist(SS, bin, bound, force_channel )
%ISIDIST Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4 || isempty(force_channel)
    force_channel = 0;
end
if nargin < 3 || isempty(bound)
    bound = [min(SS.time) max(SS.time)];
end
if nargin < 2 || isempty(bin)
    bin = 0:0.01:5;
end

isi_dist.bin = bin;


if isempty(SS.unit) || force_channel
    
    uc = unique(SS.channel);
    isi_dist.chan = uc;
    isi_dist.count = zeros(numel(uc), numel(bin));
    
    for i = 1:numel(uc)
        b = SS.time >= bound(1) & SS.time < bound(2) & SS.channel == uc(i);
        st = SS.time(b);
        
        if numel(st) > 1
            isi_dist.count(i,:) = histc(diff(st),bin);
        end
    end
else
    uu = unique(SS.unit(SS.unit~=0));
    isi_dist.unit = uu;
    isi_dist.count = zeros(numel(uu), numel(bin));
    
    for i = 1:numel(uu)
        b = SS.time >= bound(1) & SS.time < bound(2) & SS.unit == uu(i);
        st = SS.time(b);
        
        if numel(st) > 1
            isi_dist.count(i,:) = histc(diff(st),bin);
        end
        
    end
end

SS.isi_dist = isi_dist;

end

