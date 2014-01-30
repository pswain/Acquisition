%Script for multidimensional acquisition in MATLAB
%based originally on the beanshell script "TestAcq.bsh" by Nenad Amodaj

%clear all previous acquisitions
gui.closeAllAcquisitions();
gui.clearMessageWindow();


%Initialisation functions should go here - eg setting evolve gain and any
%others - setting the initial state of the TTL also - set to zero.
%Triggering events for the pump will occur on a falling edge at digital 5 -
%to trigger set to 00010000 (32) then down to zero again
mmc.setShutterDevice('TTL Shutter (DT)');
mmc.setProperty('Evolve', 'Gain', '2');
mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
mmc.setProperty('TTL Switch (DT)','State', '0');
mmc.setProperty('LightPath','Label','Left100');
today=date;
directory=[strcat('C:\AcquisitionData\Swain Lab\Ivan\RAWDATA\',today(8:11),'\',today(4:6),'\', date)];
disp('press ctrl+C to abort acquisition');

%USER INPUT - PLEASE FILL THIS IN
%(OTHER INFORMATION IS SET IN THE MICROMANAGER GUI:
%AUTOFOCUS
%TIMELAPSE SETTINGS (INTERVAL AND NUMBER OF TIME POINTS)
%Z STACK SETTINGS
%POSITION LIST)

acqName = 'GFPexptest';%fill in a name for the experiment
channels = {'DIC'; 'GFP'};%edit to use other channels
exposures = [10, 100];%default exposure times in ms for each channel
useZ=[0, 1];%Put a 1 here to do a z stack for the corresponding channel
useDefaultExposure=[1,0];%Put a zero here to use exposure times from position list
offset=[0,0];%to start at a different position from that in the list - used to take DIC images only in 1 position at the centre of the stack


sizeChannels=size(channels);
    numChannels=sizeChannels(1);

  
    
%Arrays to handle the channels:

%channels=channel names
%exposures=default exposure times
%useZ=1 if z stack is used for this channel
%useDefaultExposure=1 if default exposure is to be used at all positions
%for this channel - if 0 then exposure times come from the position list
%offset
%TTL= number to add to the TTL switch state to trigger the relevant LED
   
    
       
    TTL=zeros(sizeChannels);
    for i=1:sizeChannels
       if strncmp(channels(i), 'DIC',3)
           TTL(i)=1;
       end
         if strncmp(channels(i), 'CFP',3)
           TTL(i)=2;
         end
        if strncmp(channels(i), 'GFP',3)
           TTL(i)=4;
        end
        if strncmp(channels(i), 'YFP',3)
           TTL(i)=4;
        end
        if strncmp(channels(i), 'mCh',3)
           TTL(i)=8;
        end
        if strncmp(channels(i), 'tdT',3)
        TTL(i)=8;
        end
    end
    
    
% Color[] colors = {Color.BLUE, Color.GREEN, Color.RED};
%looks like color objects are a java thing - will need to get these from
%the gui to set.
    
    numSlices = 1;%number of slices default
    sliceInterval = 0.5;%default
    %Get the real numbers if z sectioning is selected in the gui
    if acq.isZSliceSettingEnabled==1
        zEnd=acq.getZTopUm;
        zStart=acq.getSliceZBottomUm;
        sliceInterval=acq.getSliceZStepUm;
        numSlices=round(abs((zEnd-zStart)/sliceInterval));
    end
 
    %Get time information - note the script doesn't check if timepoints is
    %selected in the gui - this script is only for timelapses.
    intervalMs=acq.getFrameIntervalMs;
    interval=intervalMs/1000;
    numTimepoints = acq.getNumFrames;%number of timepoints
       
    
    channelGroup = 'Dye set';
    usePFS=acq.isAutoFocusEnabled;
    
    

%Get the position list from the GUI and convert it into a 5 column MATLAB
%matrix - columns:
%1. position number
%2. x(microns)
%3. y(microns)
%4. z(microns,%from PFS offset)
%5. GFP exposures - for use in optimization of exposure times
numPositions=1;%default value for numpositions - will be used if multiposition imaging is not enabled
if acq.isMultiPositionEnabled==1
listJAVA=gui.getPositionList.serialize;
listMATLAB=char(listJAVA);%convert to a matlab string
listArray=textscan(listMATLAB,'%s');%convert to an array of strings, separated at spaces
listArray=listArray{:};
numPositions=0;
posList=zeros(1,5);%define the MATLAB postition list matrix
posName = {acqName};%create cell array to hold the position names - default has one position called by the acqName string
    for i=1:size(listArray,1)
        if strncmp(listArray(i),'"DEVICES":',10)==1%find a string that occurs soon after start of each position definition
            numPositions=(numPositions+1);%Having found "DEVICES" increase the number of positions by 1.
            posList((numPositions),:)=zeros;%Add a row to the position list matrix
        end
    
        if strncmp(listArray(i), '"PFSOffset",',12)==1%find references to the PFS offset and use the data following to define the Z position
            zStart=str2double(listArray(i+6));%Get the string that is 6 positions beyond '"PFSOffset",' and convert to a number
            posList(numPositions,4)=zStart;%Define z position for current position
        end
        
        if strncmp(listArray(i), '"XYStage",',10)==1%find references to the XY stage and use the data following to define the X and Y positions
            ypos=str2double(listArray(i+4));%The Y position is 4 beyond '"XYStage",' in the string array
            xpos=str2double(listArray(i+6));%The X position is 6 beyond '"XYStage",' in the string array
            posList(numPositions,2)=xpos;
            posList(numPositions,3)=ypos;
            
        end
        
        %Get the position names (pos0, pos1 etc by default but they can be
        %altered by the gui user
        if strncmp(listArray(i), '"LABEL":',8)==1;
            thisName=char(listArray(i+1));
            lengthOfThisName=size(thisName,2);
            thisName=thisName(:,2:(lengthOfThisName-2));%this removes the comma and quotes from the string
            posName(numPositions)=cellstr(thisName);%allocates the position name to the cell array posName
        end
        %Exposure times to be input by user if desired
        posList(:,5)=ones;%replace 1s with array of exposure times in ms if desired here
    end
    %make sure the position names are valid variable names.
    posName = genvarname(posName);
end
%Optional- define exposure times for one of the channels
posList(1,5)=10;
posList(2,5)=50;
posList(3,5)=100;
posList(4,5)=500;


  %Display experimental data
    disp(acqName);
    for n=1:numChannels
        if useDefaultExposure(n)==1
            disp(strcat('Channel',num2str(n),': ',channels(n),'  Exposure:', num2str(exposures(n)),'ms' ));
        else
            disp(strcat('Channel',num2str(n),': ',channels(n),'  Exposure by point'));
        end
        
    end

    if numSlices~=1
        disp('Z sectioning');
        disp(strcat('Number of slices: ',num2str(numSlices)));
        disp (strcat('Slice spacing: ', num2str(sliceInterval)));
    end
    
    if numTimepoints~=1
    disp (strcat('Number of time points: ',num2str(numTimepoints)));
    disp (strcat('Interval between time points: ',num2str(interval), 's'));
    end
    disp (strcat('Number of points to visit: ',num2str(numPositions)));
    
    
        

% // create acquisitions and set options%
%To allow multiposition capture need to open one acquisition for each
%position here - need a loop with differing acquisition names.
for a=1:numPositions
    gui.openAcquisition(strcat(acqName,posName(a)), directory, numTimepoints, numChannels, numSlices);
        for l=1:numChannels
             gui.setChannelName(strcat(acqName,posName(a)), (l-1), channels(l));
             % for (int i=0; i<colors.length; i++)
             %    gui.setChannelColor(acqName, i, colors[i]);
        end
end
        
if usePFS==1
    mmc.setProperty('PFSStatus','State','On');
end



  

%Now script is ready to start the acquisition:

tic%start of timer - toc statement will give time since this tic
startOfTimelapse=toc;
for i=1:numTimepoints%start of timepoint loop.
    startOfTimepoint=toc;
    endOfTimepoint=(startOfTimepoint+interval);
    
    %start loop through position list and visit point if multi position
    %imaging is enabled
    for k=1:numPositions
        if acq.isMultiPositionEnabled==1
        mmc.setXYPosition('XYStage',posList(k,2),posList(k,3));
        mmc.setProperty('PFSOffset', 'Position', num2str(posList(k,4)));
        currentAcqName=strcat(acqName,posName(k));
        end
    %Start loop through channels
        for j=1:numChannels
    
    %set the channel - need to write a new config file with the choice of 
    %LED excluded from the config groups for each dye - then can choose the
    %LED by adding or subtracting numbers from the TTL Switch (DT) state
    %instead of setting the state - this will avoid triggering syringe
    %pump events that use other TTL outputs.
        if useDefaultExposure(j)==1
        mmc.setExposure(exposures(j));
        else
        mmc.setExposure(posList(k,5));
        end
            
        oldState=mmc.getProperty('TTL Switch (DT)','State');
        newState=(str2double(oldState)+TTL(j));
        mmc.setProperty('TTL Switch (DT)','State', num2str(newState));
        mmc.setConfig(channelGroup, channels(j));
        mmc.waitForConfig(channelGroup, channels(j));
    
    %Before moving PIFOC in Z must make sure the PFS is off otherwise it 
    %will keep focal position constant.
    %Does this channel do Z sectioning?
            if useZ(j)==1
               mmc.setProperty('PFSStatus','State','Off');
            %start Z sectioning loop
            %This loop can be altered if we want to focus on the centre of the 
            %sample before starting, as in Deltavisions - now it just goes down
            %from the starting position
                for z=1:numSlices
                %PIFOC movement
                slicePosition=(z-1)*sliceInterval+offset(j);
                mmc.setPosition('PIFOC Z stage',slicePosition);
                gui.snapAndAddImage(currentAcqName, (i-1), (j-1), (z-1));
                end %end of Z sectioning loop
                %Return PIFOC to original position
                mmc.setPosition('PIFOC Z stage',0)
            else
                mmc.setProperty('PFSStatus','State','Off');
                mmc.setPosition('PIFOC Z stage',offset(j));
                gui.snapAndAddImage(currentAcqName, (i-1), (j-1), 0);
                mmc.setPosition('PIFOC Z stage',0)
            end%end of if/else statement - above code snaps images with or without z sectioning.
            
            %return to previous state of system - PFS and TTL state.
            mmc.setProperty('TTL Switch (DT)','State','oldState');
            if usePFS==1
            mmc.setProperty('PFSStatus','State','On');
            end
        end %end of loop through channels (j)
    end%end of loop though positions (k)
    %    // set channel contrast based on the first frame
        %if (i==1) 
        %gui.setContrastBasedOnFrame(currentAcqName, (i-1), 0);
        %end
        
        %Timer while statement to wait for the correct time to start the
        %next time point.
        currTime=toc;
        while (currTime<endOfTimepoint)
        currTime=toc;
        end
%The above loop doesn't seem to work - not sure why

%gui.sleep (intervalMs);




end %end of loop through timepoints

%Close acquisitions to return to Matlab command line.
gui.closeAllAcquisitions();

%to add: z stacks - make sure Z sectioning is enabled
%........point visiting loop k - using XY stage and PFS offset to define positions
%........Event triggering - using TTL inputs to drive syringe pump programs
%........Image processing - flip the DIC image and shift to allign with
%        fluorescence
%
%- custom txt file with experiment information
%- running DIC image open for looking at cell growth
%-lots of testing.

