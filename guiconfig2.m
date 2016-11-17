function guiconfig2(microscope)

global mmc;
global gui;
% global acq;
import mmcorej.*;
if strcmp(microscope.Name,'Joker')
    mmc=CMMCore;
else
    gui.getCore;
end
microscope.loadConfig;
microscope.setInitialChannel;
mmc.setExposure(10);
mmc.stopSequenceAcquisition;%Will allow acquisition to run if someone has 
%forgotten to stop the 'live' mode from the mm GUI

%Initialisation functions: unique to each microscope
microscope.initializeScope;
pause on;
%gui.refreshGUI