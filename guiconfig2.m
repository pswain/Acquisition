function guiconfig2(microscope)

global mmc;
global gui;
% global acq;
mmc=gui.getCore;
microscope.loadConfig;
microscope.setInitialChannel;

mmc.setConfig('Channel',microscope.InitialChannel);
mmc.setExposure(10);
%clear all previous acquisitions
gui.closeAllAcquisitions();
gui.clearMessageWindow();
mmc.stopSequenceAcquisition;%Will allow acquisition to run if someone has 
%forgotten to stop the 'live' mode from the mm GUI

%Initialisation functions: unique to each microscope
microscope.Initialize;
mmc.setAutoShutter(1);
pause on;
gui.refreshGUI
