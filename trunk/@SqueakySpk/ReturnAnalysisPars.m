function [trange rez spktype resprange channelrels] = ...
            ReturnAnalysisPars(SS, verify, varargin)
    %RETURNANALYSISPARS verifies and returns analysis function parameters
    %   [trange rez spktype resprange channelrels] = RETURNANALYSISPARS(SS,
    %   afpars, verify) takes analysispars, a struct containing 5 fields
    %   (outputs of this function), and assigns each field to an output.
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

        trange = [];
        rez = [];
        spktype = [];
        resprange = [];
        channelrels = [];

        if nargin > 3
            trange = varargin{1};
            rez = varargin{2};
            spktype = varargin{3};
            resprange = varargin{4};
            channelrels = varargin{5};
            anaylsispars = SS.analysispars;
        else
            if isempty(varargin{1})
                SS.analysispars = ...
                    struct('trange', [0 SS.time(end)], ...
                           'rez', 1, ...
                           'spktype', 'clean', ...
                           'resprange', .025, ...
                           'channelrels', zeros(0, 3));
                       analysispars = SS.analysispars;
            else
                analysispars = varargin{1};
            end
        end
 
        if isempty(trange)
            trange = analysispars.trange;
        end
        if isempty(rez)
            rez = analysispars.rez;
        end
        if isempty(spktype)
            spktype = analysispars.spktype;
        end
        if isempty(resprange)
            resprange = analysispars.resprange;
        end
        if isempty(channelrels)
            channelrels = analysispars.channelrels;
        end

        if verify
            emsg = '';
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