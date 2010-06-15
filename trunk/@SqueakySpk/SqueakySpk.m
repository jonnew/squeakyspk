classdef SqueakySpk < handle
    %SQUEAKY SPIKE Data Class and methods for basic preprosessing of data
    %collected using extracellular, multielectrode arrays.
    
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        
        % properties of data that you are cleaning [MAIN DATA]
        clean = true(length(spike.time),1);;
        time;
        channel;
        waveform;
        unit;
        
        % properties of the stimulus given while collecting the main data [STIM DATA]
        st_time;
        st_channel;
        
        % properties of the spontaneous data used for spk varification [SPONT DATA]
        sp_time;
        sp_channel;
        sp_waveform;
        sp_unit;
        
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
            SS.unit = zeros(length(spike.time),1);
            
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
        
        % HARD THRESHOLD CLEANER
        function HardThreshold(SS,threshold)
            %Removes all spikes with P2P amplitude
            %greater than threshold (dependent on whatever units you are
            %measuring AP's with).
            
            % Set default threshold if non is provided
            if nargin < 2 || isempty(threshold)
                threshold = 125; %uV
            end
            
            tmp = ((max(SS.waveform) - min(SS.waveform)) > threshold);
            SS.clean = SS.clean&(tmp');
        end
        
        
        %% BLOCK 3: SORTING METHODS (methods that alter the 'unit' array)
        %         function obj = set.time
        %
        %         end
        
        %% BLOCK 4: ADVANCED CLEANING METHODS (methods that alter the'clean' array, but have dependences on overloaded input properties)
        
        
        
        
        % RASTERWAVE_COMP modified version of rasterwave that shows the
        % spikes that have been cleaned versus those that have not. This
        % method is contained in a separate file.
        
        RasterWave_Comp()
        
        function output(SS)
            figure;plot(SS.clean);
            out = SS.clean;
        end
    end
    
    methods (Static)
        %% BLOCK 5: VISUALIZATION TOOLS
        % RASTERWAVE_COMP modified version of rasterwave that shows the
        % spikes that have been cleaned versus those that have not. This
        % method is contained in a separate file.
        RasterWave_Comp
    end
    
end

