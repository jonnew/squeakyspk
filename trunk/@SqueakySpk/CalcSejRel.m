function rel = CalcSejRel(SS, filters, varargin)
%CALCSEJREL calculates the reliability of response spike trains 
%   REL = CALCSEJREL(filters) calculates the response spike train
%   reliability by taking the normalization of the summation of the inner
%   products of each pair of spike trains divided by the norm of each pair
%   of spike trains, after having convolved these spike trains with a 
%   specific filter(s), specified by filters, an NxM matrix of N filters of
%   length M. Usually this filter will be a Gaussian
%   REL = CALCSEJREL(..., afpars) allows specification of analysis function
%   parameters. See SS.extractafpars documentation
    
    if nargin > 2
        [trange, rez, spktype, resprange, channels] = ...
            SS.extractafpars(varargin{1}, 1);
    else
        [trange, rez, spktype, resprange, channels] = ...
            SS.extractafpars(SS.afpars, 1);
    end
    
    %filter and channel sizes
    fsize=size(filters, 1);
    csize=size(channels, 1);

    %get spike and stim structs
    [spike stim] = SS.ReturnRanged(trange, spktype);
    
    %get spike trains
    spktrains = cell(1, csize);
    parfor x=1:length(spktrains)
        chls = channels(x, :);
        if chls(3) == 0
            spktrains{x, 1} = SS.ReturnRespSpks(spike, spike, [chls(1) chls(2)], rez, resprange);
        elseif chls(3) == 1
            spktrains{x, 1} = SS.ReturnRespSpks(spike, stim, [chls(2) chls(1)], rez, resprange);
        else
            spktrains{x, 1} = SS.ReturnRespSpks(spike, stim, [chls(1) chls(2)], rez, resprange);
        end
    end
    
    rcorr_values = zeros(csize, fsize);
    
    parfor x=1:csize
        disp(['Channel: ' num2str(x)])
        %set temp variables. spktrnset is one set of spike trains. subrcv
        %is a subset of rcorr values
        spktrnset = spktrains{x, 1};
        subrcv = zeros(1, fsize);
        for y=1:fsize
            disp(['Filter: ' num2str(y)])
            %convolve
            for z=1:size(spktrnset, 1)
                spktrnset(z, :) = conv(spktrnset(z, :), filters(y, :), 'same');
            end
            %store calc_rcorr result
            subrcv(y) = calc_rcorr(spktrnset);
        end
        %copy into rcorr_values
        rcorr_values(x, :) = subrcv;
    end
    
    rel = rcorr_values;
    
end

function rcorr = calc_rcorr(spktrains)
%CALC_RCORR Calculates rcorr value based on sejnowski paper
%   RCORR = CALC_RCORR(SPKTRAINS) calculates the rcorr value of SPKTRAINS,
%   which are spike train responses to a repeated stimulus. Refer to the
%   2003 Sejnowski paper for the reliability calculation.

    
    rcorr = 0;
    
    if isempty(spktrains)
        return;
    end
    
    %calculate spike train length, N, and calculate magnitudes vector
    stlen = size(spktrains, 1);
    n = 2/(stlen*(stlen-1));
    mag = sqrt(sum(spktrains'.^2));

    %calculate rcorr loop
    for x=1:size(spktrains, 1)-1
        if max(spktrains(x, :)) == 0
            continue;
        end
        for y=(x+1):size(spktrains, 1)
            if max(spktrains(y, :)) == 0
                continue;
            end
            a=dot(spktrains(x, :), spktrains(y, :));
            b=mag(x)*mag(y);
            rcorr = rcorr + n * (a/b);
        end
    end

end
