function h = ASDR(SS,dt,loglin,ymax,returnplot)
% ASDR(SS) Array-wide spike detection rate using bins of width 1 second. 
% The function populates the asdr and csdr properties of the SS object.
% This analysis is only performed on clean spikes.
% 
%   SS.asdr is a matrix of the form [b ASDR] where b are time bins
%   and ASDR is vector of corresponding firing rates over all electrodes.
% 
%   SS.csdr is a matrix of the form [b CSDR] where b are time bins 
%   and CSDR is matrix of corresponding firing rates where each column
%   represents the firing rate at a given electrode.
% 
% ASDR(SS,dt) Allows the user to define a specific bin size (in seconds)
% 
% ASDR(SS,...,loglin,ymax,returnplot) Allows the user to define aspects of the 
% ASDR figure. If loglin is set to false, then the plot returned by ASDR will have
% linear axes. ymax forces the maximal value of the ordinate axis.
% returnplot is a boolean value determining if a figure should be created
% and its handle returned by the function. Default values for these
% parameters are true, auto, and true, respectively.
% 
%       Created by: Jon Newman (jnewman6 at gatech dot edu)
%       Location: The Georgia Institute of Technology
%       Created on: Feb 2, 2011
%       Last modified: Feb 2, 2011
%       Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt


if nargin < 5 || isempty(returnplot)
    returnplot = 1;
end
if nargin < 4 || isempty(ymax)
    ymax = 'auto';
end
if nargin < 3 || isempty(loglin)
    loglin = 1;
end
if nargin < 2 || isempty(dt)
    dt = 1; %seconds
end

dat = SS.ReturnClean;

% Calculate
bins = 0:dt:SS.time(end);
SS.csdr = zeros(length(bins),max(SS.channel)+1);
SS.csdr(:,1) = bins';
for i = 1:max(dat.channel)
    asdr_tmp = hist(dat.time(dat.channel==i),bins);
    if size(asdr_tmp,2) == 1;
        SS.csdr(:,i+1) = asdr_tmp./dt;
    else
        SS.csdr(:,i+1) = asdr_tmp'./dt;
    end
end

% Calculate ASDR
SS.asdr = [bins' sum(SS.csdr(:,2:end),2)];

% Plot results
if(returnplot)
    h = figure();
    if loglin
        asdrp = SS.asdr(SS.asdr(:,2)>0,:);
        semilogy(asdrp(:,1),asdrp(:,2),'k');
        if ~strcmp(ymax,'auto')            
            ylim([1 ymax])
        end
    else
        plot(SS.asdr(:,1),SS.asdr(:,2),'k');
    end
    xlabel('Time (sec)')
    ylabel(['(' num2str(dt) 's)^-1'])
end

end