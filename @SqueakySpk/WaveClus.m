function WaveClus(SS,minspk)

if nargin < 2 || isempty(minspk)
    minspk = 20;
end

% Waveclus for main data
time = SS.time;
channel = SS.channel;
waveform = SS.waveform;

[chan2anal chanparse] = PepareBatchData(time,channel,waveform);
Do_Clustering(chanparse,chan2anal);
UnitID = Populate_Results(chan2anal);

SS.unit = UnitID;

% Waveclus for spontaneous data
if ~isempty(SS.sp_time)
    
    time = SS.sp_time;
    channel = SS.sp_channel;
    waveform = SS.sp_waveform;
    
    [chan2anal chanparse] = PepareBatchData(time,channel,waveform);
    Do_Clustering(chanparse,chan2anal);
    UnitID = Populate_Results(chan2anal);
    
    SS.sp_unit = UnitID;
    
end

% Functions called for clustering
    function Do_Clustering(channelparse,chan2anal)
        
        print2file = 1;                              %for saving printouts.
        
        handles.par.w_pre=22;                       %number of pre-event data points stored
        handles.par.w_post=52;                      %number of post-event data points stored
        handles.par.detection = 'pos';              %type of threshold
        handles.par.stdmin = 5.00;                  %minimum threshold
        handles.par.stdmax = 50;                    %maximum threshold
        handles.par.interpolation = 'y';            %interpolation for alignment
        handles.par.int_factor = 2;                 %interpolation factor
        handles.par.detect_fmin = 300;              %high pass filter for detection (default 300)
        handles.par.detect_fmax = 3000;             %low pass filter for detection (default 3000)
        handles.par.sort_fmin = 300;                %high pass filter for sorting (default 300)
        handles.par.sort_fmax = 3000;               %low pass filter for sorting (default 3000)
        
        handles.par.max_spk = inf;                  % max. # of spikes before starting templ. match.
        handles.par.template_type = 'center';       % nn, center, ml, mahal
        handles.par.template_sdnum = 3;             % max radius of cluster in std devs. % JN: MAY WANT TO MAKE LOWER SO THAT NON-SPIKES GET EXCLUDED MORE
        
        handles.par.features = 'wav';               %choice of spike features
        handles.par.inputs = 10;                    %number of inputs to the clustering
        handles.par.scales = 4;                     %scales for wavelet decomposition
        if strcmp(handles.par.features,'pca');      %number of inputs to the clustering for pca
            handles.par.inputs=3;
        end
        
        handles.par.mintemp = 0.01;                 %minimum temperature
        handles.par.maxtemp = 0.08;                 %maximum temperature
        handles.par.tempstep = 0.01;                %temperature step
        handles.par.num_temp = floor(...
            (handles.par.maxtemp - ...
            handles.par.mintemp)/handles.par.tempstep); %total number of temperatures
        handles.par.stab = 0.8;                     %stability condition for selecting the temperature
        handles.par.SWCycles = 256;                 %number of montecarlo iterations
        handles.par.KNearNeighb = 11;               %number of nearest neighbors
        handles.par.randomseed = 0;                 % if 0, random seed is taken as the clock value
        handles.par.fname_in = 'tmp_data';          % temporary filename used as input for SPC
        
        handles.par.min_clus_abs = minspk;              %minimum cluster size (absolute value)
        handles.par.min_clus_rel = 0.005;           %minimum cluster size (relative to the total nr. of spikes)
        handles.par.temp_plot = 'log';              %temperature plot in log scale
        handles.par.force_auto = 'n';               %automatically force membership if temp>3. % JN: MAY WANT TO MAKE NO SO THAT NON-SPIKES GET EXCLUDED MORE
        handles.par.max_spikes = 5000;              %maximum number of spikes to plot.
        
        handles.par.sr = 24000;                     %sampling frequency, in Hz.
        
        figure
        set(gcf,'PaperOrientation','Landscape','PaperPosition',[0.25 0.25 10.5 8])
        
        parsefieldnames = fieldnames(channelparse);
        
        for k=1:size(chan2anal,2)
            
            tic
            file_to_cluster = parsefieldnames(k); % field for current channel
            
            % LOAD SC DATA
            spikes = channelparse.(genvarname(file_to_cluster{1})).spikes;
            index = channelparse.(genvarname(file_to_cluster{1})).index;
            handles.par.fname = ['data_' char(file_to_cluster{1})];   %filename for interaction with SPC
            nspk = size(spikes,1);
            handles.par.min_clus = max(handles.par.min_clus_abs,handles.par.min_clus_rel*nspk);
            
            % CALCULATES INPUTS TO THE CLUSTERING ALGORITHM.
            inspk = wave_features(spikes,handles);              %takes wavelet coefficients.
            
            % GOES FOR TEMPLATE MATCHING IF TOO MANY SPIKES.
            if size(spikes,1)> handles.par.max_spk;
                naux = min(handles.par.max_spk,size(spikes,1));
                inspk_aux = inspk(1:naux,:);
            else
                inspk_aux = inspk;
            end
            
            %INTERACTION WITH SPC
            save(handles.par.fname_in,'inspk_aux','-ascii');
            [clu, tree] = run_cluster(handles);
            [temp] = find_temp(tree,handles);
            
            %DEFINE CLUSTERS
            class1=find(clu(temp,3:end)==0);
            class2=find(clu(temp,3:end)==1);
            class3=find(clu(temp,3:end)==2);
            class4=find(clu(temp,3:end)==3);
            class5=find(clu(temp,3:end)==4);
            class0=setdiff(1:size(spikes,1), sort([class1 class2 class3 class4 class5]));
            whos class*
            
            % IF TEMPLATE MATCHING WAS DONE, THEN FORCE
            if (size(spikes,1)> handles.par.max_spk || ...
                    (handles.par.force_auto == 'y'));
                classes = zeros(size(spikes,1),1);
                if length(class1)>=handles.par.min_clus; classes(class1) = 1; end
                if length(class2)>=handles.par.min_clus; classes(class2) = 2; end
                if length(class3)>=handles.par.min_clus; classes(class3) = 3; end
                if length(class4)>=handles.par.min_clus; classes(class4) = 4; end
                if length(class5)>=handles.par.min_clus; classes(class5) = 5; end
                f_in  = spikes(classes~=0,:);
                f_out = spikes(classes==0,:);
                class_in = classes(find(classes~=0),:);
                class_out = force_membership_wc(f_in, class_in, f_out, handles);
                classes(classes==0) = class_out;
                class0=find(classes==0);
                class1=find(classes==1);
                class2=find(classes==2);
                class3=find(classes==3);
                class4=find(classes==4);
                class5=find(classes==5);
            end
            
            %PLOTS
            clf
            clus_pop = [];
            ylimit = [];
            subplot(2,5,6)
            temperature=handles.par.mintemp+temp*handles.par.tempstep;
            switch handles.par.temp_plot
                case 'lin'
                    plot([handles.par.mintemp handles.par.maxtemp-handles.par.tempstep], ...
                        [handles.par.min_clus handles.par.min_clus],'k:',...
                        handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
                        tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:')
                case 'log'
                    semilogy([handles.par.mintemp handles.par.maxtemp-handles.par.tempstep], ...
                        [handles.par.min_clus handles.par.min_clus],'k:',...
                        handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
                        tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:')
            end
            axis tight;
            xlabel('Temperature');
            ylabel('Cluster Size')
            subplot(2,5,1)
            hold on
            cluster=zeros(nspk,2);
            cluster(:,2)= index';
            num_clusters = length(find([length(class1) length(class2) length(class3)...
                length(class4) length(class5) length(class0)] >= handles.par.min_clus));
            clus_pop = [clus_pop length(class0)];
            if length(class0) > handles.par.min_clus;
                subplot(2,5,5);
                max_spikes=min(length(class0),handles.par.max_spikes);
                plot(spikes(class0(1:max_spikes),:)','k');
                xlim([1 size(spikes,2)]);
                title('Cluster 0','Fontweight','bold')
                subplot(2,5,10)
                xa=diff(index(class0));
                [n,c]=hist(xa,0:1:500);
                bar(c(1:end-1),n(1:end-1))
                xlim([0 500])
                set(get(gca,'children'),'facecolor','k','EdgeColor','k','linewidth',0.01)
                xlabel([num2str(sum(n(1:3))) ' in < 3ms'])
                title([num2str(length(class0)) ' spikes']);
            end
            if length(class1) > handles.par.min_clus;
                clus_pop = [clus_pop length(class1)];
                subplot(2,5,1);
                max_spikes=min(length(class1),handles.par.max_spikes);
                plot(spikes(class1(1:max_spikes),:)','b');
                xlim([1 size(spikes,2)]);
                subplot(2,5,2);
                hold
                plot(spikes(class1(1:max_spikes),:)','b');
                plot(mean(spikes(class1,:),1),'k','linewidth',2)
                xlim([1 size(spikes,2)]);
                title('Cluster 1','Fontweight','bold')
                ylimit = [ylimit;ylim];
                subplot(2,5,7)
                xa=diff(index(class1));
                [n,c]=hist(xa,0:1:500);
                bar(c(1:end-1),n(1:end-1))
                xlim([0 500])
                set(get(gca,'children'),'facecolor','b','EdgeColor','b','linewidth',0.01)
                xlabel([num2str(sum(n(1:3))) ' in < 3ms'])
                title([num2str(length(class1)) ' spikes']);
                cluster(class1(:),1)=1;
            end
            if length(class2) > handles.par.min_clus;
                clus_pop = [clus_pop length(class2)];
                subplot(2,5,1);
                max_spikes=min(length(class2),handles.par.max_spikes);
                plot(spikes(class2(1:max_spikes),:)','r');
                xlim([1 size(spikes,2)]);
                subplot(2,5,3);
                hold
                plot(spikes(class2(1:max_spikes),:)','r');
                plot(mean(spikes(class2,:),1),'k','linewidth',2)
                xlim([1 size(spikes,2)]);
                title('Cluster 2','Fontweight','bold')
                ylimit = [ylimit;ylim];
                subplot(2,5,8)
                xa=diff(index(class2));
                [n,c]=hist(xa,0:1:500);
                bar(c(1:end-1),n(1:end-1))
                xlim([0 500])
                set(get(gca,'children'),'facecolor','r','EdgeColor','r','linewidth',0.01)
                xlabel([num2str(sum(n(1:3))) ' in < 3ms'])
                cluster(class2(:),1)=2;
                title([num2str(length(class2)) ' spikes']);
            end
            if length(class3) > handles.par.min_clus;
                clus_pop = [clus_pop length(class3)];
                subplot(2,5,1);
                max_spikes=min(length(class3),handles.par.max_spikes);
                plot(spikes(class3(1:max_spikes),:)','g');
                xlim([1 size(spikes,2)]);
                subplot(2,5,4);
                hold
                plot(spikes(class3(1:max_spikes),:)','g');
                plot(mean(spikes(class3,:),1),'k','linewidth',2)
                xlim([1 size(spikes,2)]);
                title('Cluster 3','Fontweight','bold')
                ylimit = [ylimit;ylim];
                subplot(2,5,9)
                xa=diff(index(class3));
                [n,c]=hist(xa,0:1:500);
                bar(c(1:end-1),n(1:end-1))
                xlim([0 500])
                set(get(gca,'children'),'FaceColor','g','EdgeColor','g','linewidth',0.01)
                xlabel([num2str(sum(n(1:3))) ' in < 3ms'])
                cluster(class3(:),1)=3;
                title([num2str(length(class3)) ' spikes']);
            end
            if length(class4) > handles.par.min_clus;
                clus_pop = [clus_pop length(class4)];
                cluster(class4(:),1)=4;
            end
            if length(class5) > handles.par.min_clus;
                clus_pop = [clus_pop length(class5)];
                subplot(2,5,1);
                cluster(class5(:),1)=5;
            end
            
            % Rescale spike's axis
            if ~isempty(ylimit)
                ymin = min(ylimit(:,1));
                ymax = max(ylimit(:,2));
            end
            if length(class1) > handles.par.min_clus; subplot(2,5,2); ylim([ymin ymax]); end
            if length(class2) > handles.par.min_clus; subplot(2,5,3); ylim([ymin ymax]); end
            if length(class3) > handles.par.min_clus; subplot(2,5,4); ylim([ymin ymax]); end
            if length(class0) > handles.par.min_clus; subplot(2,5,5); ylim([ymin ymax]); end
            
            title([pwd '/' char(file_to_cluster)],'Interpreter','none','Fontsize',14)
            features_name = handles.par.features;
            toc
            if print2file==0;
                print
            else
                set(gcf,'papertype','usletter','paperorientation','portrait','paperunits','inches')
                set(gcf,'paperposition',[.25 .25 10.5 7.8])
                eval(['print -djpeg fig2print_' char(file_to_cluster)]);
            end
            
            %SAVE FILES
            par = handles.par;
            cluster_class = cluster;
            outfile=['times_' char(file_to_cluster)];
            save(outfile, 'cluster_class', 'par', 'spikes', 'inspk')
            numclus=length(clus_pop)-1;
            outfileclus='cluster_results.txt';
            fout=fopen(outfileclus,'at+');
            fprintf(fout,'%s\t %s\t %g\t %d %g\t', char(file_to_cluster), features_name, temperature, numclus, handles.par.stdmin);
            for ii=1:numclus
                fprintf(fout,'%d\t',clus_pop(ii));
            end
            fprintf(fout,'%d\n',clus_pop(end));
            fclose(fout);
        end
        
        
    end
    function unitID = Populate_Results(channels2anal)
        chanfiles = textread('chanfiles.txt','%s');
        currunit = 1;
        
        spiketime = [];
        spikechannel = [];
        spikewave = [];
        unitID = [];
        
        for i = 1:length(chanfiles)
            
            chan = channels2anal(i);
            sortdata = load(strcat(['times_' char(chanfiles(i))]));
            numclus = max(sortdata.cluster_class(:,1));
            for k = 1:numclus
                indclus = find(sortdata.cluster_class(:,1) == k);
                if length(indclus) > minfire
                    spiketime = [spiketime sortdata.cluster_class(indclus,2)'./1000]; % convert back to seconds
                    spikechannel = [spikechannel chan*ones(size(indclus))'];
                    spikewave = [spikewave sortdata.spikes(indclus,:)'];
                    unitID = [unitID currunit*ones(size(indclus))'];
                    currunit = currunit+1;
                end
            end
            
            [spiketime temporalind] = sort(spiketime);
            spikechannel = spikechannel(temporalind);
            spikewave = spikewave(:,temporalind);
            unitID = unitID(temporalind);
            
        end
        
        % Delete temporary files and variables
        delete('Cluster.exe');
        delete('chanfiles.txt');
        delete('cluster_results.txt');
        for i = 1:length(chanfiles)
            delete(strcat([char(chanfiles(i)),'.mat']));
            delete(strcat(['times_',char(chanfiles(i)),'.mat']));
            delete(strcat(['fig2print_',char(chanfiles(i)),'.jpg']));
            delete('*.lab');
            delete('*.dg_01');
        end
        
    end
    function [chan2anal channelparse] = PepareBatchData(time,channel,waveform)
        
        channelparse = {};
        chan2anal = [];
        
        for chan = unique(channel)';
            
            ind = channel == chan;
            
            if ~isempty(ind)
                
                changood = chan;
                
                index = 1000.*time(ind); % wave_clus uses ms
                spikes = waveform(:,ind)';
                
                matfid = strcat(['chan',num2str(chan)]);
                
                channelparse.(genvarname(matfid)).index = index;
                channelparse.(genvarname(matfid)).spikes = spikes;
                
            else
                changood = [];
            end
            
            chan2anal = [chan2anal changood];
            
        end
        
    end
    function [inspk] = wave_features(spikes,handles)
        %Calculates the spike features
        
        scales = handles.par.scales;
        feature = handles.par.features;
        inputs = handles.par.inputs;
        nspk = size(spikes,1);
        ls = size(spikes,2);
        %set(handles.file_name,'string','Calculating spike features ...');
        
        % CALCULATES FEATURES
        switch feature
            case 'wav'
                cc=zeros(nspk,ls);
                if exist('wavedec')                             % Looks for Wavelets Toolbox
                    for i=1:nspk                                % Wavelet decomposition
                        [c,l]=wavedec(spikes(i,:),scales,'haar');
                        cc(i,1:ls)=c(1:ls);
                    end
                else
                    for i=1:nspk                                % Replaces Wavelets Toolbox, if not available
                        [c,l]=fix_wavedec(spikes(i,:),scales);
                        cc(i,1:ls)=c(1:ls);
                    end
                end
                for i=1:ls                                  % KS test for coefficient selection
                    thr_dist = std(cc(:,i)) * 3;
                    thr_dist_min = mean(cc(:,i)) - thr_dist;
                    thr_dist_max = mean(cc(:,i)) + thr_dist;
                    aux = cc(find(cc(:,i)>thr_dist_min & cc(:,i)<thr_dist_max),i);
                    if length(aux) > 10;
                        [ksstat]=test_ks(aux);
                        sd(i)=ksstat;
                    else
                        sd(i)=0;
                    end
                end
                [max ind]=sort(sd);
                coeff(1:inputs)=ind(ls:-1:ls-inputs+1);
            case 'pca'
                [C,S,L] = princomp(spikes);
                cc = S;
                inputs = 3;
                coeff(1:3)=[1 2 3];
        end
        
        %CREATES INPUT MATRIX FOR SPC
        inspk=zeros(nspk,inputs);
        for i=1:nspk
            for j=1:inputs
                inspk(i,j)=cc(i,coeff(j));
            end
        end
    end
    function [KSmax] = test_ks(x)
        %
        % Calculates the CDF (expcdf)
        %[y_expcdf,x_expcdf]=cdfcalc(x);
        
        yCDF = [];
        xCDF = [];
        x = x(~isnan(x));
        n = length(x);
        x = sort(x(:));
        % Get cumulative sums
        yCDF = (1:n)' / n;
        % Remove duplicates; only need final one with total count
        notdup = ([diff(x(:)); 1] > 0);
        x_expcdf = x(notdup);
        y_expcdf = [0; yCDF(notdup)];
        
        %
        % The theoretical CDF (theocdf) is assumed to be normal
        % with unknown mean and sigma
        
        zScores  =  (x_expcdf - mean(x))./std(x);
        
        %theocdf  =  normcdf(zScores , 0 , 1);
        mu = 0;
        sigma = 1;
        theocdf = 0.5 * erfc(-(zScores-mu)./(sqrt(2)*sigma));
        
        
        %
        % Compute the Maximum distance: max|S(x) - theocdf(x)|.
        %
        
        delta1    =  y_expcdf(1:end-1) - theocdf;   % Vertical difference at jumps approaching from the LEFT.
        delta2    =  y_expcdf(2:end)   - theocdf;   % Vertical difference at jumps approaching from the RIGHT.
        deltacdf  =  abs([delta1 ; delta2]);
        
        KSmax =  max(deltacdf);
    end
    function [clu, tree] = run_cluster(handles)
        dim=handles.par.inputs;
        fname=handles.par.fname;
        fname_in=handles.par.fname_in;
        
        % DELETE PREVIOUS FILES
        fileexist = exist([fname '.dg_01.lab'],'file');
        if(fileexist~=0)
            delete([fname '.dg_01.lab']);
            delete([fname '.dg_01']);
        end
        
        dat=load(fname_in);
        n=length(dat);
        fid=fopen(sprintf('%s.run',fname),'wt');
        fprintf(fid,'NumberOfPoints: %s\n',num2str(n));
        fprintf(fid,'DataFile: %s\n',fname_in);
        fprintf(fid,'OutFile: %s\n',fname);
        fprintf(fid,'Dimensions: %s\n',num2str(dim));
        fprintf(fid,'MinTemp: %s\n',num2str(handles.par.mintemp));
        fprintf(fid,'MaxTemp: %s\n',num2str(handles.par.maxtemp));
        fprintf(fid,'TempStep: %s\n',num2str(handles.par.tempstep));
        fprintf(fid,'SWCycles: %s\n',num2str(handles.par.SWCycles));
        fprintf(fid,'KNearestNeighbours: %s\n',num2str(handles.par.KNearNeighb));
        fprintf(fid,'MSTree|\n');
        fprintf(fid,'DirectedGrowth|\n');
        fprintf(fid,'SaveSuscept|\n');
        fprintf(fid,'WriteLables|\n');
        fprintf(fid,'WriteCorFile~\n');
        if handles.par.randomseed ~= 0
            fprintf(fid,'ForceRandomSeed: %s\n',num2str(handles.par.randomseed));
        end
        fclose(fid);
        
        [str,maxsize,endian]=computer;
        handles.par.system=str;
        switch handles.par.system
            case {'PCWIN','PCWIN64'}
                if exist([pwd '\cluster.exe'])==0
                    directory = which('cluster.exe');
                    copyfile(directory,pwd);
                end
                dos(sprintf('cluster.exe %s.run',fname));
            case {'MAC'}
                if exist([pwd '/cluster_mac.exe'])==0
                    directory = which('cluster_mac.exe');
                    copyfile(directory,pwd);
                end
                run_mac = sprintf('./cluster_mac.exe %s.run',fname);
                unix(run_mac);
            case {'MACI'}
                if exist([pwd '/cluster_maci.exe'])==0
                    directory = which('cluster_maci.exe');
                    copyfile(directory,pwd);
                end
                run_maci = sprintf('./cluster_maci.exe %s.run',fname);
                unix(run_maci);
            otherwise  %(GLNX86, GLNXA64, GLNXI64 correspond to linux)
                if exist([pwd '/cluster_linux.exe'])==0
                    directory = which('cluster_linux.exe');
                    copyfile(directory,pwd);
                end
                run_linux = sprintf('./cluster_linux.exe %s.run',fname);
                unix(run_linux);
        end
        
        clu=load([fname '.dg_01.lab']);
        tree=load([fname '.dg_01']);
        delete(sprintf('%s.run',fname));
        delete *.mag
        delete *.edges
        delete *.param
        delete(fname_in);
    end
    function [temp] = find_temp(tree,handles)
        % Selects the temperature.
        
        num_temp=handles.par.num_temp;
        min_clus=handles.par.min_clus;
        
        aux =diff(tree(:,5));   % Changes in the first cluster size
        aux1=diff(tree(:,6));   % Changes in the second cluster size
        aux2=diff(tree(:,7));   % Changes in the third cluster size
        aux3=diff(tree(:,8));   % Changes in the third cluster size
        
        temp = 1;         % Initial value
        
        for t=1:num_temp-1;
            % Looks for changes in the cluster size of any cluster larger than min_clus.
            if ( aux(t) > min_clus | aux1(t) > min_clus | aux2(t) > min_clus | aux3(t) >min_clus )
                temp=t+1;
            end
        end
        
        %In case the second cluster is too small, then raise the temperature a little bit
        if (temp == 1 & tree(temp,6) < min_clus)
            temp = 2;
        end
    end

end







