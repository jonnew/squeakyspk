function success = WaveClus(SS,maxclus,minspk,decompmeth,plotall,ploton)
% WAVECLUS(SS) Ported version of Rodrigo Quian Quiroga's wave-clus combined
% wavelet/superparamagnetic clustering algorithm. Citation: Quiroga, Q.,
% Nadasdy, Z., & Ben-Shaul, Y. (2004). Unsupervised spike detection and
% sorting with wavelets and superparamagnetic clustering. Neural
% Computation, 1687, 1661�1687.
%
% WAVECLUS(SS,MAXCLUS,MINSPK,DECOMPMETH) Perform spike sorting on the
% multichannel spike data within the SS object. MAXCLUS defines the
% maximual number of cluster (units) that are allowed on a particular
% channel. MINSPK is the minimum number of spikes required to for a cluster
% to be considered a unique unit. If this number is not met, the algorithm
% attempts to combine the cluster with the others or rejects the spikes
% entirely. DECOMPMETH is the spectral projection method that is used to
% reduce the dimensionality of the spike waveforms before clustering. The
% default method,'wav', is a wavelet transform, using a haar wavelet. 'pca'
% can be used for principle component projection. The first 3 principle
% components are used for clustering.
%
% Default parameters:
%       MAXCLUS = 3
%       MINSPK  = 20
%       DECOMPMETH = 'wav';
%
% WAVECLUS(SS,...,PLOTALL,PLOTON) Changes the ploting options for the
% algorithm. PLOTALL is a boolean that determins whether waveforms are
% plotted or just the average waveform for each cluster. PLOTON is a
% boolean that determines whether any plotting is performed or not.
%
% SUCCESS = WAVECLUS(SS,...) Boolean flag indicating whether algorithm ran
% to completion.
%
% MAIN OUTPUT:
% A modified unit field in the SqueakySpk object (SS.unit)
%
%   Created by: Jon Newman (jnewman6 at gatech dot edu)
%   Location: The Georgia Institute of Technology
%   Created on: July 30, 2009
%   Last modified: Feb 21, 2013
%
%   Licensed under the GPL: http://www.gnu.org/licenses/gpl.txt

if nargin < 6 || isempty(ploton)
    ploton = 1;
end
if nargin < 5 || isempty(plotall)
    plotall = 1;
end
if nargin < 4 || isempty(decompmeth)
    decompmeth = 'wav';
end
if nargin < 3 || isempty(minspk)
    minspk = 20;
end
if nargin < 2 || isempty(maxclus)
    maxclus = 3;
end
if minspk < 2
    error('Please raise the minimal number of spikes to form a cluster or there may not be enough data on some channels to perform clustering at all.')
end
if maxclus >5
    error('There is a maximum of 5 units per channel.')
end

% Waveclus for main data, only perform clustering on clean data all else is
% not clustered
time = SS.time(SS.clean);
channel = SS.channel(SS.clean);
waveform = SS.waveform(:,SS.clean);
id = SS.id(SS.clean);

uniquechan = unique(channel);

if isempty(time)
    warning('It looks like there are no clean spikes in these data, so there is nothing to sort. Exiting WaveClus');
    success = 0;
    return
end

% handle for this waveclus session
hand = ['tmp-waveclus_' num2str(round(100000000000*rand))];
mkdir(hand)

[chan2anal, chanparse] = PepareBatchData(time,channel,waveform,id,minspk);
if isempty(chanparse)
    warning('It looks like there are very few clean spikes in the evoked data set, so sorting cannot be performed');
    pause(5);
    success = 0;
    return;
else
    clustresults = Do_Clustering(chanparse,chan2anal,maxclus,minspk,plotall);
    finresult = Populate_Results(uniquechan,chan2anal,clustresults,time,channel,waveform,id);
    
    % Add dirty data back, but with the 0 unit specification
    [SS.time, idx] = sort([finresult.time;SS.time(~SS.clean)]);
    channel = [finresult.channel;SS.channel(~SS.clean)];
    SS.channel = channel(idx);
    waveform = [finresult.waveform SS.waveform(:,~SS.clean)];
    SS.waveform = waveform(:,idx);
    unit = [finresult.unit;zeros(sum(~SS.clean),1)];
    SS.unit = unit(idx);
    clean = [ones(size(finresult.time));zeros(size(SS.time(~SS.clean)))];
    SS.clean = logical(clean(idx));
    id = [finresult.id; SS.id(~SS.clean)];
    SS.id = id(idx);
    
    SS.avgwaveform.avg = finresult.meanwave;
    SS.avgwaveform.std = finresult.sdwave;
end

rmdir(hand,'s');

% Add waveclus to method log
SS.methodlog = [SS.methodlog '<WaveClus>'];
success = 1;
return;

% Functions called for clustering
    function clusterresults = Do_Clustering(channelparse,chan2anal,maxclus,minspk,plotall)
        
        print2file = 0;                             %for saving printouts.
        print2paper = 0;                            %For printing to a .jpg
        
        [str,maxsize,endian]=computer;
        handles.par.system=str;                     % Find out what type of OS we are on
        
        handles.par.w_pre=22;                       %number of pre-event data points stored
        handles.par.w_post=52;                      %number of post-event data points stored
        handles.par.detection = 'pos';              %type of threshold
        handles.par.stdmin = 5.00;                  %minimum threshold
        handles.par.stdmax = 50;                    %maximum threshold
        handles.par.interpolation = 'y';            %interpolation for alignment
        handles.par.int_factor = 2;                 %interpolation factor
        handles.par.detect_fmin = 300;              %high pass filter for detection (default 300)
        handles.par.detect_fmax = 5000;             %low pass filter for detection (default 3000)
        handles.par.sort_fmin = 300;                %high pass filter for sorting (default 300)
        handles.par.sort_fmax = 5000;               %low pass filter for sorting (default 3000)
        
        handles.par.max_spk = 1024;                 % max. # of spikes before starting templ. match.
        handles.par.template_type = 'center';       % nn, center, ml, mahal
        handles.par.template_sdnum = 3;             % max radius of cluster in std devs. % JN: MAY WANT TO MAKE LOWER SO THAT NON-SPIKES GET EXCLUDED MORE
        
        handles.par.features = decompmeth;          %choice of spike features
        handles.par.inputs = 10;                    %number of inputs to the clustering
        handles.par.scales = 4;                     %scales for wavelet decomposition
        if strcmp(handles.par.features,'pca');      %number of inputs to the clustering for pca
            handles.par.inputs=3;
        end
        
        handles.par.mintemp = 0.01;                 %minimum temperature
        handles.par.maxtemp = 0.25;                 %maximum temperature
        handles.par.tempstep = 0.01;                %temperature step
        handles.par.num_temp = floor(...
            (handles.par.maxtemp - ...
            handles.par.mintemp)/handles.par.tempstep); %total number of temperatures
        handles.par.stab = 0.8;                     %stability condition for selecting the temperature
        handles.par.SWCycles = 256;                 %number of montecarlo iterations
        handles.par.KNearNeighb = 11;               %number of nearest neighbors
        handles.par.randomseed = 0;                % if 0, random seed is taken as the clock value
        
        switch handles.par.system
            case {'PCWIN','PCWIN64'}
                handles.par.fname_in = ['.\' char(hand) '\temp_data'];
            case {'MAC','MACI'}
                handles.par.fname_in = ['./' char(hand) '/temp_data'];
            otherwise  %(GLNX86, GLNXA64, GLNXI64 correspond to linux)
                handles.par.fname_in = ['./' char(hand) '/temp_data'];
        end
        
        handles.par.min_clus_abs = minspk;          %minimum cluster size (absolute value)
        handles.par.min_clus_rel = 0.005;           %minimum cluster size (relative to the total nr. of spikes)
        handles.par.temp_plot = 'log';              %temperature plot in log scale
        handles.par.force_auto = 'n';               %automatically force membership if temp>3. % JN: MAY WANT TO MAKE NO SO THAT NON-SPIKES GET EXCLUDED MORE
        handles.par.max_spikes = 5000;              %maximum number of spikes to plot.
        
        handles.par.sr = 25000;                     %sampling frequency, in Hz.
        
        parsefieldnames = fieldnames(channelparse);
        clusterresults = {};
        
        
        for k = 1:size(chan2anal,2)
            
            tic
            file_to_cluster = parsefieldnames(k); % field for current channel
            
            % LOAD SC DATA
            ids  = channelparse.(genvarname(file_to_cluster{1})).id;
            spikes = channelparse.(genvarname(file_to_cluster{1})).spikes;
            index = channelparse.(genvarname(file_to_cluster{1})).time;
            
            switch handles.par.system
                case {'PCWIN','PCWIN64'}
                    handles.par.fname = ['.\' char(hand) '\data_' char(file_to_cluster{1})];
                case {'MAC','MACI'}
                    handles.par.fname = ['./' char(hand) '/data_' char(file_to_cluster{1})];
                otherwise  %(GLNX86, GLNXA64, GLNXI64 correspond to linux)
                    handles.par.fname = ['./' char(hand) '/data_' char(file_to_cluster{1})];  %filename for interaction with SPC
            end
            nspk = size(spikes,1);
            handles.par.min_clus = max(handles.par.min_clus_abs,handles.par.min_clus_rel*nspk);
            
            % CALCULATES INPUTS TO THE CLUSTERING ALGORITHM.
            inspk = wave_features(spikes,handles);              %takes wavelet coefficients.
            
            % GOES FOR TEMPLATE MATCHING IF TOO MANY SPIKES.
            if size(spikes,1)> handles.par.max_spk;
                %naux = min(handles.par.max_spk,size(spikes,1));
                r = randperm(size(spikes,1));
                r_ind_train = r(1:handles.par.max_spk);
                r_ind_match = r(handles.par.max_spk+1:end);
                inspk_aux = inspk(r_ind_train,:);
            else
                r_ind_train = 1:size(spikes,1);
                inspk_aux = inspk;
            end
            
            %INTERACTION WITH SPC
            save(handles.par.fname_in,'inspk_aux','-ascii');
            [clu, tree] = run_cluster(handles);
            [temp] = find_temp(tree,handles);
            
            %DEFINE CLUSTERS
            class1 = [];
            class2 = [];
            class3 = [];
            class4 = [];
            class5 = [];
            switch maxclus
                case 1
                    class1=r_ind_train(clu(temp,3:end)==0);
                    class0=setdiff(1:size(spikes,1), sort(class1));
                case 2
                    class1=r_ind_train(clu(temp,3:end)==0);
                    class2=r_ind_train(clu(temp,3:end)==1);
                    class0=setdiff(1:size(spikes,1), sort([class1 class2]));
                case 3
                    class1=r_ind_train(clu(temp,3:end)==0);
                    class2=r_ind_train(clu(temp,3:end)==1);
                    class3=find(clu(temp,3:end)==2);
                    class0=setdiff(1:size(spikes,1), sort([class1 class2 class3]));
                case 4
                    class1=r_ind_train(clu(temp,3:end)==0);
                    class2=r_ind_train(clu(temp,3:end)==1);
                    class3=r_ind_train(clu(temp,3:end)==2);
                    class4=r_ind_train(clu(temp,3:end)==3);
                    class0=setdiff(1:size(spikes,1), sort([class1 class2 class3 class4]));
                case 5
                    class1=r_ind_train(clu(temp,3:end)==0);
                    class2=r_ind_train(clu(temp,3:end)==1);
                    class3=r_ind_train(clu(temp,3:end)==2);
                    class4=r_ind_train(clu(temp,3:end)==3);
                    class5=r_ind_train(clu(temp,3:end)==4);
                    class0=setdiff(1:size(spikes,1), sort([class1 class2 class3 class4 class5]));
            end
            
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
                f_out = spikes(r_ind_match,:);
                class_in = classes(classes~=0);
                class_out = force_membership_wc(f_in, class_in, f_out, handles);
                classes(r_ind_match) = class_out;
                class0=find(classes==0);
                class1=find(classes==1);
                class2=find(classes==2);
                class3=find(classes==3);
                class4=find(classes==4);
                class5=find(classes==5);
            end
            
            %PLOTS
            clus_pop = [];
            cluster=zeros(nspk,2);
            cluster(:,2) = index';
            meanwave = [];
            sdwave = [];
            
            clus_pop = [clus_pop length(class0)];
            cluster(class0(:),1)=0;
            if length(class1) > handles.par.min_clus;
                meanwave1 = mean(spikes(class1,:),1);
                sdwave1 = std(spikes(class1,:),1);
                meanwave = [meanwave meanwave1'];
                sdwave = [sdwave sdwave1'];
                clus_pop = [clus_pop length(class1)];
                cluster(class1(:),1)=1;
            end
            if length(class2) > handles.par.min_clus;
                meanwave2 = mean(spikes(class2,:),1);
                sdwave2 = std(spikes(class2,:),1);
                meanwave = [meanwave meanwave2'];
                sdwave = [sdwave sdwave2'];
                clus_pop = [clus_pop length(class2)];
                cluster(class2(:),1)=2;
            end
            if length(class3) > handles.par.min_clus;
                meanwave3 = mean(spikes(class3,:),1);
                sdwave3 = std(spikes(class3,:),1);
                meanwave = [meanwave meanwave3'];
                sdwave = [sdwave sdwave3'];
                clus_pop = [clus_pop length(class3)];
                cluster(class3(:),1)=3;
            end
            if length(class4) > handles.par.min_clus;
                meanwave4 = mean(spikes(class4,:),1);
                sdwave4 = std(spikes(class4,:),1);
                meanwave = [meanwave meanwave4'];
                sdwave = [sdwave sdwave4'];
                clus_pop = [clus_pop length(class4)];
                cluster(class4(:),1)=4;
            end
            if length(class5) > handles.par.min_clus;
                meanwave5 = mean(spikes(class5,:),1);
                sdwave5 = std(spikes(class1,:),1);
                meanwave = [meanwave meanwave5'];
                sdwave = [sdwave sdwave5'];
                clus_pop = [clus_pop length(class5)];
                subplot(2,5,1);
                cluster(class5(:),1)=5;
            end
            
            % PLOTS (if requested by user)
            if (ploton)
                clf
                set(gcf,'PaperOrientation','Landscape','PaperPosition',[0.25 0.25 10.5 8])
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
                num_clusters = length(find([length(class1) length(class2) length(class3)...
                    length(class4) length(class5) length(class0)] >= handles.par.min_clus));
                if length(class0) > handles.par.min_clus;
                    subplot(2,5,5);
                    max_spikes=min(length(class0),handles.par.max_spikes);
                    if plotall
                        plot(spikes(class0(1:max_spikes),:)','k');
                    end
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
                    subplot(2,5,1);
                    max_spikes=min(length(class1),handles.par.max_spikes);
                    plot(spikes(class1(1:max_spikes),:)','b');
                    xlim([1 size(spikes,2)]);
                    subplot(2,5,2);
                    hold
                    if plotall
                        plot(spikes(class1(1:max_spikes),:)','b');
                    end
                    plot(meanwave1,'k','linewidth',2)
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
                    subplot(2,5,1);
                    max_spikes=min(length(class2),handles.par.max_spikes);
                    plot(spikes(class2(1:max_spikes),:)','r');
                    xlim([1 size(spikes,2)]);
                    subplot(2,5,3);
                    hold
                    if plotall
                        plot(spikes(class2(1:max_spikes),:)','r');
                    end
                    plot(meanwave2,'k','linewidth',2)
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
                    subplot(2,5,1);
                    max_spikes=min(length(class3),handles.par.max_spikes);
                    plot(spikes(class3(1:max_spikes),:)','g');
                    xlim([1 size(spikes,2)]);
                    subplot(2,5,4);
                    hold
                    if plotall
                        plot(spikes(class3(1:max_spikes),:)','g');
                    end
                    plot(meanwave3,'k','linewidth',2)
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
                
                if print2paper == 1;
                    print
                end
                if print2file == 1;
                    set(gcf,'papertype','usletter','paperorientation','portrait','paperunits','inches')
                    set(gcf,'paperposition',[.25 .25 10.5 7.8])
                    eval(['print -djpeg fig2print_' char(file_to_cluster)]);
                end
                
                drawnow;
            end
            
            
            %Output
            clusterresults.(genvarname(file_to_cluster{1})).class = cluster(:,1);
            clusterresults.(genvarname(file_to_cluster{1})).time = index;
            clusterresults.(genvarname(file_to_cluster{1})).channel = chan2anal(k)*ones(size(cluster,1),1);
            clusterresults.(genvarname(file_to_cluster{1})).waveform = spikes;
            clusterresults.(genvarname(file_to_cluster{1})).id = ids;
            clusterresults.(genvarname(file_to_cluster{1})).meanwave = meanwave;
            clusterresults.(genvarname(file_to_cluster{1})).sdwave = sdwave;
            
        end
    end

    function result = Populate_Results(uniquechan, channels2anal,clusterresults,time,channel,waveform,id)
        
        % DELETE ANY RESIDUAL FILES
        delete *.dg_01.lab
        delete *.dg_01
        delete *.run
        delete *.mag
        delete *.edges
        delete *.param
        
        currunit = 1;
        spiketime = [];
        spikechannel = [];
        spikewave = [];
        unitID = [];
        absID = [];
        
        meanwave = [];
        sdwave = [];
        
        for i = uniquechan'
            
            if ismember(i,channels2anal)
                
                sortdata = clusterresults.(genvarname(['chan' num2str(i)]));
                numclus = max(sortdata.class);
                
                for k = 0:numclus
                    
                    % Gather indicies of spike entries belonging to class k
                    ind = sortdata.class == k;
                    
                    if k == 0 % unsorted case
                        
                        spiketime = [spiketime; sortdata.time(ind)]; % convert back to seconds
                        spikechannel = [spikechannel; sortdata.channel(ind)];
                        spikewave = [spikewave sortdata.waveform(ind,:)'];
                        unitID = [unitID;zeros(sum(ind),1)];
                        absID = [absID; sortdata.id(ind)];
                        
                    else % sorted units
                        
                        spiketime = [spiketime; sortdata.time(ind)]; % convert back to seconds
                        spikechannel = [spikechannel; sortdata.channel(ind)];
                        spikewave = [spikewave sortdata.waveform(ind,:)'];
                        unitID = [unitID; currunit*ones(sum(ind),1)];
                        meanwave = [meanwave sortdata.meanwave(:,k)];
                        sdwave = [sdwave sortdata.sdwave(:,k)];
                        absID = [absID; sortdata.id(ind)];
                        
                        % Increment the current unit number
                        currunit = currunit+1;
                    end
                end
            else
                ind = (channel == i);
                spiketime = [spiketime; time(ind)];
                spikechannel = [spikechannel; channel(ind)];
                spikewave = [spikewave waveform(:,ind')];
                unitID = [unitID; zeros(size(time(ind)))];
                absID = [absID; id(ind)];
            end
        end
        
        result.time = spiketime;
        result.channel = spikechannel;
        result.waveform = spikewave;
        result.unit = unitID;
        result.meanwave = meanwave;
        result.sdwave = sdwave;
        result.id = absID;
        
    end

    function [chan2anal, channelparse] = PepareBatchData(time,channel,waveform,id,minspk)
        
        chan2anal = [];
        
        for chan = unique(channel)';
            
            ind = (channel == chan);
            
            % If there were enough spikes detected on this channel, then
            % append its name to the list of channels to be sorted.
            if sum(ind) >= minspk
                
                % Generate Field name
                fld = strcat(['chan',num2str(chan)]);
                
                % Populate a struct containing the data for this channel
                channelparse.(genvarname(fld)).id = id(ind);
                channelparse.(genvarname(fld)).time = time(ind);
                channelparse.(genvarname(fld)).spikes = waveform(:,ind)';
                
                % Update the channels to analyze list
                chan2anal = [chan2anal chan];
            end
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
                    aux = cc((cc(:,i)>thr_dist_min & cc(:,i)<thr_dist_max),i);
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
        inspk = zeros(nspk,inputs);
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
        
        delete *.dg_01.lab
        delete *.dg_01
        
        % Assign new names
        fname=handles.par.fname;
        fname_in=handles.par.fname_in;
        
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
        
        switch handles.par.system
            case {'PCWIN','PCWIN64'}
                if exist([pwd '\cluster.exe'])==0
                    directory = which('cluster.exe');
                    copyfile(directory,[pwd '\' char(hand)]);
                end
                %                    display('.\\%s\\Cluster.exe %s.run',hand,fname);
                dos(sprintf('.\\%s\\Cluster.exe %s.run',hand,fname));
            case {'MAC'}
                directory = which('cluster_mac.exe');
                run_mac = sprintf([directory ' %s.run'],fname);
                unix(run_mac);
            case {'MACI','MACI64'}
                directory = which('cluster_maci.exe');
                run_maci = sprintf([directory ' %s.run'],fname);
                unix(run_maci);
            otherwise  %(GLNX86, GLNXA64, GLNXI64 correspond to linux)
                directory = which('cluster_linux.exe');
                run_linux = sprintf([directory ' %s.run'],fname);
                unix(run_linux);
        end
        
        clu=load([fname '.dg_01.lab']);
        tree=load([fname '.dg_01']);
        
        delete(sprintf('%s.run',fname));
        delete *cluster*.exe
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