%Script for multidimensional acquisition in MATLAB - based on the beanshell
%script "TestAcq.bsh" by Nenad Amodaj

%clear all previous acquisitions

gui.closeAllAcquisitions();
gui.clearMessageWindow();

%User input - please fill this part in - later will get most of it from the
%gui

% // file locations
%save=acq.getSaveFiles();
%if save==1 
directory='C:\AcquisitionData\Swain Lab\Ivan\23_9_10\test';%later will get this from the gui
acqName = 'testing';%later will get this from the gui
%end

numTimepoints = 3;%number of timepoints
channels = {'DIC'; 'GFP'};
sizeChannels=size(channels);
numChannels=sizeChannels(1);
% Color[] colors = {Color.BLUE, Color.GREEN, Color.RED};
%looks like color objects are a java thing - will need to get these from
%the gui to set.
exposures = [10, 100];%exposure times in ms
numSlices = 1;
interval=10;%interval in s
intervalMs = (interval*1000);
channelGroup = 'Dye set';
%will add z interval here for z stack acquisition

% // create acquisition and set options
gui.openAcquisition(acqName, directory, numTimepoints, numChannels, numSlices);
% for (int i=0; i<colors.length; i++)
%    gui.setChannelColor(acqName, i, colors[i]);

for i=1:numChannels
    
     gui.setChannelName(acqName, (i-1), channels(i));
end
  
tic%start of timer - toc statement will give time since this tic

for i=1:numTimepoints
    startOfTimepoint=toc;
    endOfTimepoint=(startOfTimepoint+interval);
    for j=1:numChannels
    %gui.message('Acquiring timepoint ' + (i-1) + ', channel ' + channels(j) + '.');
    mmc.setExposure(exposures(j));
    mmc.setConfig(channelGroup, channels(j));
    mmc.waitForConfig(channelGroup, channels(j));
    gui.snapAndAddImage(acqName, (i-1), (j-1), 0);% the 0 here is for the slice - will need another loop to do Z stacks
    end
    %    // set channel contrast based on the first frame
        if (i==0) 
        gui.setContrastBasedOnFrame(acqName, i, 0);
        end
        %Timer while statement to wait for the correct time to start the
        %next z stack.
        currTime=toc;
        while (currTime<endOfTimepoint)
        currTime=toc;
        end;
   

end
gui.closeAcquisition(acqName);

%to add: z stacks - with z section interval and number of slices as input
%........point visiting - using XY stage and PFS offset to define positions
%........Event triggering - using TTL inputs to drive syringe pump programs
%........Image processing - flip the DIC image and shift to allign with
%        fluorescence
%Other optional ideas - varying exposure times with points - for optimizing
%for bleaching
%- custom txt file with experiment information
%- running DIC image open for looking at cell growth

