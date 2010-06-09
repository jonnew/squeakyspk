classdef SqueakySpk
    %SQUEAKY SPIKE Data Class and methods for basic preprosessing of data
    %collected using extracellular, multielectrode arrays.
    
    %   Detailed explanation goes here
    
    properties
        
        % properties of data that you are cleaning [MAIN DATA]
        clean;
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
        function obj = set.time
            
        end
    end
    
end

