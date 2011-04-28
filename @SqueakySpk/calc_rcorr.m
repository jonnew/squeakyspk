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
    for x=1:length(spktrains)-1
        if max(spktrains(x, :)) == 0
            continue;
        end
        for y=(x+1):length(spktrains)
            if max(spktrains(y, :)) == 0
                continue;
            end
            a=dot(spktrains(x, :), spktrains(y, :));
            b=mag(x)*mag(y);
            rcorr = rcorr + n * (a/b);
        end
    end

end

