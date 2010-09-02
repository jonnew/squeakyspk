	********************************************************************	                     				S	                        S Q U E A K Y S P K
	********************************************************************
	Name: SqueakySpk
	Authors: Jon Newman <jnewman6 at gatech dot edu>
 		 Riley Zeller-Townson	
	********************************************************************
	
	NOTE: 	This class is a work in progress. It is licensed under GPLv3.
		If you wish to contribute to the source, report a bug etc,
		please request write permission to our google-code repository
		at http://code.google.com/p/squeakyspk/.
	
	DESCRIPTION:
	
	Squeaky Spk is a MATLAB(R) class that is useful for artifact removal,
	spike-sorting, basic analysis, and storage of extracellular neural
	recordings.
	
	It is useful for handling data of the form T, C, and W where T is an NX1
	vector of spike times, C is an NX1 vector of channel indicies that
	correspond to the spike times in T and W is an NXM matrix of spike waveforms
	('snips') that correspond to the spike times in T.
	
	********************************************************************
	INSTALLATION:
	
	1. Place the SqueakySpk directory somewhere on your hard-drive. For PC
	   users I recommend:

		C:Users/<your account>/MATLAB
	
	2. Open Matlab. Add SqueakySpk to your matlab path using
	
	     	File > Set Path
	
	3. Click 'Add with Subfolders' and navigate to the SqueakySpk main 
	   directory. Hit OK and then click save.  
	
	********************************************************************
	USAGE:

	SqueakySpk is a MATLAB(R) class. This means it has properties (which
	which will store your data) along with methods that can act on
	that data. It is important to recognize that SqueakySpk never deletes
	raw data, it only modifies the way in which this data is accessed.

	For example, if I had my data structure spkdat with fields 'time',
	'channel' and 'waveform' as mentioned above, a typical workflow 
 	for using Squeaky spikes would be as follows:

		% Object ID
		fid = '20100604_16269_SS';


	This example uses the loadspike method that works with the output of
	John Rolston's NeuroRighter recording and stimulation system.
	SqueakySpk can be used with any recording system so long as data is
	entered as a struct with 'time', 'channel', and 'waveform' data fields. 
	In addition to storage of spiking data, there are overload inputs that
	can store stimulus data by inputing a stimulus struct with fields 'time'
	and 'channel' where 'time' is a WX1 vector of stimulus times and 'channel'
	is a WX1 vector of corresponding stimulus channels.

		% Load data into data structs
		spkdat = loadspike('20100604_16269_spont.spk');
		stimdat = loadstim('20100604_16269_stim.stim');
		spontdat = loadspike('20100604_16269_spont.spk');

	Here spkdat is a struct with fields spkdat.time, spkdat.channel, and
	spkdat.waveform as mentioned above.

		% Instantiate a SqueakySpk Object
		SS = SqueakySpk('20100604_16269_test',25000,1/1200,spkdat,stimdat,spontdat);

		% Remove meaningless channels (default is for MCS arrays)
		SS.RemoveChannel();

		% Remove spikes with blanks due to artifact suppression
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

		% File ID's
		SSfid = '20100622_poisstim_wdeletes30_100_16269_SS';
		spkfid = '20100622_poisstim_wdeletes30_100_16269.spk';

		% Load the data
		spkdat = loadspike(spkfid);


	For help on the methods available once you have created a SqueakySpk
	object, at the command line, enter the name of your SS object:

		>> SSobj

	This will provide information on the properties and methods avaiable to
	you. Next type 

		>> help <method you are interested in>

	at the command line to get further help on a given method. 

	For an example of SqueakySpk in action, run the example script that
	is provided in the main SqueakySpk directory, SSTestScript.m
	
	********************************************************************



