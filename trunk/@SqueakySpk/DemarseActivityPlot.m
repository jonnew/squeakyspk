function DemarseActivityPlot(SS,tbound,pbspeed,tau,fid)
% DemarseActivityPlot(SS,t,tau,dilation,name) visualizes firing rate as a
% movie of a 2 dimensional manifold floating in 3 dimensional space.  The x
% and y components show the row and column of each electrode, while the z
% component shows the firing rate of each electrode.
% TBOUND is a 2 d vector containing the start and stop time
% TAU is the time constant for the firing rate- how fast does the firing
% rate decay over time
% PBSPEED is how dilated time is- 10 will slow down data 10x, 0.1 will
% speed through data at 10x
% NAME is the name of the .avi you wish to produce.  If you do not provide
% this argument, no movie file will be made.

% containing 
fps = 30;
duration = (tbound(2)-tbound(1))*pbspeed;
vizframes = ceil(fps*duration);
frameDuration = 1/(pbspeed*fps);
activity = zeros(10);
tstart = tbound(1);
fh = figure('visible','off');
set(fh,'color','k');
caxis([0 2]);
caxis('manual');
ft = figure();
chan = SS.channel(SS.clean);
for i = 1:vizframes
    activity = activity*(exp(-frameDuration/tau));
    
    %what activity occured during this frame?
    tmpC = chan((SS.time(SS.clean)>=tstart)&(SS.time(SS.clean)<tstart+frameDuration));
    %figure(ft);hold on;plot(ones(size(tmpC))*tstart,tmpC,'.');hold off;
    %what row 
    r = ceil((tmpC)/8);
    c = tmpC - (r-1)*8;
    for j = 1:length(r)
    activity(r(j)+1,c(j)+1) = activity(r(j)+1,c(j)+1)+1;%offset by a row and a column
    end
    tstart = tstart+frameDuration;
    figure(fh);
    surf(activity);axis([1 10 1 10 0 12]);hidden on;shading interp;%;%shading flat;set(axes,'Zscale','log');
    %set(fh,'color','k','XColor',[1 1 1],'YColor',[1 1 1],'ylim',[0 max(unitinterest)+1])
%title('Spike Raster','fontsize',13)

title('\textbf{Neural Activity Plot}','fontsize',13,'Interpreter','Latex','Color','white')%
xlabel('\textbf{row}','fontsize',10,'Interpreter','Latex','color','w')

    ylabel('\textbf{column}','fontsize',10,'Interpreter','Latex','color','w')
    text('HorizontalAlignment','Center','String',[num2str(ceil(tstart*1000)) 'ms'],'color','w');
    F (i)=getframe(fh);
end
%

if (nargin < 5 || isempty(fid))
    %disp('no name')
    movie(F,1);
else
    %disp('name!')
    movie2avi(F, fid,'compression','none','fps',fps,'quality',100);
end

%


end