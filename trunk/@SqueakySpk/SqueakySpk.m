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
        badunit; % Array of units deemed to be bad after spike sorting
        badchannel; % Array of channels deemed to be bad
        
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
            SS.waveform = (spike.waveform(:,ind)).*1e6*SS.recunit; % Convert to uV
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
        function HardThreshold(SS,threshold)
            % HARDTHRESHOLD(SS,threshold) removes all 'spikes' with P2P amplitude
            % greater than threshold (dependent on whatever units you are
            % measuring AP's with).
            % Written by: JN and RZT
            
            % Set default threshold if non is provided
            if nargin < 2 || isempty(threshold)
                threshold = 175; %uV
            end
            
            tmp = ((max(SS.waveform) - min(SS.waveform)) < threshold);
            SS.clean = SS.clean&(tmp');
            SS.methodlog = [SS.methodlog '<HardThreshold>'];
        end
        function RemoveSpkWithBlank(SS)
            % REMOVESPKWITHBLANK(SS) Removes all 'spikes' that have more that have 5 or more
            % voltage values in their waveform below 0.1 uV inidcating that a
            % portion of the waveform is blanked. This is extremely
            % unlikely otherwise.
            % Written by: JN
            
            tmp = (sum(abs(SS.waveform) <= 0.1,1) >= 5);
            SS.clean = SS.clean&(~tmp');
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
            SS.badchannel = [SS.badchannel channel2remove];
            
            tmp = ismember(SS.channel,channel2remove);
            SS.clean = SS.clean&(~tmp);
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
            
            tmp = ismember(SS.unit,unit2remove);
            SS.clean = SS.clean&(~tmp);
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
        
        RasterWave(SS, bound, what2show, Fs)
        % This method is contained in a separate file.
        
        %% Block 7: BASIC DATA PROCESSING TOOLS
        function ASDR(SS,dt)
            % ASDR(SS,dt) Array-wide spike detection rate using time window
            % dt in seconds. This analysis is only performed on clean
            % spikes.
            
            if nargin < 2 || isempty(dt)
                dt = 1; %seconds
            end
            
            % Calculate
            bins = 0:dt:SS.time(end);
            asdr_tmp = hist(SS.time(SS.clean),bins);
            if size(asdr_tmp,2) == 1;
                SS.asdr = [bins' asdr_tmp./dt];
            else
                SS.asdr = [bins' asdr_tmp'./dt];
            end
            
            % Plot results
            figure()
            plot(SS.asdr(:,1),SS.asdr(:,2),'k');
            xlabel('Time (sec)')
            ylabel(['(' num2str(dt) 's)^-1'])
            
        end
        
        %% Block 6: SONIFICATION TOOLS
        ns = NeuroSound(SS,tbound,pbspeed,ampscale,basefreq)
        % This method is contained in a separate file.
        
        
        %% Block 7: RETURN CLEAN DATA
        function cdat = ReturnClean(SS)
            % CDAT = RETURNCLEAN(SS) return the clean data. Returns an array
            % of the format of the orginal main data input containing those
            % data indicies that have survived the cleaning process.
            
            cdat = {};
            cdat.ctime = SS.time(logical(SS.clean));
            cdat.cchannel = SS.channel(logical(SS.clean));
            cdat.cwaveform = SS.waveform(:,logical(SS.clean));
            cdat.cunit = SS.unit(logical(SS.clean));

            % Rename the clean units starting from 1
            if ~isempty(SS.unit)
                cleanunits = SS.unit(logical(SS.clean));
                cleanunitvalues = unique(cleanunits);
                for i = 1:length(cleanunitvalues )
                    cleanunits(cleanunits == cleanunitvalues(i)) = i;
                end
                cdat.cunit = cleanunits;
            end

            % Rename the clean units starting from 1
            if ~isempty(SS.unit)
                cleanunits = SS.unit(logical(SS.clean));
                cleanunitvalues = unique(cleanunits);
                for i = 1:length(cleanunitvalues )
                    cleanunits(cleanunits == cleanunitvalues(i)) = i;
                end
                cdat.cunit = cleanunits;
            end
        end
        
        %% Block 8: Save SS object
        function Save(SS)
            save([SS.name '.SS'],'SS')
        end
        
    end
    
end
