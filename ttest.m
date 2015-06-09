gui.closeAllAcquisitions();
directory='C:\AcquisitionData\Swain Lab\Ivan\28_9_10\test2';%later will get this from the gui
acqName = 'test';%later will get this from the gui
numSlices = 10;
sliceInterval=1;
numTimepoints=5;
interval=5;

gui.openAcquisition(acqName, directory, numTimepoints, 1, numSlices);
tic;
for t=1:numTimepoints
    startOfTimepoint=toc;
    endOfTimepoint=(startOfTimepoint+interval);
mmc.setExposure(10);
mmc.setConfig('Channel','FITC');
mmc.waitForConfig('Channel','FITC');
for z=1:numSlices
        %PIFOC movement - PIFOC should be set as the default z stage
        slicePosition=(z-1)*sliceInterval;
        mmc.setPosition('Z',slicePosition);
        gui.snapAndAddImage(acqName, (t-1), 0, (z-1));
end
        %Return to original position
        mmc.setPosition('Z',0)
       
        currTime=toc;
        while (currTime<endOfTimepoint)
            currTime=toc;
        end;
        
end
gui.closeAcquisition(acqName);