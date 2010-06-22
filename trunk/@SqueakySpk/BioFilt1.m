function BioFilt1(SS,alpha)
%BIOFILT Summary of this function goes here
%   Detailed explanation goes here
% Written by: JN

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end
if isempty(SS.sp_time)
    error('You need to provide spontaneous data collected just prior to the main data structure to run this method')
end
if isempty(SS.sp_unit)
    error('You need to do spike sorting before running this method')
end

% Temp clean array
tmp = ones(size(SS.time));

% Begin filtering
figure()
for i = 1:max(SS.sp_channel)
    
    unitsonchannel = unique(SS.sp_unit(SS.sp_channel == i));
    unitsonchannel(unitsonchannel == 0 ) = []; % remove unsorted stuff
    
    if ~isempty(unitsonchannel)
        % Create your set of biological filters
        unitwaveforms = SS.sp_avgwaveform(:,unitsonchannel);
        
        % Get the indicies of waveforms you will analize with these filters
        ind = (SS.channel == i);
        underinvestigation = unique(SS.unit(ind)); % units from the evoked data being investigated
        underinvestigation(underinvestigation == 0 ) = []; % remove unsorted stuff
        
        if ~isempty(underinvestigation)
            
            for j = underinvestigation'
                
                scoremat = (SS.waveform(:,SS.unit == j)')*(unitwaveforms);
                scoremat_comp = (SS.sp_waveform(:,SS.sp_unit == unitsonchannel)')*(unitwaveforms);
                
                subplot(211)
                hold on
                plot(SS.waveform(:,SS.unit == j),'b');
                plot(SS.sp_waveform(:,SS.sp_unit == unitsonchannel),'r')
                subplot(212)
                hold on
                hist(scoremat)
                hist(scoremat_comp)
                

                
                for k = 1:size(scoremat,2)
                    reject = ttest2(scoremat(:,k),alpha,'both','unequal');
                    [p,tbl,stats] = anova1(hogg);
                    [c,m] = multcompare(stats)
                end
                
                
                
            end
            
        end
        
        
    end
    
    
end

SS.methodlog = [SS.methodlog '<BioFilt>'];

end

