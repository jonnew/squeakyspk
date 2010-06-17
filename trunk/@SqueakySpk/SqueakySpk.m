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
    %         b. PassOver
    %         c. RemoveChan
    %     3. Spike Sorting
    %         a. WaveClus
    %     4. Advanced Cleaning
    %         a. BioFilt
        
    properties (SetAccess = private)
        
        % properties of data that you are cleaning [MAIN DATA]
        clean = true(length(spike.time),1); % [BOOL]
        time; % [DOUBLE, seconds]
        channel; % [INT]
        waveform; % [DOUBLE, mV]
        unit; % [INT]
        
        % properties of the stimulus given while collecting the main data [STIM DATA]
        st_time; % [DOUBLE, seconds]
        st_channel; % [INT]
        
        % properties of the spontaneous data used for spk verification [SPONT DATA]
        sp_time; % [DOUBLE, seconds]
        sp_channel; % [INT]
        sp_waveform; % [DOUBLE, mV]
        sp_unit; % [INT]
        
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
            % HARDTHRESHOLD removes all 'spikes' with P2P amplitude
            %greater than threshold (dependent on whatever units you are
            %measuring AP's with).
            
            % Set default threshold if non is provided
            if nargin < 2 || isempty(threshold)
                threshold = 175; %uV
            end
            
            tmp = ((max(SS.waveform) - min(SS.waveform)) < threshold);
            SS.clean = SS.clean&(tmp');
        end
        
        function RemoveSpkWithBlank(SS)
            % REMOVESPKWITHBLANK Removes all 'spikes' that have more that have 5 or more
            % voltage values in their waveform below 0.01 uV inidcating that a
            % portion of the waveform is blanked. This is extremely
            % unlikely otherwise.
            
            tmp = ~(sum(abs(SS.waveform) <= 0.01,1) >= 5);
            SS.clean = SS.clean&(tmp');
        end
        
        function RemoveChannel(SS,channeltoremove)
            % REMOVECHANNELS removes channels that the experimenter knows
            % apriori are bad for some reason. channelstoremove is a
            % 1-based, linearly indexed set of channel numbers to be 
            % removed from the data. The default channels to remove are [1
            % 8 33 58 64] corresponding to the four unconnected channels
            % and the ground on a standard MCS MEA.
            if nargin < 2 || isempty(channelstoremove)
                channeltoremove = [1 8 33 58 64];
            end
           
            tmp = ones(size(SS.channel));
            for k = channeltoremove
               tmp = tmp&(SS.channel~=k);
            end
            SS.clean = SS.clean&(tmp);
        end
        
        %% BLOCK 3: SORTING METHODS (methods that alter the 'unit' array)
        WaveClus(SS,minspk)
        % WAVECLUS ported version of Rodrigo Quian Quiroga's wave-clus
        % combined wavelet/superparamagnetic clustering algorithm. maxclusters 
        % determines the maximal number of units allowed per channel.
        % minspk sets the minimal number of spikes within a cluster for the
        % user to accept that data a legitimate unit. This method is contained
        % in a separate file.
        
        %% BLOCK 4: ADVANCED CLEANING METHODS (methods that alter the'clean' array, but have dependences on overloaded input properties)
        
        
        %% BLOCK 5: VISUALIZATION TOOLS
        RasterWave_Comp(SS, bound, Fs)
        % RASTERWAVE_COMP modified version of rasterwave that shows the
        % spikes that have been cleaned versus those that have not. This
        % method is contained in a separate file.
    end
    



    
end
