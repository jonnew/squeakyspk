function PlotAvgWaveform(SS)
% PLOTAVGWAVEFORM(SS) Plots the average waveforms for each
% unit, labeled with the unit number. Units that will be
% removed are colored red.

if isempty(SS.avgwaveform) || isempty(SS.avgwaveform.avg)
    error('You have not performed spike sorting yet, or there are no valid units.')
end

avgfig = figure();
m = ceil(sqrt(size(SS.avgwaveform.avg,2)));
n = ceil(sqrt(size(SS.avgwaveform.avg,2)));

for it = 1:size(SS.avgwaveform.avg,2)
    subplot(m,n,it)
    if ismember(it, SS.badunit)
        col = [1 0 0];
    else
        col = [0 0 1];
    end
    confplot(1000/SS.fs.*(1:length(SS.avgwaveform.avg(:,it))),...
        SS.avgwaveform.avg(:,it),...
        SS.avgwaveform.std(:,it),...
        SS.avgwaveform.std(:,it),...
        'LineWidth',2,'color', col)
    title(['Unit ' num2str(it)])
    axis tight
    [min_amp min_ind] = min(SS.avgwaveform.avg(:,it));
    [max_amp max_ind] = max(SS.avgwaveform.avg(:,it));
    ylim([min_amp-SS.avgwaveform.std(min_ind,it)-2 max_amp+SS.avgwaveform.std(max_ind,it)+2])
end

[ax1,h1] = suplabel('Time (msec)');
[ax2,h2] = suplabel('Amplitude (uV)','y');
set(h1,'FontSize',16);
set(h2,'FontSize',16);

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
        
        H = [p, a1, a2];
        
        if (nargout>1)
            varargout{1} = H;
        end;
        
    end
    function [ax,h]=suplabel(text,whichLabel,supAxes)
        % PLaces text as a title, xlabel, or ylabel on a group of subplots.
        % Returns a handle to the label and a handle to the axis.
        %  [ax,h]=suplabel(text,whichLabel,supAxes)
        % returns handles to both the axis and the label.
        %  ax=suplabel(text,whichLabel,supAxes)
        % returns a handle to the axis only.
        %  suplabel(text) with one input argument assumes whichLabel='x'
        %
        % whichLabel is any of 'x', 'y', 'yy', or 't', specifying whether the
        % text is to be the xlable, ylabel, right side y-label,
        % or title respectively.
        %
        % supAxes is an optional argument specifying the Position of the
        %  "super" axes surrounding the subplots.
        %  supAxes defaults to [.08 .08 .84 .84]
        %  specify supAxes if labels get chopped or overlay subplots
        %
        % EXAMPLE:
        %  subplot(2,2,1);ylabel('ylabel1');title('title1')
        %  subplot(2,2,2);ylabel('ylabel2');title('title2')
        %  subplot(2,2,3);ylabel('ylabel3');xlabel('xlabel3')
        %  subplot(2,2,4);ylabel('ylabel4');xlabel('xlabel4')
        %  [ax1,h1]=suplabel('super X label');
        %  [ax2,h2]=suplabel('super Y label','y');
        %  [ax3,h2]=suplabel('super Y label (right)','yy');
        %  [ax4,h3]=suplabel('super Title'  ,'t');
        %  set(h3,'FontSize',30)
        %
        % SEE ALSO: text, title, xlabel, ylabel, zlabel, subplot,
        %           suptitle (Matlab Central)
        
        % Author: Ben Barrowes <barrowes@alum.mit.edu>
        
        %modified 3/16/2010 by IJW to make axis behavior re "zoom" on exit same as
        %at beginning. Requires adding tag to the invisible axes
        
        
        currax=findobj(gcf,'type','axes','-not','tag','suplabel');
        
        if nargin < 3
            supAxes=[.08 .08 .84 .84];
            ah=findall(gcf,'type','axes');
            if ~isempty(ah)
                supAxes=[inf,inf,0,0];
                leftMin=inf;  bottomMin=inf;  leftMax=0;  bottomMax=0;
                axBuf=.04;
                set(ah,'units','normalized')
                ah=findall(gcf,'type','axes');
                for ii=1:length(ah)
                    if strcmp(get(ah(ii),'Visible'),'on')
                        thisPos=get(ah(ii),'Position');
                        leftMin=min(leftMin,thisPos(1));
                        bottomMin=min(bottomMin,thisPos(2));
                        leftMax=max(leftMax,thisPos(1)+thisPos(3));
                        bottomMax=max(bottomMax,thisPos(2)+thisPos(4));
                    end
                end
                supAxes=[leftMin-axBuf,bottomMin-axBuf,leftMax-leftMin+axBuf*2,bottomMax-bottomMin+axBuf*2];
            end
        end
        if nargin < 2, whichLabel = 'x';  end
        if nargin < 1, help(mfilename); return; end
        
        if ~isstr(text) || ~isstr(whichLabel)
            error('text and whichLabel must be strings')
        end
        whichLabel=lower(whichLabel);
        
        ax=axes('Units','Normal','Position',supAxes,'Visible','off','tag','suplabel');
        if strcmp('t',whichLabel)
            set(get(ax,'Title'),'Visible','on')
            title(text);
        elseif strcmp('x',whichLabel)
            set(get(ax,'XLabel'),'Visible','on')
            xlabel(text);
        elseif strcmp('y',whichLabel)
            set(get(ax,'YLabel'),'Visible','on')
            ylabel(text);
        elseif strcmp('yy',whichLabel)
            set(get(ax,'YLabel'),'Visible','on')
            ylabel(text);
            set(ax,'YAxisLocation','right')
        end
        
        for k=1:length(currax), axes(currax(k));end % restore all other axes
        
        if (nargout < 2)
            return
        end
        if strcmp('t',whichLabel)
            h=get(ax,'Title');
            set(h,'VerticalAlignment','middle')
        elseif strcmp('x',whichLabel)
            h=get(ax,'XLabel');
        elseif strcmp('y',whichLabel) || strcmp('yy',whichLabel)
            h=get(ax,'YLabel');
        end
        
    end

end