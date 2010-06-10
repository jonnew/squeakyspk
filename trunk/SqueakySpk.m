classdef SqueakySpk
    %SQUEAKY SPIKE Data Class and methods for basic preprosessing of data
    %collected using extracellular, multielectrode arrays.
    
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        
        % properties of data that you are cleaning [MAIN DATA]
        clean =true(length(spike.time),1);;
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
        
        %constructors
        function SS = SqueakySpk(spike)
            %constructor using only the spike construct (ie, the data to be
            %cleaned)
            %SS.clean = true(length(spike.time),1);
            SS.time = spike.time;
            SS.channel = spike.channel;
            SS.waveform = spike.waveform;
            SS.unit = zeros(length(spike.time),1);
        end
        
        %cleaning methods (methods that alter the 'clean' array)
        function hardThreshold(SS, threshold)
            %cleaning method that removes all spikes with an amplitude
            %greater than the threshold argument
            tmp = ((max(SS.waveform)-min(SS.waveform))<threshold);
            figure;plot(SS.waveform(:,tmp));
            SS.clean = SS.clean&tmp';
            figure;plot(SS.clean);
        end
        %sorting methods (methods that alter the 'unit' array)
%         function obj = set.time
%             
%         end
        function out = output(SS)
            figure;plot(SS.clean);
            out = SS.clean;
        end
    end
    
end

