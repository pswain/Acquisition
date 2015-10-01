function guiconfig2(microscope)

global mmc;
global gui;
% global acq;
import mmcorej.*;
mmc = gui.getCore;
microscope.loadConfig;
microscope.setInitialChannel;
mmc.setExposure(10);
%clear all previous acquisitions
gui.closeAllAcquisitions();
gui.clearMessageWindow();
mmc.stopSequenceAcquisition;%Will allow acquisition to run if someone has 
%forgotten to stop the 'live' mode from the mm GUI

%Initialisation functions: unique to each microscope
microscope.initializeScope;
pause on;
%gui.refreshGUI
