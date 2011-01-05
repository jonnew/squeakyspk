function xcorrfilm(SS,tasks)
  %using the results of SS.xcorrs, create movie so you can watch the xcorrs
  %change over time
  %tasks is an Nx1 array, specifying which N xcorrs you want to look
  %at over time.  
   fps = 3;
   %'compression','Cinepak'
  h = avifile('xcorrsfull2.avi', 'fps',fps,'quality',100);
  
  scrsz = get(0,'ScreenSize');
k = figure('Position',[scrsz(3)*1/8 scrsz(4)*1/8 scrsz(3)*6/8 scrsz(4)*6/8]);
  

  
  side = ceil((length(tasks)+1)^0.5);
  
  for i = 1:size(SS.xcorrmat,1)
      for j = 1:length(tasks)
          subplot(side,side,j);
          imagesc(reshape(SS.xcorrmat(i,tasks(j),:,:),64,201)./SS.xcount(i,tasks(j)));
          title(num2str(tasks(j)));
      end
      subplot(side,side,side^2);imagesc(SS.xcount'/SS.xbin);colorbar;title('total activity (hz)');
      hold on; plot([i i],[0 size(SS.xcount,2)],'k','linewidth',3);hold off;
      h = addframe(h,getframe(k));
      
  end
  h = close(h);