function XCorrFilm(SS,name,tasks, fps)
  %using the results of SS.xcorrs, create movie so you can watch the xcorrs
  %change over time
  %name is the file name
  %tasks is an Nx1 array, specifying which N xcorrs you want to look
  %at over time.  
  %fps is frames per second
  
   %'compression','Cinepak'
  h = avifile([name '.avi'], 'fps',fps,'quality',100);
  
  scrsz = get(0,'ScreenSize');
k = figure('Position',[scrsz(3)*1/8 scrsz(4)*1/8 scrsz(3)*6/8 scrsz(4)*6/8]);
  

  
  side = ceil((length(tasks)+1)^0.5);
  
  for i = 1:size(SS.xcorrmat,1)
      for j = 1:length(tasks)
          subplot(side,side,j);
          imagesc(reshape(SS.xcorrmat(i,tasks(j),:,:),64,201)./SS.xcount(i,tasks(j)),[0 1]);
          ylabel('channel');
          xlabel('time (ms)');
          colorbar;
          set(gca,'XTick',0:50:200);
set(gca,'XTickLabel',{'-100','-50','0','50','100'});
          title(['conditioned on ' num2str(tasks(j))]);
      end
      subplot(side,side,side^2);imagesc(SS.xcount'/SS.xbin);colorbar;title('total activity (hz)'); ylabel('channel');xlabel({'time slice'; '(in hundreds of seconds)'});
      hold on; plot([i i],[0 size(SS.xcount,2)],'k','linewidth',3);hold off;
   %pause
      h = addframe(h,getframe(k));
      
  end
  h = close(h);