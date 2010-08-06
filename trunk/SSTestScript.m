% Object FID
fid = '20100604_16269_SS';

% Load data into data structs
spkdat = loadspike('20100604_16269_spont.spk');
stimdat = loadstim('20100604_16269_stim.stim');
spontdat = loadspike('20100604_16269_spont.spk');

% Instantiate a SqueakySpk Object
SS = SqueakySpk('20100604_16269_test',25000,1/1200,spkdat,stimdat,spontdat);

% Remove meaningless channels
SS.RemoveChannel();

% Remove spikes with blanks
SS.RemoveSpkWithBlank();

% Perform a hard p2p cut at 175 uV
SS.HardThreshold(175);

% Clustering
SS.WaveClus(3,20,'wav',1);
SS.RemoveUnit(0); % remove unsorted data

% Weed units by average waveforms
SS.WeedUnitByWaveform();

% Examime some data to make sure results of sorting and cleaning look good
SS.RasterWave([200 210],'both');

% Save the SS data object
SS.Save

%% Clear everything and just load the SS object you just saved
clear all
load('20100604_16269_test.SS','-mat')