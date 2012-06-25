function LineSort(SS)
% LINESORT Supervised spike sorting using time-domain feature selection.
%
%   
%
%   Created by: Jon Newman (jnewman6 at gatech dot edu)
%   Location: The Georgia Institute of Technology
%   Created on: May 28, 2012
%   Last modified: May 28, 2012
%
%   Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

% Global parameters
numWaves2Plot = 500;

% Global variables
ss.channel = SS.channel;
ss.unit = SS.unit;
ss.waveform = SS.waveform;
ss_static = ss;
col = [[0.2 0.2 0.2]; hsv(10)];
currentChannel = 0;
currentMinMax = [0 0];
B = [];
selectedUnits = [];
selectedIdx = [];
extraUnits = 0;
lineDef = [0 0; 0 0];

%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Units','Pixels','Position',[30 30 760 590]);
set(f,'WindowButtonUpFcn',@StopDragFcn,...
    'KeyPressFcn',@CatchKeyboardPress);

%  Construct the components.
% Panels
p_waves = uipanel('Parent',f,'Title','Waveforms', ...
    'Units','Pixels','Position',[240 70 500 500]);
p_chans = uipanel('Parent',f,'Title','Channels', ...
    'Units','Pixels','Position',[20 315 200 255]);
p_units = uipanel('Parent',f,'Title','Unit Control', ...
    'Units','Pixels','Position',[20 70 200 225]);

% Buttons
b_save = uicontrol('Parent',f,'Style','pushbutton',...
    'String','Save and Close',...
    'Position',[540,20,200,30],...
    'Callback',{@b_save_Callback});
b_combine= uicontrol('Parent',p_units,'Style','pushbutton',...
    'String','Combine',...
    'Position',[10,10,85,30],...
    'Callback',{@b_combine_Callback});
b_reset = uicontrol('Parent',p_units,'Style','pushbutton',...
    'String','Reset',...
    'Position',[105,10,85,30],...
    'Callback',{@b_reset_Callback});

% List Boxes
lb_channels = uicontrol('Parent',p_chans,'Style','listbox',...
    'Position',[10,10,180,225],...
    'Callback',{@lb_channels_Callback},...
    'Background',[1 1 1]);
lb_units = uicontrol('Parent',p_units,'Style','listbox',...
    'Position',[10,50,180,155],...
    'Callback',{@lb_units_Callback},...
    'Background',[1 1 1],'Max',300,'Min',1);

% Axes
a_waves = axes('Parent',p_waves','Units','Pixels',...
    'Position',[10,10,480,470],'XTick',[],'YTick',[],...
    'box','on', ...
    'ButtonDownFcn',@StartMouseDrag);

% Line
l_select = line([0 0],[0 0],'Parent',a_waves,'Color','k');

% Initialize the GUI.
% Change units to normalized so components resize automatically.
set([f,p_chans, p_units, p_waves,b_save,b_combine,b_reset,lb_channels,lb_units,a_waves],...
    'Units','Normalized');

% Update the channel list box
UpdateChannelListBox()

% Assign the GUI a name to appear in the window title.
set(f,'Name','Line Sorter')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');


%% Callbacks
%  Callbacks for gui. These callbacks automatically
%  have access to component handles and initialized data
%  because they are nested at a lower level.
    function lb_channels_Callback(hObject, eventdata, handles)
        contents = cellstr(get(hObject,'String'));
        currentChannel =  str2num(contents{get(hObject,'Value')});
        currentMinMax = [min(min(ss.waveform(:,ss.channel == currentChannel))), ...
            max(max(ss.waveform(:,ss.channel == currentChannel)))];
        UpdateUnitListBox();
    end

    function lb_units_Callback(hObject, eventdata, handles)
        contents = str2num(char(get(hObject,'String')))';
        selectedIdx = cell2mat({get(hObject,'Value')});
        selectedUnits = contents(selectedIdx);
        SetWorkingData();
        PlotWaves();
    end

    function CatchKeyboardPress(hObject, eventdata, handles)
        
        % Which key was pressed
        keyval = get(hObject,'CurrentCharacter');
  
        % Assing, Delete or Ignore
        switch lower(keyval)
            case 'a',
                % Make sure lineDef is defined
                if isequal(lineDef,[0 0;0 0])
                    return;
                end
                b = FindIntersectingWaves();
                AssignNewUnit(b);
            case 'd',
                % Make sure lineDef is defined
                if isequal(lineDef,[0 0;0 0])
                    return;
                end
                b = FindIntersectingWaves();
                DeleteUnit(b);
            case 'c',
                % Make sure lineDef is defined
                if isequal(lineDef,[0 0;0 0])
                    return;
                end
                b = FindIntersectingWaves();
                CombineUnits2(b);
            case 's',
                idx = get(lb_channels,'Value');
                contents = cellstr(get(lb_channels,'String'));
                if idx < numel(contents)
                    currentChannel =  str2num(contents{idx+1});
                    currentMinMax = [min(min(ss.waveform(:,ss.channel == currentChannel))), ...
                        max(max(ss.waveform(:,ss.channel == currentChannel)))];
                    set(lb_channels,'Value',idx+1);
                    UpdateUnitListBox();
                end
            case 'w',
                idx = get(lb_channels,'Value');
                contents = cellstr(get(lb_channels,'String'));
                if idx > 1 
                    currentChannel =  str2num(contents{idx-1});
                    currentMinMax = [min(min(ss.waveform(:,ss.channel == currentChannel))), ...
                        max(max(ss.waveform(:,ss.channel == currentChannel)))];
                    set(lb_channels,'Value',idx-1);
                    UpdateUnitListBox();
                end
            otherwise,
                return;
        end
        
        
    end

    function b_combine_Callback(hObject, eventdata, handles)
        b = ismember(ss.unit,selectedUnits);
        CombineUnits(b);
    end

    function b_reset_Callback(hObject, eventdata, handles)
        u = ss_static.unit(ss_static.channel == currentChannel);
        ss.unit(ss.channel == currentChannel) = u;
        UpdateUnitListBox();
    end

    function b_save_Callback(hObject, eventdata, handles)
        su = ss.unit;
        uu = unique(su);
        
        for i = 1:length(uu)-1
            ss.unit(su == uu(i)+1) = i;
        end
        
        SS.unit = ss.unit;
        delete(f);
    end


%% Internal functions
    function PlotWaves()
        
        axes(a_waves);
        cla;
        l_select = line([0 0],[0 0],'Parent',a_waves,'Color','k');
        
        numSpikes = sum(B);
        if numSpikes > numWaves2Plot
            r = randperm(numSpikes);
            idx = r(1:numWaves2Plot);
        else
            idx = 1:numSpikes;
        end
        
        w = ss.waveform(:,B);
        w = w(:,idx);
        if ~isempty(ss.unit)
            u = ss.unit(B);
            u = u(idx);
        else
            u = zeros(size(w),2);
        end
        uu = unique(u);
        cu = 1:length(uu);
        
        hold all
        for j = 1:length(cu)
            ww = w(:,u == uu(j));
            if ~isempty(ww)
                if uu(j) == 0
                    plot(ww,'Color',col(1,:))
                else
                    plot(ww,'Color',col(selectedIdx(j)+1,:))
                end
            end
        end
        
%         currentMinMax = [min(min(a_waves)), ...
%             max(max(a_waves))];
        
        set(a_waves,'Ylim',currentMinMax);
    end

    function StartMouseDrag(hObject, eventdata, handles)
        pt = get(a_waves,'CurrentPoint');
        pt = [pt(1,1) pt(1,2)];
        set(f,'WindowButtonMotionFcn',{@DraggingFcn,pt});
    end

    function DraggingFcn(hObject, eventdata, handles)
        axes(a_waves);
        pt = get(a_waves,'CurrentPoint');
        pt = [pt(1,1) pt(1,2)];
        lineDef = [handles(1) pt(1);handles(2) pt(2)];
        set(l_select,'XData',[handles(1) pt(1)],'YData',[handles(2) pt(2)])
    end

    function StopDragFcn(hObject, eventdata, handles)
        set(f,'WindowButtonMotionFcn','');
    end

    function UpdateChannelListBox()
        
        % Populate the List Boxes
        % Add available channels
        uChan = unique(ss.channel);
        chs = {length(uChan)};
        for i = 1:length(uChan)
            chs{i} = num2str(uChan(i));
        end
        set(lb_channels, 'String', chs,'Value',1);
        contents = cellstr(get(lb_channels,'String'));
        currentChannel =  str2num(contents{get(lb_channels,'Value')});
        currentMinMax = [min(min(ss.waveform(:,ss.channel == currentChannel))), ...
            max(max(ss.waveform(:,ss.channel == currentChannel)))];
        UpdateUnitListBox();
        
    end

    function UpdateUnitListBox(varargin)
        
        % Add available units
        cUnit = unique(ss.unit(ss.channel == currentChannel));
        u = {length(cUnit)};
        
        if ~nargin
            selectedUnits = [];
            selectedIdx = [];
        end

        for i = 1:length(cUnit)
            if ~nargin
                selectedIdx = [selectedIdx i];
                selectedUnits = [selectedUnits cUnit(i)];
            end
            u{i} = num2str(cUnit(i));
        end
        if ~nargin
            set(lb_units, 'String', u,'Value',1:length(u));
        else
            set(lb_units, 'String',u,'Value',[]);
            contents = str2num(char(get(lb_units,'String')))';
            idx = 1:length(contents);
            selectedIdx = idx(ismember(contents,varargin{1}));
            set(lb_units, 'Value',selectedIdx);
        end
        SetWorkingData();
        PlotWaves();
    end

    function AssignNewUnit(b)
        if sum(b) > 0
            extraUnits = extraUnits + 1;
            ss.unit(b & B) = max(ss.unit) + 1;
            selectedUnits = [selectedUnits max(ss.unit)];
            UpdateUnitListBox(selectedUnits);
        end
    end

    function DeleteUnit(b)
        if sum(b) > 0
            extraUnits = extraUnits - 1;
            ss.unit(b & B) = 0;
            selectedUnits = [0 selectedUnits];
            UpdateUnitListBox(selectedUnits);
        end
    end

    function CombineUnits(b)
        ss.unit(b & B) = min(selectedUnits);
        selectedUnits = min(selectedUnits);
        UpdateUnitListBox(selectedUnits); 
    end

    function CombineUnits2(b)
        u = min(ss.unit(b & B & ss.unit ~= 0));
        sd = setdiff(ss.unit(b & B),u);
        ss.unit(b & B) = u;
        selectedUnits = setdiff(selectedUnits,sd);
        UpdateUnitListBox(selectedUnits); 
    end

    function b = FindIntersectingWaves()
        
        bIdx = find(B == 1);
        intersect = zeros(size(B));
        x = 1:size(ss.waveform,1);
        mn = floor(min(lineDef(1,:)));
        mx = ceil(max(lineDef(1,:)));
        w = ss.waveform(x >= mn & x <= mx,B);
        t = mn:mx;
        for i = 1:sum(B)
            intersect(bIdx(i)) = ~isempty(InterX([t;w(:,i)'],lineDef));
        end
        b = intersect > 0;
        
    end

    function SetWorkingData
        B = ss.channel == currentChannel & ismember(ss.unit, selectedUnits);
    end

    function P = InterX(L1,varargin)
        %INTERX Intersection of curves
        %   P = INTERX(L1,L2) returns the intersection points of two curves L1
        %   and L2. The curves L1,L2 can be either closed or open and are described
        %   by two-row-matrices, where each row contains its x- and y- coordinates.
        %   The intersection of groups of curves (e.g. contour lines, multiply
        %   connected regions etc) can also be computed by separating them with a
        %   column of NaNs as for example
        %
        %         L  = [x11 x12 x13 ... NaN x21 x22 x23 ...;
        %               y11 y12 y13 ... NaN y21 y22 y23 ...]
        %
        %   P has the same structure as L1 and L2, and its rows correspond to the
        %   x- and y- coordinates of the intersection points of L1 and L2. If no
        %   intersections are found, the returned P is empty.
        %
        %   P = INTERX(L1) returns the self-intersection points of L1. To keep
        %   the code simple, the points at which the curve is tangent to itself are
        %   not included. P = INTERX(L1,L1) returns all the points of the curve
        %   together with any self-intersection points.
        %
        %   Example:
        %       t = linspace(0,2*pi);
        %       r1 = sin(4*t)+2;  x1 = r1.*cos(t); y1 = r1.*sin(t);
        %       r2 = sin(8*t)+2;  x2 = r2.*cos(t); y2 = r2.*sin(t);
        %       P = InterX([x1;y1],[x2;y2]);
        %       plot(x1,y1,x2,y2,P(1,:),P(2,:),'ro')
        
        %   Author : NS
        %   Version: 3.0, 21 Sept. 2010
        
        %   Two words about the algorithm: Most of the code is self-explanatory.
        %   The only trick lies in the calculation of C1 and C2. To be brief, this
        %   is essentially the two-dimensional analog of the condition that needs
        %   to be satisfied by a function F(x) that has a zero in the interval
        %   [a,b], namely
        %           F(a)*F(b) <= 0
        %   C1 and C2 exactly do this for each segment of curves 1 and 2
        %   respectively. If this condition is satisfied simultaneously for two
        %   segments then we know that they will cross at some point.
        %   Each factor of the 'C' arrays is essentially a matrix containing
        %   the numerators of the signed distances between points of one curve
        %   and line segments of the other.
        
        %...Argument checks and assignment of L2
        error(nargchk(1,2,nargin));
        if nargin == 1,
            L2 = L1;    hF = @lt;   %...Avoid the inclusion of common points
        else
            L2 = varargin{1}; hF = @le;
        end
        
        %...Preliminary stuff
        x1  = L1(1,:)';  x2 = L2(1,:);
        y1  = L1(2,:)';  y2 = L2(2,:);
        dx1 = diff(x1); dy1 = diff(y1);
        dx2 = diff(x2); dy2 = diff(y2);
        
        %...Determine 'signed distances'
        S1 = dx1.*y1(1:end-1) - dy1.*x1(1:end-1);
        S2 = dx2.*y2(1:end-1) - dy2.*x2(1:end-1);
        
        C1 = feval(hF,D(bsxfun(@times,dx1,y2)-bsxfun(@times,dy1,x2),S1),0);
        C2 = feval(hF,D((bsxfun(@times,y1,dx2)-bsxfun(@times,x1,dy2))',S2'),0)';
        
        %...Obtain the segments where an intersection is expected
        [i,j] = find(C1 & C2);
        if isempty(i),P = zeros(2,0);return; end;
        
        %...Transpose and prepare for output
        i=i'; dx2=dx2'; dy2=dy2'; S2 = S2';
        L = dy2(j).*dx1(i) - dy1(i).*dx2(j);
        i = i(L~=0); j=j(L~=0); L=L(L~=0);  %...Avoid divisions by 0
        
        %...Solve system of eqs to get the common points
        P = unique([dx2(j).*S1(i) - dx1(i).*S2(j), ...
            dy2(j).*S1(i) - dy1(i).*S2(j)]./[L L],'rows')';
        
        function u = D(x,y)
            u = bsxfun(@minus,x(:,1:end-1),y).*bsxfun(@minus,x(:,2:end),y);
        end
    end
end
