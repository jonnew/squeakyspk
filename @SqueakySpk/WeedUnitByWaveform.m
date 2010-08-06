function WeedUnitByWaveform(SS)
% WEEDUNITBYWAVEFORM Supervised unit deletion by examination of average
% voltage waveform. Input is an SS object. Requires that the SS object
% hase non-empty units and average waveform fields
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
current_data_avg = SS.avgwaveform.avg(:,waveind);
current_data_sd = SS.avgwaveform.std(:,waveind);
confplot(1:length(current_data_avg),...
    current_data_avg,...
    current_data_sd,...
    current_data_sd,...
    'k','LineWidth',2);
hold on
plot([0 length(current_data_avg)],[0 0],'k--')
xlabel('time (samp.)')
ylabel('uV')
text(length(current_data_avg)-10,min(current_data_avg),['# ' num2str(waveind) ' of ' num2str(size(SS.avgwaveform.avg,2))])
[min_amp min_ind] = min(current_data_avg);
[max_amp max_ind] = max(current_data_avg);
axis([1 length(current_data_avg) min_amp-current_data_sd(min_ind)-2 max_amp+current_data_sd(max_ind)+2]);

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
        
        if waveind+1 == size(SS.avgwaveform.avg,2)
            returnbutton_Callback()
        else
            % Plot the next unit waveform
            cla
            waveind = waveind+1;
            current_data_avg = SS.avgwaveform.avg(:,waveind);
            current_data_sd = SS.avgwaveform.std(:,waveind);

            confplot(1:length(current_data_avg),...
                current_data_avg,...
                current_data_sd,...
                current_data_sd,...
                'k','LineWidth',2);
            hold on 
            plot([0 length(current_data_avg)],[0 0],'k--')
            xlabel('time (samp.)')
            ylabel('uV')
            text(length(current_data_avg)-10,min(current_data_avg),['# ' num2str(waveind) ' of ' num2str(size(SS.avgwaveform.avg,2))])
            [min_amp min_ind] = min(current_data_avg);
            [max_amp max_ind] = max(current_data_avg);
            axis([1 length(current_data_avg) min_amp-current_data_sd(min_ind)-2 max_amp+current_data_sd(max_ind)+2]);
        end
        
    end

    function badbutton_Callback(source,eventdata)
        
        % Append badunit vector
        badunit = [badunit waveind];
        
        if waveind+1 == size(SS.avgwaveform.avg,2)
            returnbutton_Callback()
        else
            % Plot the next unit waveform
            cla
            waveind = waveind+1;
            current_data_avg = SS.avgwaveform.avg(:,waveind);
            current_data_sd = SS.avgwaveform.std(:,waveind);
            confplot(1:length(current_data_avg),...
                current_data_avg,...
                current_data_sd,...
                current_data_sd,...
                'k','LineWidth',2);
            confplot(1:length(current_data_avg),...
                current_data_avg,...
                current_data_sd,...
                current_data_sd,...
                'k','LineWidth',2);
            hold on 
            plot([0 length(current_data_avg)],[0 0],'k--')
            xlabel('time (samp.)')
            ylabel('uV')
            text(length(current_data_avg)-10,min(current_data_avg),['# ' num2str(waveind) ' of ' num2str(size(SS.avgwaveform.avg,2))])
            [min_amp min_ind] = min(current_data_avg);
            [max_amp max_ind] = max(current_data_avg);
            axis([1 length(current_data_avg) min_amp-current_data_sd(min_ind)-2 max_amp+current_data_sd(max_ind)+2]);
        end
        
    end

    function gobackbutton_Callback(source,eventdata)
        
        if waveind > 1
            waveind = waveind - 1;
            badunit(badunit==waveind) = [];
            goodunit(badunit==waveind) = [];
            
            % Plot the old unit waveform
            cla
            current_data_avg = SS.avgwaveform.avg(:,waveind);
            current_data_sd = SS.avgwaveform.std(:,waveind);
            confplot(1:length(current_data_avg),...
                current_data_avg,...
                current_data_sd,...
                current_data_sd,...
                'k','LineWidth',2);
            confplot(1:length(current_data_avg),...
                current_data_avg,...
                current_data_sd,...
                current_data_sd,...
                'k','LineWidth',2);
            hold on 
            plot([0 length(current_data_avg)],[0 0],'k--')
            xlabel('time (samp.)')
            ylabel('uV')
            text(length(current_data_avg)-10,min(current_data_avg),['# ' num2str(waveind) ' of ' num2str(size(SS.avgwaveform.avg,2))])
            [min_amp min_ind] = min(current_data_avg);
            [max_amp max_ind] = max(current_data_avg);
            axis([1 length(current_data_avg) min_amp-current_data_sd(min_ind)-2 max_amp+current_data_sd(max_ind)+2]);
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
        SS.PlotAvgWaveform();
        return
    end

    function quitbutton_Callback(source,eventdata)
        % Quit the GUI
        close all
        return
    end

    function varargout = confplot(varargin)
        %CONFPLOT Linear plot with continuous confidence/error boundaries.
        %
        %   CONFPLOT(X,Y,L,U) plots the graph of vector X vs. vector Y with
        %   'continuous' confidence/error boundaries specified by the vectors
        %   L and U.  L and U contain the lower and upper error ranges for each
        %   point in Y. The vectors X,Y,L and U must all be the same length.
        %
        %   CONFPLOT(X,Y,E) or CONFPLOT(Y,E) plots Y with error bars [Y-E Y+E].
        %   CONFPLOT(...,'LineSpec') uses the color and linestyle specified by
        %   the string 'LineSpec'.  See PLOT for possibilities.
        %
        %   H = CONFPLOT(...) returns a vector of line handles.
        %
        %   For example,
        %      x = 1:0.1:10;
        %      y = sin(x);
        %      e = std(y)*ones(size(x));
        %      confplot(x,y,e)
        %   draws symmetric continuous confidence/error boundaries of unit standard deviation.
        %
        %   See also ERRORBAR, SEMILOGX, SEMILOGY, LOGLOG, PLOTYY, GRID, CLF, CLC, TITLE,
        %   XLABEL, YLABEL, AXIS, AXES, HOLD, COLORDEF, LEGEND, SUBPLOT, STEM.
        %
        %     © 2002 - Michele Giugliano, PhD (http://www.giugliano.info) (Bern, Monday Nov 4th, 2002 - 19:02)
        %    (bug-reports to michele@giugliano.info)
        %   $Revision: 1.0 $  $Date: 2002/11/11 14:36:08 $
        %
        
        if (nargin<2)
            disp('ERROR: not enough input arguments!');
            return;
        end % if
        
        x = [];  y = [];  z1 = [];  z2 = [];  spec = '';
        
        switch nargin
            case 2
                y  = varargin{1};
                z1 = y + varargin{2};
                z2 = y - varargin{2};
                x  = 1:length(y);
            case 3
                x  = varargin{1};
                y  = varargin{2};
                z1 = y + varargin{3};
                z2 = y - varargin{3};
            case 4
                x  = varargin{1};
                y  = varargin{2};
                z1 = y + varargin{4};
                z2 = y - varargin{3};
        end % switch
        
        if (nargin >= 5)
            x  = varargin{1};
            y  = varargin{2};
            z1 = y + varargin{4};
            z2 = y - varargin{3};
            spec = 'ok';
        end %
        
        
        p = plot(x,y,x,z1,x,z2);    YLIM = get(gca,'YLim');    delete(p);
        a1 = area(x,z1,min(YLIM));
        hold on;
        set(a1,'LineStyle','none');     set(a1,'FaceColor',[0.8 0.8 0.8]);
        a2 = area(x,z2,min(YLIM));
        set(a2,'LineStyle','none');     set(a2,'FaceColor',[1 1 1]);
        if (~isempty(spec)),
            spec = sprintf('p = plot(x,y,varargin{5}');
            for i=6:nargin,  spec = sprintf('%s,varargin{%d}',spec,i); end % for
            spec = sprintf('%s);',spec);
            eval(spec);
        else                     p = plot(x,y);
        end;
        hold off;
        
        set(gca,'Layer','top');
        
        if (nargout>1)
            varargout{1} = H;
        end;
        
    end

end