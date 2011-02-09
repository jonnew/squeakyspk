% Object FID
fid = 'SS_example';

% Load data into data structs (change path for windoze machine)
spkdat = loadspike([pwd '/example-data.spk']);
stimdat = loadstim([pwd '/example-data.stim']);

% Instantiate a SqueakySpk Object
SS = SqueakySpk(fid,25000,1,spkdat,stimdat);

% Remove meaningless channels
SS.RemoveChannel();

% Remove spikes with blanks
SS.RemoveSpkWithBlank();

% Perform a hard p2p cut at 250 uV
SS.HardThreshold(250);

% Clustering
SS.WaveClus(3,20,'wav',1);
SS.RemoveUnit(0); % remove unsorted data

%% Weed units by average waveforms
SS.WeedUnitByWaveform();

%% Calculate ASDR
SS.ASDR

%% Examime some data to make sure results of sorting and cleaning look good
SS.RasterWave;

%% Save the SS data object
SS.Save

%% Clear everything and just load the SS object you just saved
clear all
fid = 'SS_example';
load([fid '.SS'],'-mat')

SS % look at the state of the object