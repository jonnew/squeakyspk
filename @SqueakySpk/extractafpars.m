function [trange rez spktype resprange channelrels] = ...
            extractafpars(SS, afpars, verify)
    %EXTRACTAFPARS verifies and returns analysis function parameters
    %   [trange rez spktype resprange channelrels] = EXTRACTAFPARS(SS,
    %   afpars, verify) takes afpars, a struct containing 5 fields (the
    %   outputs of this function), and assigns each field to an output.
    %   If verify is TRUE, then the function will verify that each
    %   field is within proper parameters, and will throw an error
    %   message if they are not.
    %   TRANGE is a 1x2 matrix which indicates the range of data to
    %       look at. trange(1) <= spike and stim data < trange(2)
    %   REZ is resolution of data at 1/rez milliseconds
    %   SPKTYPE specifies type of spike data to look at; 'clean',
    %       'dirty', or 'both'
    %   RESPRANGE is the maximum time after a stimulus that a response
    %       occurs, in ms.
    %   CHANNELRELS is an Nx3 matrix with column 1 indicating the
    %       stimulating channel, column 2 indicating the responding
    %       channel, and column 3 indicating whether to compare
    %       spike-spike, spike-stim, or stim-spike, represented by 0, 
    %       1, and 2, respectively. For example, [7 13 1] would
    %       indicate that the analysis functions should use the spike
    %       data on channel 7 and stim data on channel 13

        trange = afpars.trange;
        rez = afpars.rez;
        spktype = afpars.spktype;
        resprange = afpars.resprange;
        channelrels = afpars.channelrels;

        emsg = '';
        if verify
            if numel(trange) ~= 2 || trange(1) < 0 || ...
                    trange(2) > SS.time(end)
                emsg = [emsg; 'invalid trange data'];
            end
            if ~isscalar(rez) || rez < 1/SS.time(end)*1000 || ...
                    rez > SS.fs/1000
                emsg = [emsg; 'invalid rez data'];
            end
            if ~ischar(spktype) || ~any(strcmp(spktype, {'clean', ...
                    'dirty', 'both'}))
                emsg = [emsg; 'invalid spktype data'];
            end
            if ~isscalar(resprange) || resprange < 0 || ...
                    resprange > SS.time(end)
                emsg = [emsg; 'invalid resprange data'];
            end
            if size(channelrels, 2) ~= 3 || ...
                    sum(~ismember(unique(channelrels(:, 1)), ...
                    unique(SS.channel))) || ...
                    sum(~ismember(unique(channelrels(:, 2)), ...
                    unique(SS.channel))) || ...
                    sum(~ismember(unique(channelrels(:, 3)), [0 1 2]))
                emsg = [emsg; 'invalid channelrels data'];
            end

            if ~isempty(emsg)
                disp(emsg);
            end
        end
    end