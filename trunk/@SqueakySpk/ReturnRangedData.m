function [spike stim] = ReturnRangedData(SS, varargin)
%RETURNRANGEDDATA returns ranged spike and stim data
%   [spike stim] = RETURNRANGEDDATA(SS) returns spike and stim data as
%   structs within range [SS.afpars.trange(1) SS.afpars.trange(2)).
%
%   RETURNRANGEDDATA(..., trange, spktype) specifies the time range and
%   spike type, and does not overwrite the field in SS.analysispars

    error(nargchk(1, 3, nargin, 'struct'));

    %defaults to SS properties
    trange = SS.analysispars.trange;
    spktype = SS.analysispars.spktype;

    %check input parameters
    for x=1:length(varargin)
        if isempty(varargin{x}) 
            continue;
        elseif ischar(varargin{x})
            spktype = varargin{x};
        elseif isa(varargin{x}, 'double')
            trange = varargin{x};
        else
            error('input data not valid');
        end
    end

    %get indices for all spikes within range
    a = find(SS.time >= trange(1), 1);
    b = find(SS.time < trange(2), 1, 'last');
    ind = a:b;

    %return clean or dirty spikes
    if strcmp(spktype, 'clean') 
        ind = ind(logical(SS.clean(a:b)));
    elseif strcmp(spktype, 'dirty')
        ind = ind(logical(~SS.clean(a:b)));
    end

    spike.time = SS.time(ind);
    spike.channel = SS.channel(ind);
    if ~isempty(SS.waveform)
        spike.waveform = SS.waveform(:, ind);
    end

    %get and return indices for all stims within range
    a = find(SS.st_time >= trange(1), 1);
    b = find(SS.st_time < trange(2), 1, 'last');

    stim.time = SS.st_time(a:b);
    stim.channel = SS.st_channel(a:b);
end