function WeedUnitByWaveform(SS)
% WEEDUNITBYWAVEFORM Supervised unit deletion by examination of average
% voltage waveform. Input is an SS object. Requires that the SS object
% hase non-empty units and average waveform fields. This can be acheived
% by running WAVECLUS.
%
%   Created by: Jon Newman (jnewman6 at gatech dot edu)
%   Location: The Georgia Institute of Technology
%   Created on: July 30, 2009
%   Last modified: Aug 05, 2010
%
%   Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if isempty(SS.unit) || isempty(SS.avgwaveform.avg)
    error('You must perform spike sorting using SS.WaveClus before running this method')
end

%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Position',[360,500,750,285],'Toolbar','figure');

%  Construct the components.
hinstruct = uicontrol('Style','text','String','Is this average waveform Good or Bad?',...
    'Position',[50,250,500,20]);
hgood = uicontrol('Style','pushbutton','String','Good',...
    'Position',[570,220,100,40],...
    'Callback',{@goodbutton_Callback});
hbad = uicontrol('Style','pushbutton','String','Bad',...
    'Position',[570,170,100,40],...
    'Callback',{@badbutton_Callback});
hgoback = uicontrol('Style','pushbutton',...
    'String','Go Back',...
    'Position',[570,120,100,40],...
    'Callback',{@gobackbutton_Callback});
hreturn = uicontrol('Style','pushbutton',...
    'String','Return Results',...
    'Position',[570,70,100,40],...
    'Callback',{@returnbutton_Callback});

ha = axes('Units','Pixels','Position',[50,60,500,185]);
align([hgood,hbad,hgoback,hreturn],'Center','None');

% Initialize the GUI.
% Change units to normalized so components resize
% automatically.
set([f,ha,hinstruct,hgood,hbad,hgoback,hreturn],...
    'Units','normalized');

%Storage for bad units
badunit = [];
goodunit = [];

% Waveform Index
waveind = 1;

% Plot the first unit waveform
plotWaveform(SS,waveind);

% Assign the GUI a name to appear in the window title.
set(f,'Name','Supervised Unit Deletion by Average Waveform')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');

%  Callbacks for simple_gui. These callbacks automatically
%  have access to component handles and initialized data
%  because they are nested at a lower level.

% Push button callbacks. Each callback plots current_data_avg in
% the specified plot type.

    function goodbutton_Callback(source,eventdata)
        
        % Append goodunit vector
        goodunit = [goodunit waveind];
        
        if waveind == size(SS.avgwaveform.avg,2)
            returnbutton_Callback()
        else
            % Plot the next unit waveform
            cla
            waveind = waveind+1;
            plotWaveform(SS,waveind);
            
        end
        
    end

    function badbutton_Callback(source,eventdata)
        
        % Append badunit vector
        badunit = [badunit waveind];
        
        if waveind == size(SS.avgwaveform.avg,2)
            returnbutton_Callback()
        else
            % Plot the next unit waveform
            cla
            waveind = waveind+1;
            plotWaveform(SS,waveind);
        end
        
    end

    function gobackbutton_Callback(source,eventdata)
        
        if waveind > 1
            waveind = waveind - 1;
            badunit(badunit==waveind) = [];
            goodunit(goodunit==waveind) = [];
            
            % Plot the next unit waveform
            cla
            plotWaveform(SS,waveind);
        else
            disp('Cannot go back because you are at the first waveform!')
        end
        
    end

    function returnbutton_Callback(source,eventdata)
        
        f_end = figure('Visible','off','Position',[360,500,340,100]);
        
        %  Construct the components.
        htext = uicontrol('Style','text','String','Enter Selections into SS object?',...
            'Position',[10,70,320,20]);
        hyes = uicontrol('Style','pushbutton','String','Enter Selections',...
            'Position',[10,20,150,40],...
            'Callback',{@enterbutton_Callback});
        hno = uicontrol('Style','pushbutton','String','Ignore Selections',...
            'Position',[180,20,150,40],...
            'Callback',{@quitbutton_Callback});
        align([hgood,hbad,hgoback,hreturn],'Center','None');
        set(f_end ,'Name','Terminate Supervised Unit Deletion')
        % Move the GUI to the center of the screen.
        movegui(f_end ,'center')
        % Make the GUI visible.
        set(f_end ,'Visible','on');
        
    end

    function enterbutton_Callback(source,eventdata)
        % Enter your good/bad picks
        SS.RemoveUnit(badunit);
        SS.methodlog = [SS.methodlog '<WeedUnitbyWaveform>'];
        close all
        return
    end

    function quitbutton_Callback(source,eventdata)
        % Quit the GUI
        close all
        return
    end

    function plotWaveform(SS,waveind)
        
        % plot the waveform
        current_data = SS.waveform(:,SS.unit == waveind);
        if length(current_data) > 500
            rp = randperm(length(current_data));
            current_data = current_data(:,rp(1:500));
        end
        
        current_data_avg = SS.avgwaveform.avg(:,waveind);
        current_data_sd = SS.avgwaveform.std(:,waveind);

        hold on
        
        plot([0 length(current_data_avg)],[0 0],'k--')
        plot(current_data)
        [hl hp] = boundedline(1:length(current_data_avg),...
            current_data_avg,...
            current_data_sd);
        set(hl,'LineWidth',3,'Color',[0 0 0]);
        
        xlabel('time (samp.)')
        ylabel('uV')
        text(length(current_data_avg)-10,min(current_data_avg),['# ' num2str(waveind) ' of ' num2str(size(SS.avgwaveform.avg,2))])
        axis([1 length(current_data_avg) min(min(current_data)) max(max(current_data))]);
    end

    function varargout = boundedline(varargin)
        %BOUNDEDLINE Plot a line with shaded error/confidence bounds
        %
        % [hl, hp] = boundedline(x, y, b)
        % [hl, hp] = boundedline(x, y, b, linespec)
        % [hl, hp] = boundedline(x1, y1, b1, linespec1,  x2, y2, b2, linespec2)
        % [hl, hp] = boundedline(..., 'alpha')
        % [hl, hp] = boundedline(..., ax)
        % [hl, hp] = boundedline(..., 'transparency', trans)
        % [hl, hp] = boundedline(..., 'orientation', orient)
        % [hl, hp] = boundedline(..., 'cmap', cmap)
        %
        % Input variables:
        %
        %   x, y:       x and y values, either vectors of the same length, matrices
        %               of the same size, or vector/matrix pair where the row or
        %               column size of the array matches the length of the vector
        %               (same requirements as for plot function).
        %
        %   b:          npoint x nsize x nline array.  Distance from line to
        %               boundary, for each point along the line (dimension 1), for
        %               each side of the line (lower/upper or left/right, depending
        %               on orientation) (dimension 2), and for each plotted line
        %               described by the preceding x-y values (dimension 3).  If
        %               size(b,1) == 1, the bounds will be the same for all points
        %               along the line.  If size(b,2) == 1, the bounds will be
        %               symmetrical on both sides of the lines.  If size(b,3) == 1,
        %               the same bounds will be applied to all lines described by
        %               the preceding x-y arrays (only applicable when either x or
        %               y is an array).  Bounds cannot include Inf, -Inf, or NaN,
        %
        %   linespec:   line specification that determines line type, marker
        %               symbol, and color of the plotted lines for the preceding
        %               x-y values.
        %
        %   'alpha':    if included, the bounded area will be rendered with a
        %               partially-transparent patch the same color as the
        %               corresponding line(s).  If not included, the bounded area
        %               will be an opaque patch with a lighter shade of the
        %               corresponding line color.
        %
        %   ax:         handle of axis where lines will be plotted.  If not
        %               included, the current axis will be used.
        %
        %   trans:      Scalar between 0 and 1 indicating with the transparency or
        %               intensity of color of the bounded area patch. Default is
        %               0.2.
        %
        %   orient:     'vert': add bounds in vertical (y) direction (default)
        %               'horiz': add bounds in horizontal (x) direction
        %
        %   cmap:       n x 3 colormap array.  If included, lines will be colored
        %               (in order of plotting) according to this colormap,
        %               overriding any linespec or default colors.
        %
        % Output variables:
        %
        %   hl:         handles to line objects
        %
        %   hp:         handles to patch objects
        %
        % Example:
        %
        % x = linspace(0, 2*pi, 50);
        % y1 = sin(x);
        % y2 = cos(x);
        % e1 = rand(size(y1))*.5+.5;
        % e2 = [.25 .5];
        %
        % subplot(2,2,1);
        % boundedline(x, y1, e1, '-b*', x, y2, e2, '--ro');
        %
        % subplot(2,2,2);
        % boundedline(x, [y1;y2], rand(length(y1),2,2)*.5+.5, 'alpha');
        %
        % subplot(2,2,3);
        % boundedline([y1;y2], x, e1(1), 'orientation', 'horiz')
        %
        % subplot(2,2,4)
        % boundedline(x, repmat(y1, 4,1), permute(0.5:-0.1:0.2, [3 1 2]), ...
        %             'cmap', cool(4), 'transparency', 0.5);
        
        
        % Copyright 2010 Kelly Kearney
        
        %--------------------
        % Parse input
        %--------------------
        
        % Alpha flag
        
        isalpha = cellfun(@(x) ischar(x) && strcmp(x, 'alpha'), varargin);
        if any(isalpha)
            usealpha = true;
            varargin = varargin(~isalpha);
        else
            usealpha = false;
        end
        
        % Axis
        
        isax = cellfun(@(x) isscalar(x) && ishandle(x) && strcmp('axes', get(x,'type')), varargin);
        if any(isax)
            hax = varargin{isax};
            varargin = varargin(~isax);
        else
            hax = gca;
        end
        
        % Transparency
        
        [found, trans, varargin] = parseparam(varargin, 'transparency');
        
        if ~found
            trans = 0.2;
        end
        
        if ~isscalar(trans) || trans < 0 || trans > 1
            error('Transparency must be scalar between 0 and 1');
        end
        
        % Orientation
        
        [found, orient, varargin] = parseparam(varargin, 'orientation');
        
        if ~found
            orient = 'vert';
        end
        
        if strcmp(orient, 'vert')
            isvert = true;
        elseif strcmp(orient, 'horiz')
            isvert = false;
        else
            error('Orientation must be ''vert'' or ''horiz''');
        end
        
        
        % Colormap
        
        [hascmap, cmap, varargin] = parseparam(varargin, 'cmap');
        
        
        % X, Y, E triplets, and linespec
        
        [x,y,err,linespec] = deal(cell(0));
        while ~isempty(varargin)
            if length(varargin) < 3
                error('Unexpected input: should be x, y, bounds triplets');
            end
            if all(cellfun(@isnumeric, varargin(1:3)))
                x = [x varargin(1)];
                y = [y varargin(2)];
                err = [err varargin(3)];
                varargin(1:3) = [];
            else
                error('Unexpected input: should be x, y, bounds triplets');
            end
            if ~isempty(varargin) && ischar(varargin{1})
                linespec = [linespec varargin(1)];
                varargin(1) = [];
            else
                linespec = [linespec {[]}];
            end
        end
        
        %--------------------
        % Reformat x and y
        % for line and patch
        % plotting
        %--------------------
        
        % Calculate y values for bounding lines
        
        plotdata = cell(0,7);
        
        htemp = figure('visible', 'off');
        for ix = 1:length(x)
            
            % Get full x, y, and linespec data for each line (easier to let plot
            % check for properly-sized x and y and expand values than to try to do
            % it myself)
            
            try
                if isempty(linespec{ix})
                    hltemp = plot(x{ix}, y{ix});
                else
                    hltemp = plot(x{ix}, y{ix}, linespec{ix});
                end
            catch
                close(htemp);
                error('X and Y matrices and/or linespec not appropriate for line plot');
            end
            
            linedata = get(hltemp, {'xdata', 'ydata', 'marker', 'linestyle', 'color'});
            
            nline = size(linedata,1);
            
            % Expand bounds matrix if necessary
            
            if nline > 1
                if ndims(err{ix}) == 3
                    err2 = squeeze(num2cell(err{ix},[1 2]));
                else
                    err2 = repmat(err(ix),nline,1);
                end
            else
                err2 = err(ix);
            end
            
            % Figure out upper and lower bounds
            
            [lo, hi] = deal(cell(nline,1));
            for iln = 1:nline
                
                x2 = linedata{iln,1};
                y2 = linedata{iln,2};
                nx = length(x2);
                
                if isvert
                    lineval = y2;
                else
                    lineval = x2;
                end
                
                sz = size(err2{iln});
                
                if isequal(sz, [nx 2])
                    lo{iln} = lineval - err2{iln}(:,1)';
                    hi{iln} = lineval + err2{iln}(:,2)';
                elseif isequal(sz, [nx 1])
                    lo{iln} = lineval - err2{iln}';
                    hi{iln} = lineval + err2{iln}';
                elseif isequal(sz, [1 2])
                    lo{iln} = lineval - err2{iln}(1);
                    hi{iln} = lineval + err2{iln}(2);
                elseif isequal(sz, [1 1])
                    lo{iln} = lineval - err2{iln};
                    hi{iln} = lineval + err2{iln};
                elseif isequal(sz, [2 nx]) % not documented, but accepted anyways
                    lo{iln} = lineval - err2{iln}(:,1);
                    hi{iln} = lineval + err2{iln}(:,2);
                elseif isequal(sz, [1 nx]) % not documented, but accepted anyways
                    lo{iln} = lineval - err2{iln};
                    hi{iln} = lineval + err2{iln};
                elseif isequal(sz, [2 1]) % not documented, but accepted anyways
                    lo{iln} = lineval - err2{iln}(1);
                    hi{iln} = lineval + err2{iln}(2);
                else
                    error('Error bounds must be npt x nside x nline array');
                end
                
            end
            
            % Combine all data
            
            plotdata = [plotdata; linedata lo hi];
            
        end
        close(htemp);
        
        % Override colormap
        
        if hascmap
            nd = size(plotdata,1);
            cmap = repmat(cmap, ceil(nd/size(cmap,1)), 1);
            cmap = cmap(1:nd,:);
            plotdata(:,5) = num2cell(cmap,2);
        end
        
        
        %--------------------
        % Plot
        %--------------------
        
        % Setup of x and y, plus line and patch properties
        
        nline = size(plotdata,1);
        [xl, yl, xp, yp, marker, lnsty, lncol, ptchcol, alpha] = deal(cell(nline,1));
        
        for iln = 1:nline
            xl{iln} = plotdata{iln,1};
            yl{iln} = plotdata{iln,2};
            if isvert
                xp{iln} = [plotdata{iln,1} fliplr(plotdata{iln,1})];
                yp{iln} = [plotdata{iln,6} fliplr(plotdata{iln,7})];
            else
                xp{iln} = [plotdata{iln,6} fliplr(plotdata{iln,7})];
                yp{iln} = [plotdata{iln,2} fliplr(plotdata{iln,2})];
            end
            
            marker{iln} = plotdata{iln,3};
            lnsty{iln} = plotdata{iln,4};
            
            if usealpha
                lncol{iln} = plotdata{iln,5};
                ptchcol{iln} = plotdata{iln,5};
                alpha{iln} = trans;
            else
                lncol{iln} = plotdata{iln,5};
                ptchcol{iln} = interp1([0 1], [1 1 1; lncol{iln}], trans);
                alpha{iln} = 1;
            end
        end
        
        % Plot patches and lines
        
        [hp,hl] = deal(zeros(nline,1));
        
        axes(hax);
        hold on;
        
        for iln = 1:nline
            hp(iln) = patch(xp{iln}, yp{iln}, ptchcol{iln}, 'facealpha', alpha{iln}, 'edgecolor', 'none');
        end
        
        for iln = 1:nline
            hl(iln) = line(xl{iln}, yl{iln}, 'marker', marker{iln}, 'linestyle', lnsty{iln}, 'color', lncol{iln});
        end
        
        %--------------------
        % Assign output
        %--------------------
        
        nargchk(0, 2, nargout);
        
        if nargout >= 1
            varargout{1} = hl;
        end
        
        if nargout == 2
            varargout{2} = hp;
        end
        
        %--------------------
        % Parse optional
        % parameters
        %--------------------
        
        function [found, val, vars] = parseparam(vars, param)
            
            isvar = cellfun(@(x) ischar(x) && strcmpi(x, param), vars);
            
            if sum(isvar) > 1
                error('Parameters can only be passed once');
            end
            
            if any(isvar)
                found = true;
                idx = find(isvar);
                val = vars{idx+1};
                vars([idx idx+1]) = [];
            else
                found = false;
                val = [];
            end
        end
        
    end
end
