classdef (ConstructOnLoad = false) SqueakySpk < handle
% SQUEAKYSPK is a data class and methods for basic preprocessing of data
% collected using extracellular, multielectrode arrays.To use SqueakySpk,
% look at ReadMe.txt and testscript.m that were provided with this package.
% Additionally,
% 
%     1. For a full list of PROPERTIES type properties('SqueakySpk') into
%     the command line. 
%     2.  For a full list of METHODS type methods('SqueakySpk') into the
%     command line. To access help on a particular method, type help 
%     <methodname> into the command line.
% 
%   --
% 
% The following lists may not be up to date. Use the above methods for up
% to date lists of methods and properties
%
%   PROPERTIES: 
%
%   - For a full list of properties type properties('SqueakySpk') into the
%   command line.
%
%   1. Metadata
%       a. name; % String that names the data object
%       b. fs; % sampling rate for data collection in Hz
%       c. recunit; % This is a scaling factor for spike waveform data. It
%       is the fraction of volts that the waveform data is provided in. For
%       instance, if data are in volts, then recunit = 1. If in millivolts,
%       then recunit = 1/1000 = 0.001
%       d. tor; % time of recording. Specified by user after object
%       construction.
%       e. age; % age of preperation. Useful for in-vitro studies. Specified by user after object
%       construction.
%
%   2. Properties of data that you are cleaning
%       a. clean; % [N BOOL (clean?, spike index)]  (sec, spike index)] 
%       c. channel; % [N INT (channel #, spike index)] 
%       d. waveform; % [M DOUBLE x N INT ([uV], spike index)] 
%       e. unit; % [N INT (unit #, spike index)] 
%       f. avgwaveform; % [M DOUBLE x K INT ([uV], unit #)] 
%       g. asdr; % Array-wide spike detection rate matrix [[bins] [count]] 
%       h. badunit; % Array of units deemed to be bad after spike sorting 
%       i. badchannel; % Array of channels deemed to be bad 
%       j. etc - further properties are filled in by
%         running specific analysis methods. Type help <methodname> to
%         investigate what property a method modifies.
%
%   3. properties of stimuli
%       a. st_time; % [K DOUBLE (sec, spike index)]
%     	b. st_channel; % [K INT (channel #, spike index)]
%       c. st_type; % [K TYPE (aux. info about each stimulus. TYPE can be
%       anything.)]
%
%   4. Methods log
%       a. methodlog; % string array that keeps track of the methods run on
%       the SS object
%
%   5. Analysis properties used by analysis functions like CAT, dAP, etc.
%   Refer to specific function documentation for more info
%       a. analysispars;
%
%   METHODS: 
%   - For a full list of methods type methods('SqueakySpk') into the
%   command line. 
%   - To access help on a particular method, type help <methodname> into
%   the command line.
    
    properties (SetAccess = public)
        
        % Data name and parameters of recording
        name; % String that names the data object
        fs; % frequency
        recunit; % Unit that the users data is provided in as a fraction of volts (1-> volts, 0.001 -> millivolts, etc).
        
        % recording properities
        tor; % time of recording
        age; % age of culture, in seconds
        
        % properties of data that you are cleaning [MAIN DATA]
        clean; % [N BOOL (clean?, spike index)]
        time; % [N DOUBLE (sec, spike index)]
        channel; % [N INT (channel #, spike index)]
        waveform; % [M DOUBLE x N INT ([uV], spike index)]
        waveform_us;% [M DOUBLE x N INT ([uV], spike index)], upsampled waveforms, dirty indices are 0's
        waveform_us_t;% [N DOUBLE (microseconds from peak for upsampled waveforms)]
        unit; % [N INT (unit #, spike index)]
        avgwaveform; % {avg:[M DOUBLE x K INT ([uV], unit #)],sd[M DOUBLE x K INT ([uV], unit #)]}
        asdr; % Array-wide spike detection rate matrix [[bins] [count]]
        csdr; % Channel spike detection rate matrix [[bins] [count_1] [count_2] ...]
        usdr; % Unit spike detection rate structure
        bi; % burstiness index as defined by Wagenaar
        badunit; % Array of units deemed to be bad after spike sorting
        badchannel; % Array of channels deemed to be bad
        psh; % Peri-stimulus histogram
        upsh; % unit-wise peri-stimulus histogram
        unitfr; % the sorted average firing rate of each unit
        
        % properties of the stimulus given while collecting the main data
        % [STIM DATA]
        st_time; % [K DOUBLE (sec, spike index)]
        st_channel; % [K INT (channel #, spike index)]
        st_type; % [K TYPE (aux. info about each stimulus. TYPE can be anything.)]
        
        % Methods log
        methodlog; % string array that keeps track of the methods run on the SS object
        
        % Analysis parameters
        analysispars; % refer to ReturnAnalysisPars for doc
        
        % Stuff filled by running xcorrs
        xcorrmat;%[N x M x P xQ double (timeslice, 'causal' channel, 'effect' channel, offset (ms)]
        %cross correlation between spikes on different channels and stimuli
        %on different channels.  Each cross correlation is calculated using
        %XBIN seconds of data (a 'timeslice').
        
        xcount;%[N x M int (timeslice, 'causal' channel count)]
        %the number of times this channel was active.  Stimulating
        %electrodes are index +64
        
        xbin;%[INT (length of each timeslice in s)]
        %the duration of a timeslice, in seconds
        
        xrez;%[DOUBLE (resolution of offsets, in ms)]
        %the resolution of the cross correlation
        xauto;
    end
    
    methods
        
        %% BLOCK 1: CONSTRUCTOR
        function SS = SqueakySpk(name,fs,recunit,spike,stimulus)
        % SQUEAKYSPK(NAME, FS, RECUNIT, SPIKE) constructs a squeaky spike
        % object. The first four arguments are required. NAME is a string
        % that provides the SS object with a name. FS is the sampling
        % frequency used to collect spiking informaiton in Hz. RECUNIT is a
        % scaling factor for spike waveform data. It is the fraction of
        % volts that the waveform data is provided in. For instance, if
        % data are in volts, then recunit = 1. If in millivolts, then
        % recunit = 1/1000 = 0.001. SPIKE is the spike data structure of
        % the form:
        %
        %   spike.time = [NX1] vector of spike times in seconds
        %   spike.unit = [NX1] vector of sported unit numbers 
        %   spike.channel = [NX1] vector of corresponding channels
        %   spike.waveform = [NXM] matrix of corresponding spike snippet 
        %   waveforms
        %
        % SQUEAKYSPK(..., STIMULUS) constructs a SQUEAKYSPK object using
        % additional arguments for a stimulus data structure of the form:
        %
        %   stimulus.time = [RX1] vector of spike times in seconds
        %   stimulus.channel = [RX1] vector of corresponding stimulation 
        %   channels.

            % Check input arguments
            if nargin < 4
                error('Minimal arguements to create an SS object are (1) a name string, (2) the sampling frequency, (3) units used for recording as a fraction of Volts, and (4) a spike data structure.')
            end
            if nargin == 5
                if (min(spike.channel) < 0) || (min(stimulus.channel) < 0)
                    error('A channel entry on one of your input structures has a negative value. Channels should be 1-based integers.')
                end
            end
            if nargin == 6
                if min(spike.channel) < 0 || min(stimulus.channel) < 0 || min(spontaneous.channel) < 0
                    error('A channel entry on one of your input structures has a negative value. Channels should be 1-based integers.')
                end
            end
            if min(spike.time) < 0
                error('Your spike.time arguement has a negative entry')
            end
            
            % String with name of data
            SS.name = name;
            
            % Sampling frequency
            SS.fs = fs;
            
            % Recording unit
            SS.recunit = recunit;
            
            %constructor using only the spike construct (ie, the data to be
            %cleaned)
            SS.clean = true(length(spike.time),1);
            [SS.time ind] = sort(spike.time); % Make sure incoming data is sorted in time
            if min(spike.channel) == 0 % channel index is 1 based
                warning('Channel index must be 1 based in an SS object, shifting your SS.channel property by 1');
                SS.channel = spike.channel(ind)+1;
            else
                SS.channel = spike.channel(ind);
            end
            if  isfield(spike, 'waveform') && size(spike.waveform,2) > 0 %allow for spike files with no waveforms to be uploaded
                SS.waveform = (spike.waveform(:,ind)).*1e6*SS.recunit; % Convert to uV
            end
            if isfield(spike,'unit')
                SS.unit = spike.unit(ind);
            else
                SS.unit = [];
            end
            SS.methodlog = [];
            SS.badunit = [];
            SS.badchannel = [];
            
            %Analysis parameters defaults. Refer to ReturnAnalysisPars for
            %more info
            SS.analysispars = ...
                struct('trange', [0 SS.time(end)], ...
                'rez', 1, ...
                'spktype', 'clean', ...
                'resprange', .025, ...
                'channelrels', zeros(0, 3));
            
            % Load stimulus information
            if nargin < 5 || isempty (stimulus)
                SS.st_time = [];
                SS.st_channel = [];
            else
                usetype = 0;
                if isfield(stimulus, 'type')
                    if ~isempty(stimulus.type)
                        usetype = 1;
                    end
                end
                if usetype
                    SS.st_time = stimulus.time;
                    SS.st_channel = stimulus.channel;
                    if min(stimulus.channel) == 0
                        SS.st_channel = SS.st_channel+1;
                    end
                    SS.st_type = stimulus.type;
                    
                else
                    SS.st_time = stimulus.time;
                    SS.st_channel = stimulus.channel;
                    if min(stimulus.channel) == 0
                        SS.st_channel = SS.st_channel+1;
                    end
                    SS.st_type = [];
                end
            end
            
            % END CONSTRUCTOR
            
        end
        
        %% BLOCK 2: CLEANING METHODS (methods that alter the 'clean' array)
        HardThreshold(SS,highThreshold,lowThreshold)
        % This method is contained in a separate file.
        
        RemoveBySymmetry(SS,maxWaveSymmetry)
        % This method is contained in a separate file.
        
        RemoveSpkWithBlank(SS)
        % This method is contained in a separate file.
        
        RemoveChannel(SS,channel2remove)
        % This method is contained in a separate file.
        
        RemoveUnit(SS,unit2remove)
        % This method is contained in a separate file.
        
        MitraClean(SS)
        % This method is contained in a separate file.
        
        ResetClean(SS)
        % This method is contained in a separate file.
        
        AmpSel(SS,threshold)
        % This method is contained in a separate file.
        
        PkTrSel(SS,width)
        % This method is contained in a separate file.
        
        MinCheck(SS,mintime)
        % This method is contained in a separate file.
        
        Crossing(SS,th)
        % This method is contained in a separate file.
        
        MaxMinCheck(SS,th)
        % This method is contained in a separate file.
        
        PkVelocity(SS,th)
        % This method is contained in a separate file.
        
        UpSamp(SS,us,pkalign,tpre,tpost,threshold)
        % This method is contained in a separate file.
        
        MUA(SS)
        % This method is contained in a separate file.
        
        PlotWfs(SS,maxwfs,chan)
        % This method is contained in a separate file.
        
        %% BLOCK 3: SORTING METHODS (methods that alter the 'unit' array)
        suc = WaveClus(SS,maxclusters,minspk,decompmeth,plotall,ploton)
        % This method is contained in a separate file.
        
        LineSort(SS,ylimit,numWaves2Plot);
        % This method is contained in a separate file.
        
        %% BLOCK 4: ADVANCED CLEANING METHODS (methods that alter the 'clean' array, but have dependences on overloaded input properties or sorting)
        WeedUnitByWaveform(SS)
        % This method is contained in a separate file.
        
        %% BLOCK 5: VISUALIZATION TOOLS
        PlotAvgWaveform(SS)
        % This method is contained in a separate file.
        
        RasterPlot(SS, bound, what2show, yaxischannel)
        % This method is contained in a separate file.
        
        RasterWave(SS, bound, what2show, yaxischannel)
        % This method is contained in a separate file.
        
        PlotPeriStimHistogram(SS)
        % This method is contained in a separate file.
        
        q = PlotUnitWisePSH(SS,frmax,include0)
        % This method is contained in a separate file.
        
        RandScat(SS,bound,forcechannel,sortu,sortbound)
        % This method is contained in a separate file.
        
        PlotCSDR(SS,frmax)
        % This method is contained in a separate file.
        
        PlotUSDR(SS,frmax,sortu,sortbound,showscale)
        % This method is contained in a separate file.
        
        PlotCSDRHist(SS,binsize,maxdr)
        % This method is contained in a separate file.
        
        PlotRandomWaveform(SS,plotall,N,rangeV,bound)
        % This method is contained in a separate file.
        
        DemarseActivityPlot(SS,t,tau,dilation,name)
        % This method is contained in a separate file.
        
        %% Block 7: BASIC DATA PROCESSING TOOLS
        ASDR(SS,dt,bound,whichchan,shouldplot,loglin,ymax);
        % This method is contained in a separate file.
        
        BI(SS,bound);
        % This method is contained in a separate file.
        
        catmat = CATr(SS, movtimebin, timewindow, bmode, varargin)
        % This method is contained in a separate file.
        
        dapmat = DAP(SS, varargin)
        % This method is contained in a separate file.
        
        PeriStimHistogram(SS,dt,histrange,whichstim,ploton);
        % This method is contained in a separate file.
        
        q = UnitWisePSH(SS,dt,histrange,whichstim,which,effrange,forcechan,ploton);
        % This method is contained in a separate file.
        
        PeriStimRaster(SS,bound,dur,ch,ti);
        % This method is contained in a separate file.
        
        PeriSpikeRaster(SS,unit,bounds,dur);
        % This method is contained in a separate file.
        
        rel = SejReliability(SS, filters, varargin);
        % This method is contained in a separate file.
        
        xcorrmat = XCorr(SS, varargin)
        % This method is contained in a separate file.
        
        [result counts]=XCorrs(SS, mintime, maxtime, binlength, xcorlength, xcorrez);
        % This method is contained in a separate file.
        
        XCorrFilm(SS,name,tasks, fps);
        % This method is contained in a separate file.
        
        latmat = LatencyMatrix(SS,bound,dur);
        % This method is contained in a separate file.
        
        UnitFR(SS,bound,units);
        % This method is contained in a separate file
        
        %% Block 6: SONIFICATION TOOLS
        ns = NeuroSound(SS,tbound,pbspeed,ampscale,basefreq,scale,env,sniplength, fid)
        % This method is contained in a separate file.
        
        dh = DishHRTF(SS,fs,pbloc,times,chind)
        % This method is contained in a separate file.
        
        %% Block 7: RETURN CLEAN DATA
        sqycln = ReturnClean(SS,bound)
        % This method is contained in a separate file.
        
        %% Block 8: SAVE SS OBJECT
        Save(SS,auxfid)
        % This method is contained in a separate file.
        
        %% Block 9: INTERNAL METHODS
        [spike stim] = ReturnRangedData(SS, varargin)
        % This method is contained in a separate file.
        
        spktrains = ReturnPeriStimSpkTrains(SS, spike, stim, ...
            channelpair, rez, varargin)
        % This method is contained in a separate file.
        
        spks = return_spksinrange(SS, spikes, stim, resprange)
        % This method is contained in a separate file.
        
        [trange rez spktype resprange channelrels] = ...
            ReturnAnalysisPars(SS, verify, varargin)
        % This method is contained in a separate file.
        
    end
    
end

