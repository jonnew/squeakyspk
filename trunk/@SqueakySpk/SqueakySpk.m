classdef SqueakySpk < handle
    %SQUEAKY SPIKE Data Class and methods for basic preprosessing of data
    %collected using extracellular, multielectrode arrays.
    
    %   Properties:
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
    %         a. BioFilt
        
    properties (SetAccess = private)
        
        % properties of data that you are cleaning [MAIN DATA]
        clean = true(length(spike.time),1); % [N BOOL (clean?, spike index)]
        time; % [N DOUBLE (sec, spike index)]
        channel; % [N INT (channel #, spike index)]
        waveform; % [M DOUBLE x N INT ([uV], spike index)]
        unit; % [N INT (unit #, spike index)]
        avgwaveform; % [M DOUBLE x K INT ([uV], unit #)]
        
        % properties of the stimulus given while collecting the main data [STIM DATA]
        st_time; % [N DOUBLE (sec, spike index)]
        st_channel; % [N INT (channel #, spike index)]
        
        % properties of the spontaneous data used for spk verification [SPONT DATA]
        sp_time; % [N DOUBLE (sec, spike index)]
        sp_channel; % [N INT (channel #, spike index)]
        sp_waveform; % [M DOUBLE x N INT ([uV], spike index)]
        sp_unit; % [N INT (unit #, spike index)]
        sp_avgwaveform; % [M DOUBLE x K INT ([uV], unit #)]
    end
    
    methods
        
        %% BLOCK 1: CONSTRUCTOR
        function SS = SqueakySpk(spike,stimulus,spontaneous)
            
            %constructor using only the spike construct (ie, the data to be
            %cleaned)
            SS.clean = true(length(spike.time),1);
            SS.time = spike.time;
            SS.channel = spike.channel;
            SS.waveform = (spike.waveform).*1000; % Assumes data is provided in mV [is this true?];
            SS.unit = [];
            
            % Load stimulus information
            if nargin < 2 || isempty (stimulus)
                SS.st_time = [];
                SS.st_channel = [];
            else
                SS.st_time = stimulus.time;
                SS.st_channel = stimulus.channel;
            end
            
            % Load spontaneous data
            if nargin < 3 || isempty (spontaneous)
                SS.sp_time = [];
                SS.sp_channel = [];
                SS.sp_waveform = [];
                SS.sp_unit = [];
            else
                SS.sp_time = spontaneous.time;
                SS.sp_channel = spontaneous.channel;
                SS.sp_waveform = spontaneous.waveform*1000;
                SS.sp_unit = zeros(length(spontaneous.time),1);
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
        end
        function RemoveSpkWithBlank(SS)
            % REMOVESPKWITHBLANK(SS) Removes all 'spikes' that have more that have 5 or more
            % voltage values in their waveform below 0.1 uV inidcating that a
            % portion of the waveform is blanked. This is extremely
            % unlikely otherwise.
            % Written by: JN  
            
            tmp = (sum(abs(SS.waveform) <= 0.1,1) >= 5);
            SS.clean = SS.clean&(~tmp');
        end
        function RemoveChannel(SS,channel2remove)
            % REMOVECHANNELS(SS,channel2remove) removes data collected on
            % channels that the experimenter knows
            % apriori are bad for some reason. channelstoremove is a
            % 1-based, linearly indexed set of channel numbers to be 
            % removed from the data. The default channels to remove are [1
            % 8 33 58 64] corresponding to the four unconnected channels
            % and the ground on a standard MCS MEA.
            % Written by: JN 
            
            if nargin < 2 || isempty(channel2remove)
                channel2remove = [1 8 33 58 64];
            end
           
            tmp = ismember(SS.channel,channel2remove);
            SS.clean = SS.clean&(~tmp);
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
            
            tmp = ismember(SS.unit,unit2remove);
            SS.clean = SS.clean&(~tmp);
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
        end
   
        %% BLOCK 3: SORTING METHODS (methods that alter the 'unit' array)
        WaveClus(SS,maxclusters,minspk,decompmeth, plotbool)
        % This method is contained in a separate file.
        
        %% BLOCK 4: ADVANCED CLEANING METHODS (methods that alter the 'clean' array, but have dependences on overloaded input properties)
        BioFilt(SS,alpha)
        % This method is contained in a separate file.
        
        %% BLOCK 5: VISUALIZATION TOOLS
        RasterWave_Comp(SS, bound, what2show, Fs)
        % This method is contained in a separate file.
        
        %% Block 6: SONIFICATION TOOLS
    end
    



    
end

