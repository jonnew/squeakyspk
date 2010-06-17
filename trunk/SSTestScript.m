% Load data into data structs
spkdat = loadspike('20100604_16269_spont.spk');
stimdat = loadstim('20100604_16269_stim.stim');
spontdat = loadspike('20100604_16269_spont.spk');

% Instantiate a SqueakySpk Object
SStest = SqueakySpk(spkdat,stimdat,spontdat);

% Remove meaningless channels
SStest.RemoveChannel();

% Remove spikes with blanks
SStest.RemoveSpkWithBlank();

% Perform a hard p2p cut at 175 uV
SStest.HardThreshold(175);

% Clustering
SStest.WaveClus(3,20,'wav',1);
SStest.RemoveUnit(0); % remove unsorted data

% BioFilt
% SStest.BioFilt();

% Examime some data to make sure results of sorting and cleaning look good
SStest.RasterWave_Comp([200 250],'both');