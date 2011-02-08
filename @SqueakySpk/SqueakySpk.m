classdef (ConstructOnLoad = false) SqueakySpk < handle
    %SQUEAKYSPK data class and methods for basic preprosessing of data
    %collected using extracellular, multielectrode arrays.
    %
    %   Properties:
    %   1. Data name
    %       a. name; % String that names the data object
    %
    %   2. Properties of data that you are cleaning [MAIN DATA]
    %         a. clean; % [N BOOL (clean?, spike index)]
    %         b. time; % [N DOUBLE (sec, spike index)]
    %         c. channel; % [N INT (channel #, spike index)]
    %         d. waveform; % [M DOUBLE x N INT ([uV], spike index)]
    %         e. unit; % [N INT (unit #, spike index)]
    %         f. avgwaveform; % [M DOUBLE x K INT ([uV], unit #)]
    %         g. asdr; % Array-wide spike detection rate matrix [[bins] [count]]
    %         h. badunit; % Array of units deemed to be bad after spike sorting
    %         i  badchannel; % Array of channels deemed to be bad
    %
    %   3. properties of the stimulus given while collecting the main data [STIM DATA]
    %       a. st_time; % [N DOUBLE (sec, spike index)]
    %     	b. st_channel; % [N INT (channel #, spike index)]
    %
    % 	4. properties of the spontaneous data used for spk verification [SPONT DATA]
    %   	a. sp_time; % [N DOUBLE (sec, spike index)]
    %    	b. sp_channel; % [N INT (channel #, spike index)]
    %    	c. sp_waveform; % [M DOUBLE x N INT ([uV], spike index)]
    %    	d. sp_unit; % [N INT (unit #, spike index)]
    %    	e. sp_avgwaveform; % [M DOUBLE x K INT ([uV], unit #)]
    %
    %   4. Methods log
    %       a. methodlog; % string array that keeps track of the methods run on the SS object
    %
    %   Methods:
    %     1. Constructor
    %         a. SqueakySpk
    %     2. Basic Cleaning
    %         a. HardThreshold
    %         b. RemoveSpkWithBlank
    %         c. RemoveChan
    %         d. RemoveUnit
    %         e. MitrClean
    %     3. Spike Sorting
    %         a. WaveClus
    %     4. Advanced Cleaning
    %         a. WeedUnitByWaveform
    %     5. Analysis
    %     6. Sonification
    %     7. Returning clean data
    %     8. Saving
    %
    %   To use SqueakySpk, look at ReadMe.txt that came with this package,
    %   look at the testscript and examine the help for each method by
    %   typing help methodname in the command promp.
    
    properties (SetAccess = public)
        
        % Data name and parameters of recording
        name; % String that names the data object
        fs;
        recunit; % Unit that the users data is provided in as a fraction of volts (1-> volts, 0.001 -> millivolts, etc).
        
        % properties of data that you are cleaning [MAIN DATA]
        clean; % [N BOOL (clean?, spike index)]
        time; % [N DOUBLE (sec, spike index)]
        channel; % [N INT (channel #, spike index)]
        waveform; % [M DOUBLE x N INT ([uV], spike index)]
        unit; % [N INT (unit #, spike index)]
        avgwaveform; % {avg:[M DOUBLE x K INT ([uV], unit #)],sd[M DOUBLE x K INT ([uV], unit #)]}
        asdr; % Array-wide spike detection rate matrix [[bins] [count]]
        csdr; % Channel spike detection rate matrix [[bins] [count_1] [count_2] ...]
        bi; % burstiness index as defined by Wagenaar
        badunit; % Array of units deemed to be bad after spike sorting
        badchannel; % Array of channels deemed to be bad
        psh; % Peri-stimulus histogram
        
        % properties of the stimulus given while collecting the main data [STIM DATA]
        st_time; % [N DOUBLE (sec, spike index)]
        st_channel; % [N INT (channel #, spike index)]
        
        % properties of the spontaneous data used for spk verification [SPONT DATA]
        sp_time; % [N DOUBLE (sec, spike index)]
        sp_channel; % [N INT (channel #, spike index)]
        sp_waveform; % {avg:[M DOUBLE x K INT ([uV], unit #)],sd[M DOUBLE x K INT ([uV], unit #)]}
        sp_unit; % [N INT (unit #, spike index)]
        sp_avgwaveform; % [M DOUBLE x K INT ([uV], unit #)]
        
        % Methods log
        methodlog; % string array that keeps track of the methods run on the SS object
        
        % Stuff filled by running xcorrs
        xcorrmat;%[N x M x P xQ double (timeslice, 'causal' channel, 'effect' channel, offset (ms)]
        %cross correlation between spikes on different channels and
        %stimuli on different channels.  Each cross correlation is
        %calculated using XBIN seconds of data (a 'timeslice').
        
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
        function SS = SqueakySpk(name,fs,recunit,spike,stimulus,spontaneous)
            % SQUEAKYSPK SS object constructor. The first four arguments are
            % required. They are a name for the object that you are about
            % to create, the sampling frequency in Hz, fs, fraction of volts
            % that the waveform data is provided in,and the data structure, spike, of the form:
            %   spike.time = [NX1] vector of spike times in seconds
            %   spike.channel = [NX1] vector of corresponding channels
            %   spike.wavefomr = [NXM] matrix of corresponding spike snip waveforms
            % Addtional arguments for a stimulus data structure of the
            % form:
            %   stimulus.time = [RX1] vector of spike times in seconds
            % stimulus.channel = [RX1] vector of corresponding channels
            % And spontanous data taken before and evoked recording,
            % with the same fields as the spike structure.
            
            if nargin < 4
                error('You must provide (1) a name string, (2) the sampling frequency, (3) units used for recording as a fraction of Volts, and (3) a spike data structure.')
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
            [SS.time ind] = sort(spike.time); % Make sure incoming data
            if min(spike.channel) == 0 % channel index is 1 based
                SS.channel = spike.channel(ind)+1;
            else
                SS.channel = spike.channel(ind);
            end
            if size(spike.waveform,2)>0 %allow for spike files with no waveforms to be uploaded
                SS.waveform = (spike.waveform(:,ind)).*1e6*SS.recunit; % Convert to uV
            end
            SS.unit = [];
            SS.methodlog = [];
            SS.badunit = [];
            SS.badchannel = [];
            
            % Load stimulus information
            if nargin < 5 || isempty (stimulus)
                SS.st_time = [];
                SS.st_channel = [];
            else
                SS.st_time = stimulus.time;
                SS.st_channel = stimulus.channel;
            end
            
            % Load spontaneous data
            if nargin < 6 || isempty (spontaneous)
                SS.sp_time = [];
                SS.sp_channel = [];
                SS.sp_waveform = [];
                SS.sp_unit = [];
            else
                [SS.sp_time ind] = sort(spontaneous.time);
                if min(spontaneous.channel) == 0 % channel index is 1 based
                    SS.sp_channel = spontaneous.channel(ind)+1;
                else
                    SS.sp_channel = spontaneous.channel(ind);
                end
                SS.sp_waveform = (spontaneous.waveform(:,ind)).*1e6*SS.recunit;
                SS.sp_unit = [];
            end % END CONSTRUCTOR
            
        end
        
        %% BLOCK 2: CLEANING METHODS (methods that alter the 'clean' array)
        function HardThreshold(SS,highThreshold,lowThreshold)
            % HARDTHRESHOLD(SS,highThreshold,lowThreshold) removes all 'spikes'
            % with P2P amplitude greater/less than high/low threshold
            % (dependent on whatever units you are measuring AP's with).
            % Written by: JN and RZT
            
            % Set default thresholds if non are provided
            if nargin < 2 || isempty(highThreshold)
                highThreshold = 175; %uV
            end
            if nargin < 3 || isempty(lowThreshold)
                lowThreshold = 0; %uV
            end
            
            dirty = ((max(SS.waveform) - min(SS.waveform)) > highThreshold | (max(SS.waveform) - min(SS.waveform)) < lowThreshold);
            if ~isempty(dirty)
                SS.clean = SS.clean&(~dirty');
            end
            
            SS.methodlog = [SS.methodlog '<HardThreshold>'];
        end
        function RemoveBySymmetry(SS,maxWaveSymmetry)
            % REMOVEBYSYMMETRY(SS,maxWaveSymmetry) takes the ratio of the
            % maximal postive and negative deflections of a waveform about
            % its mean (DC) offset and compares this to maxWaveSymmetry
            % (which is between 0 and 1). If the ratio is larger than
            % maxWaveSymmetry, the spike is rejected.
            % Written by: JN
            
            if maxWaveSymmetry > 1 || maxWaveSymmetry <0
                error(' The arguement maxWaveSymmetry must be a ratio between 0 and 1')
            end
            
            meanAmplitude = mean(SS.waveform,1);
            maxAmplitude = abs(max(SS.waveform,[],1) - meanAmplitude);
            minAmplitude = abs(min(SS.waveform,[],1)  - meanAmplitude);
            numeratorOverDenominator = sort([maxAmplitude; minAmplitude],1);
            symRatio = numeratorOverDenominator(1,:)./numeratorOverDenominator(2,:);
            dirty = symRatio > maxWaveSymmetry;
            
            if ~isempty(dirty)
                SS.clean = SS.clean&(~dirty');
            end
            SS.methodlog = [SS.methodlog '<RemoveBySymmetry>'];
        end
        function RemoveSpkWithBlank(SS)
            % REMOVESPKWITHBLANK(SS) Removes all 'spikes' that have more that have 5 or more
            % voltage values in their waveform below 0.1 uV inidcating that a
            % portion of the waveform is blanked. This is extremely
            % unlikely otherwise.
            % Written by: JN
            
            dirty = (sum(abs(SS.waveform) <= 0.1,1) >= 5);
            if ~isempty(dirty)
                SS.clean = SS.clean&(~dirty');
            end
            SS.methodlog = [SS.methodlog '<RemoveSpkWithBlank>'];
        end
        function RemoveChannel(SS,channel2remove)
            % REMOVECHANNELS(SS,channel2remove) removes data collected on
            % channels that the experimenter knows
            % apriori are bad for some reason. channelstoremove is a
            % 1-based, linearly indexed set of channel numbers to be
            % removed from the data. The default channels to remove are [1
            % 8 33 57 64] corresponding to the four unconnected channels
            % and the ground on a standard MCS MEA.
            % Written by: JN
            
            if nargin < 2 || isempty(channel2remove)
                channel2remove = [1 8 33 57 64];
            end
            
            % Append the badchannel vector
            SS.badchannel = unique([SS.badchannel channel2remove]);
            
            dirty = ismember(SS.channel,channel2remove)';
            if ~isempty(dirty)
                SS.clean = SS.clean&(~dirty');
            end
            
            SS.methodlog = [SS.methodlog '<RemoveChannel>'];
        end
        function RemoveUnit(SS,unit2remove)
            % REMOVEUNIT(unit2remove) removes all a spikes with ID in the
            % unit2remove vector from the clean array. Default is to remove
            % all unsorted 'spikes'.
            % Written by: JN
            
            if nargin < 2 || isempty(unit2remove)
                unit2remove = 0;
            end
            if isempty(SS.unit)
                error('You have not clustered your data yet and unit information is not available.')
            end
            
            % Append the badunit vector
            SS.badunit = [SS.badunit unit2remove];
            
            dirty = ismember(SS.unit,unit2remove);
            if ~isempty(dirty)
                SS.clean = SS.clean&(~dirty);
            end
            SS.methodlog = [SS.methodlog '<RemoveUnit>'];
        end
        function MitraClean(SS)
            % MITRA CLEAN(SS) removes all spikes that have multiple peaks
            % effective at removing noise, many stimulus artifacts
            % still get through
            %
            % probably not optimal code, but this will work
            %
            % needs edit so that it doesn't care about minor ripples in the
            % main peak
            %
            %will remove compound APs if they are less than 1ms apart
            % Written by: RZT
            
            true_wave = ones(length(SS.waveform),1);
            
            for ind = 1:length(SS.waveform)
                wave = SS.waveform(:,ind);%examine this particular waveform
                [d i] = max(abs(wave));
                d = wave(i); %get the peak amplitude, including the sign
                pos = (d>0);
                pos = pos*2-1;% -1 means negative, 1 means positive
                low =i-25;%need to specify the region of interest- 25 samples on either side of the peak
                if low<1;
                    low = 1;
                end
                high = i+25;
                if high>75
                    high = 75;
                end
                %look for peaks on either side of the main peak
                dt =diff(wave);
                
                %find the valleys on either side of the main peak
                up = dt(i+1:high-1);
                down = dt(low:i-1);
                bup = find(up*pos>0);
                bdown = find(-down*pos>0);
                
                %if a valley is found, check to see if other peaks after
                %this valley are equal to half the amplitude of the main
                %peak
                if ~isempty(bup)
                    bu = bup(1);
                    %plot(i+bu,wave(i+bu),'.b');
                    if max(wave(i+bu:high)*pos)>d*pos/2
                        true_wave(ind) = 0;
                    end
                end
                
                %look to see if the first peak before the main peak exceeds
                %threhold:
                if ~isempty(bdown)
                    bd = bdown(length(bdown));
                    %plot(bd+low,wave(bd+low),'.m');
                    if max(wave(low:bd+low)*pos)>d*pos/2
                        true_wave(ind) = 0;
                    end
                end
                %                 if true_wave(ind)
                %                     figure(1);hold on;plot(wave);
                %                 else
                %                     figure(2);hold on; plot(wave);
                %                 end
            end
            SS.clean = SS.clean&true_wave;
            %                 size(SS.clean)
            %                 size(true_wave)
            SS.methodlog = [SS.methodlog '<Mitraclean>'];
        end
        function ResetClean(SS)
            % RESETCLEAN(SS) Resets the clean, badunit and badchannel arrays
            % so nothing is cleaned.
            % Written by: JN
            
            SS.clean = true(length(SS.time),1);
            SS.badchannel = [];
            SS.badunit = [];
            SS.methodlog = [SS.methodlog '<ResetClean>'];
            
        end
        
        %% BLOCK 3: SORTING METHODS (methods that alter the 'unit' array)
        WaveClus(SS,maxclusters,minspk,decompmeth,plotbool)
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
        
        RandScat(SS,bound,forcechannel)
        % This method is contained in a separate file.
        
        CSDR(SS)
        % This method is contained in a separate file.
        
        q = PlotRandomWaveform(SS,N,rangeV)
        % This method is contained in a separate file.
        
        DemarseActivityPlot(SS,t,tau,dilation,name)
        %contained in a separate file- t is a 2d vector containing the
        %start and stop times, tau is the time constant of the image,
        %dilation is the time dilation
        
        %% Block 7: BASIC DATA PROCESSING TOOLS
        ASDR(SS,dt,shouldplot);
        % This method is contained in a separate file.
 
        BI(SS);
        % This method is contained in a separate file.

        PeriStimHistogram(SS,dt,histrange,bound,ploton);
        % This method is contained in a separate file.
        
        [result counts]=XCorrs(SS, mintime, maxtime, binlength, xcorlength, xcorrez);
        % This method is contained in a separate file.
        
        XCorrFilm(SS,name,tasks, fps);
        % This method is contained in a separate file.
        
        %% Block 6: SONIFICATION TOOLS
        ns = NeuroSound(SS,tbound,pbspeed,ampscale,basefreq,scale,savewav)
        % This method is contained in a separate file.
        
        %% Block 7: RETURN CLEAN DATA
        function sqycln = ReturnClean(SS)
            % SQYCLN = RETURNCLEAN(SS) return the clean data. Returns an array
            % of the format of the orginal main data input containing those
            % data indicies that have survived the cleaning process.
            
            sqycln = {};
            sqycln.time = SS.time(logical(SS.clean));
            sqycln.channel = SS.channel(logical(SS.clean));
            sqycln.waveform = SS.waveform(:,logical(SS.clean));
            
            % Rename the clean units starting from 1
            if ~isempty(SS.unit)
                cleanunits = SS.unit(logical(SS.clean));
                cleanunitvalues = unique(cleanunits);
                for i = 1:length(cleanunitvalues )
                    cleanunits(cleanunits == cleanunitvalues(i)) = i;
                end
                sqycln.unit = cleanunits;
            end
        end
        
        %% Block 8: Save SS object
        function Save(SS)
            save([SS.name '.SS'],'SS')
        end
        
    end
    
end

