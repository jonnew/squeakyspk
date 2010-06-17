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
        
         
        function MitraClean(SS)
            % MITRA CLEAN
            %removes all spikes that have multiple peaks
            %effective at removing noise, many stimulus artifacts
            %still get through
            
            %probably not optimal code, but this will work
            
            %needs edit so that it doesn't care about minor ripples in the
            %main peak
            
            %will remove compound APs if they are less than 1ms apart
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

