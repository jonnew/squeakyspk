function dap = getdap(spkhist)
%GETDAP Finds dAP(s) according to Bakkum et al. paper
%   DAP = GETDAP(SPKHIST) finds dAP(s) given a spike histogram SPKHIST. The
%   method finds peaks of the histogram, gets the highest valley left and
%   right of the peak, and returns the index of the peak if the peak is
%   2 * highest valley + .5
%   spike histograms can be made with the hist() MATLAB function

    dap = [];
    [maxima, ind] = findpeaks(spkhist);
    for x=1:length(maxima)
        %for each peak, find left valley (lv) and right valley (rv)
        %left valley
        z=ind(x)-1;
        lv = spkhist(z);
        while z > 1 && spkhist(z-1) < lv
            lv = spkhist(z-1);
            z = z - 1;
        end
        %right valley
        z=ind(x)+1;
        rv = spkhist(z);
        while z < length(spkhist) && spkhist(z+1) < rv
            rv = spkhist(z+1);
            z = z + 1;
        end
        %compare left and right valleys, pick larger value
        if lv > rv
            z = lv;
        else
            z = rv;
        end
        %if peak is 2 * highest valley + .5, then this is a dAP
        if maxima(x) > 2 * z + .5
            dap = [dap ind(x)];
        end
    end
end

