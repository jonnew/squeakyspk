function RasterPlot(SS, bound, what2show, yaxischannel)
% RASTERPLOT Rasterplot method for the SqeakySpk class.
%
% Plots the a raster image of spike times versus unit or channel along with
% stimuli. Spikes that will currently be cleaned in the Squeaky spike
% object appear as red dots, those that will pass appear as white dots.
%
%   RASTERPLOT(SS) displays a raster-plot of
%   SS properties time versus unit (or channel),
%   e.g.    SS.time = [0.1 0.21 0.22 0.9 1.1,...,N] (NX1)
%           SS.unit = [3 1 1 1 2,...,N] (NX1)
%           SS.waveform = [[],[],...,N] (MXN).
%
%   RASTEPLOT(SS, bound, what2show, yaxischannel) creates a raster
%   wave plot for a portion of the full recording specified in bound = [start
%   stop] measured in whatever the units SS.time are in. what2show is a
%   string argument that can take three values ['both','clean', or
%   'dirty']. This determins what type of data is shown in the raster plot.
%   Those data that will be removed after cleaning ('dirty') those data
%   that have survived cleaning ('clean') or both types in different
%   colors. yaxischannel is a logical that will force the ordinate axis of
%   the raster plot to display channel instead of unit informaiton.
%
%   Created by: Jon Newman (jnewman6 at gatech dot edu)
%   Location: The Georgia Institute of Technology
%   Created on: July 30, 2009
%   Last modified: Aug 05, 2010
%
%   Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt


% check number and type of arguments
if nargin < 4 || isempty(yaxischannel)
    yaxischannel = false; % Default sampling frequecy (Hz)
end
if nargin < 3 || isempty(what2show)
    what2show = 'both'; % Default sampling frequecy (Hz)
end
if nargin < 2 || isempty(bound)
    bound = [0 SS.time(end)];
end
if nargin < 1
    error('Need to act on SqueakSpk Object');
end
% find stimuli within user bounds
goodstimind = (SS.st_time > bound(1)&SS.st_time < bound(2));

% find spike times within bound defined by user
startind = find(SS.time > bound(1),1);
if bound(2) == SS.time(end)
    endind = length(SS.time);
else
    endind = find(SS.time > bound(2),1) - 1;
end

spkinterest = SS.time(startind:endind);
cleaninterest = SS.clean(startind:endind);

% Has the user sorted yet?
usechan = isempty(SS.unit);
if usechan || yaxischannel
    unitinterest = SS.channel(startind:endind);
    % Set up figure and plot raster array
    fh = figure();
    set(fh,'color','k'); % sets the background color to black
    hold on
    
    
    % Plot the raster for spikes in the time bound of interest
    switch what2show
        case 'both'
            plot(spkinterest(cleaninterest),unitinterest(cleaninterest),'w.','MarkerSize',4);
            plot(spkinterest(~cleaninterest),unitinterest(~cleaninterest),'r.','MarkerSize',4);
            plot(SS.st_time(goodstimind),SS.st_channel(goodstimind),'*','Color',[0 1 0],'MarkerSize',4);
        case 'clean'
            spkinterest = spkinterest(cleaninterest);
            unitinterest = unitinterest(cleaninterest);            
            plot(spkinterest,unitinterest,'w.','MarkerSize',4);
            plot(SS.st_time(goodstimind),SS.st_channel(goodstimind),'*','Color',[0 1 0],'MarkerSize',4);
        case 'dirty'
            spkinterest = spkinterest(~cleaninterest);
            unitinterest = unitinterest(~cleaninterest);            
            plot(spkinterest,unitinterest,'r.','MarkerSize',4);
            plot(SS.st_time(goodstimind),SS.st_channel(goodstimind),'*','Color',[0 1 0],'MarkerSize',4);
    end
else
    unitinterest = SS.unit(startind:endind);
    % Set up figure and plot raster array
    fh = figure();
    set(fh,'color','k'); % sets the background color to black
    hold on
    
    % Plot the raster for spikes in the time bound of interest
    switch what2show
        case 'both'
            plot(spkinterest(cleaninterest),unitinterest(cleaninterest),'w.','MarkerSize',4);
            plot(spkinterest(~cleaninterest),unitinterest(~cleaninterest),'r.','MarkerSize',4);
            plot(SS.st_time(goodstimind),ones(size(SS.st_time(goodstimind)))*max(SS.unit)+1,'*','Color',[0 1 0],'MarkerSize',4);
        case 'clean'
            spkinterest = spkinterest(cleaninterest);
            unitinterest = unitinterest(cleaninterest);           
            plot(spkinterest,unitinterest,'w.','MarkerSize',4);
            plot(SS.st_time(goodstimind),ones(size(SS.st_time(goodstimind)))*max(SS.unit)+1,'*','Color',[0 1 0],'MarkerSize',4);
        case 'dirty'
            spkinterest = spkinterest(~cleaninterest);
            unitinterest = unitinterest(~cleaninterest);
            plot(spkinterest,unitinterest,'r.','MarkerSize',4);
            plot(SS.st_time(goodstimind),ones(size(SS.st_time(goodstimind)))*max(SS.unit)+1,'*','Color',[0 1 0],'MarkerSize',4);
    end
end

axis tight
h = gca;
set(h,'color','k','XColor',[1 1 1],'YColor',[1 1 1],'ylim',[0 max(unitinterest)+1])
title('Spike Raster','fontsize',13)
set(get(h,'Title'),'Color','white')
xlabel('Time (sec)','fontsize',14)
if usechan
    ylabel('Channel','fontsize',14)
else
    ylabel('Unit','fontsize',14)
end
hold off

end
