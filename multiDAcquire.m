%Script for multidimensional acquisition in MATLAB
%clear all previous acquisitions and close figure windows

gui.closeAllAcquisitions();
gui.clearMessageWindow();

mmc.stopSequenceAcquisition;
close all;

%Initialisation functions: setting evolve gain and any
%others - setting the initial state of the TTL switch also - set to zero.
%Triggering events for the pump will occur on a falling edge at digital 5 -
%to trigger set to 00010000 (32) then down to zero again
mmc.setShutterDevice('TTL Shutter (DT)');
mmc.setProperty('Evolve', 'Gain', '2');
mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
mmc.setProperty('TTL Switch (DT)','State', '0');
mmc.setProperty('LightPath','Label','Left100');%all light should go to the camera
pause on;
today=date;
root=strcat('C:\AcquisitionData\Swain Lab\Ivan\RAW DATA\',today(8:11),'\',today(4:6),'\', date);
disp('press ctrl+C to abort acquisition');
%logfile=fopen(strcat(root,'\',acqName),'w');%Then can write to logfile
%later using fprintf(logfile,'string goes here');
height=mmc.getImageHeight;
width=mmc.getImageWidth;



%USER INPUT - PLEASE FILL THIS PART IN
%ALSO SEE BELOW FOR USING SEPARATE EXPOSURE TIMES FOR DIFFERENT POINTS.
%(OTHER INFORMATION IS SET IN THE MICROMANAGER GUI:
%- AUTOFOCUS
%- TIMELAPSE SETTINGS (INTERVAL AND NUMBER OF TIME POINTS)
%- Z STACK SETTINGS
%- POSITION LIST

acqName = 'GFP_Yswitch';%fill in a name for the experiment
channels = {'DIC'};%edit to use other channels
exposures = [10];%default exposure times in ms for each channel
useZ=[0];%Put a 1 here to do a z stack for the corresponding channel
useDefaultExposure=[1,0];%Put a zero here to use exposure times from position list
offset=[0,0];%to start at a different position from that in the list - used to take DIC images only in 1 position at the centre of the stack



%Initialisation for the channels
sizeChannels=size(channels);
    numChannels=sizeChannels(1);
 channelGroup = 'Dye set';
    
%Arrays to handle the channels:
%channels: =channel names
%exposures: =default exposure times
%useZ=1 if z stack is used for this channel
%useDefaultExposure=1 if default exposure is to be used at all positions
%for this channel - if 0 then exposure times come from the position list
%offset
  
%Initialisation for Z settings
%usePFS=acq.isAutoFocusEnabled;
usePFS=1;
numSlices = 1;%number of slices default
sliceInterval = 0.5;%default
%Get the real numbers if z sectioning is selected in the gui

if acq.isZSliceSettingEnabled==1
        zEnd=acq.getZTopUm;
        zStart=acq.getSliceZBottomUm;
        sliceInterval=acq.getSliceZStepUm;
        numSlices=round(abs((zEnd-zStart)/sliceInterval));
end




%Initialisation for time settings

%Get time information - note the script doesn't check if timepoints is
%selected in the gui - this script is only for timelapses.

    intervalMs=acq.getFrameIntervalMs;
    interval=intervalMs/1000;
    numTimepoints = acq.getNumFrames;%number of timepoints
       
    
    
%Initialisation for point visiting settings

%Get the position list from the GUI and convert it into a 5 column MATLAB
%matrix - columns:
%1. position number
%2. x(microns)
%3. y(microns)
%4. z(microns,%from PFS offset)
%5. GFP exposures - for use in optimization of exposure times
numPositions=1;%default value for numpositions - will be used if multiposition imaging is not enabled
posList=zeros(1,5);%define the MATLAB postition list matrix
posName = {acqName};%create cell array to hold the position names - default has one position called by the acqName string
if acq.isMultiPositionEnabled==1
listJAVA=gui.getPositionList.serialize;
listMATLAB=char(listJAVA);%convert to a matlab string
listArray=textscan(listMATLAB,'%s');%convert to an array of strings, separated at spaces
listArray=listArray{:};
numPositions=0;

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
    
end
%make sure the position names are valid variable names.
posName = genvarname(posName);
%Create directory names to hold the saved data
%need to check if there are existing directories with the same experiment
%name and add numbers to make each experiment unique

exptNum=0;
exptNumString=sprintf('%02d',exptNum);
exptFolder=strcat(root,'\',acqName,'_',exptNumString);

while exist(exptFolder,'dir')==7
    exptNum=(exptNum+1);
    exptNumString=sprintf('%02d',exptNum);
    exptFolder=strcat(root,'\',acqName,'_',exptNumString);
end
    % create a folder for each position to hold the saved data and a figure
    % for each one to display on the screen
directories={''};
fighandles=[];
for n=1:numPositions
directories(n)=cellstr(strcat(exptFolder,'\',char(posName(n))));
    mkdir (char(directories(n)));
    %figure('Name',char(posName(n)));
    %fighandles(n)=gcf;
end
%tilefigs;%For spreading the figures around the screen



%Optional- define exposure times for one of the channels
posList(1,5)=0;
posList(2,5)=30;
posList(3,5)=100;
posList(4,5)=200;


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
    
    
        

% % // create acquisitions and set options% - this method runs out of memory
% % very quickly - better to do all acquisitions in Matlab
% %To allow multiposition capture need to open one acquisition for each
% %position here - need a loop with differing acquisition names.
% %for a=1:numPositions
%     %gui.openAcquisition(strcat(acqName,posName(a)), directory,numTimepoints, numChannels, numSlices);
%     %Previous line commented out - will try to make new acquisition for
%     %each position at each timepoint - to avoid out of memory error when
%     %doing large acquisisions.
%         for l=1:numChannels
%              gui.setChannelName(strcat(acqName,posName(a)), (l-1), channels(l));
%              % for (int i=0; i<colors.length; i++)
%              %    gui.setChannelColor(acqName, i, colors[i]);
%         end
% end
%         

if usePFS==1
    mmc.setProperty('PFSStatus','State','On');
end



  

%Now script is ready to start the acquisition:

tic%start of timer - toc statement will give time since this tic
startOfTimelapse=toc;

for t=1:numTimepoints%start of timepoint loop.
    startOfTimepoint=toc;
    endOfTimepoint=(startOfTimepoint+interval);
    disp(strcat('Time point  ',num2str(t)));
        %start loop through position list and visit point if multi position
    %imaging is enabled
    for pos=1:numPositions
        if acq.isMultiPositionEnabled==1
        mmc.setXYPosition('XYStage',posList(pos,2),posList(pos,3));
        %figure (fighandles(pos));
        %Plan is to have the user mark the centre position of the stack -
        %so they can focus on that - as in Deltavisions. Then move to top
        %before imaging. So need to calculate the position to move to not
        %just go to the marked Z position.
        %Go up by floor(Number of slices/2) slices - ie that number
        %multipled by the slice spacing.
        %NOTE - if the number of slices is even this means you won't collect an
        %image at the actual marked position but at evenly spaced intervals
        %around it.
        
        ZTopPosition=posList(pos,4)-(sliceInterval*(floor(numSlices/2)));
        mmc.setProperty('PFSOffset', 'Position', num2str(ZTopPosition));
        %currentAcqName=strcat(acqName,posName(pos));
        
        end
    %Start loop through channels
        for ch=1:numChannels
    
    %set the channel and exposure time
        if useDefaultExposure(ch)==1
        mmc.setExposure(exposures(ch));
        else
        mmc.setExposure(posList(pos,5));
        end
            
        mmc.setConfig(channelGroup, channels(ch));
        mmc.waitForConfig(channelGroup, channels(ch));
    
    %Before moving PIFOC in Z must make sure the PFS is off otherwise it 
    %will keep focal position constant.
    %Does this channel do Z sectioning?
            if useZ(ch)==1
               mmc.setProperty('PFSStatus','State','Off');
            %start Z sectioning loop
                expos=mmc.getExposure;
                if expos~=0
           
                for z=1:numSlices%start of z sectioning loop
                %PIFOC movement
                slicePosition=(z-1)*sliceInterval+offset(ch);
                mmc.setPosition('PIFOC Z stage',slicePosition);                            
                mmc.snapImage();
                img=mmc.getImage;
                img2=typecast(img,'uint16'); 
                img2=reshape(img2,[height,width]); 
                %imshow(img2,[]);
                filename=char(strcat('img_',sprintf('%09d',t),'_',channels(ch),'_',sprintf('%03d',z)));
                imwrite(img2,strcat(char(directories(pos)),'\',filename,'.tif'));
                %gui.snapAndAddImage(currentAcqName, (i-1), (j-1), (z-1));
                
                end %end of Z sectioning loop
                end % end of if - to avoid snapping when exp time is zero.
                %Return PIFOC to original position
                mmc.setPosition('PIFOC Z stage',0)
            else
                mmc.setProperty('PFSStatus','State','Off');
                mmc.setPosition('PIFOC Z stage',offset(ch));
                mmc.snapImage();
                img=mmc.getImage;
                img2=typecast(img,'uint16'); 
                img2=reshape(img2,[height,width]); 
                imshow(img2,[]);
                filename=char(strcat('img_',sprintf('%09d',t),'_',channels(ch),'_',sprintf('%03d',0)));
                imwrite(img2,strcat(char(directories(pos)),'\',filename,'.tif'));
                mmc.setPosition('PIFOC Z stage',0)
            end%end of if/else statement - above code snaps images with or without z sectioning.
            
            %return to previous state of system - PFS and TTL state.
            %mmc.setProperty('TTL Switch (DT)','State','oldState');
            if usePFS==1
            mmc.setProperty('PFSStatus','State','On');
            end
        end %end of loop through channels (ch)
    end%end of loop though positions (pos)
    
         
        %Timer while statement to wait for the correct time to start the
        %next time point.
        currTime=toc;
        while (currTime<endOfTimepoint)
        currTime=toc;
        end
        
        %code to switch between the two media at the end of time point 20
       
%         if t==5
% mmc.setProperty('TTL Switch (DT)','State','32');%binary 00010000 - ie switch digital 5 to 1
% mmc.setProperty('TTL Shutter (DT)','OnOff','1');%Open shutter sends the signal
% pause (0.110);%to detect a falling edge the signal has to be in the on state for more than 100ms
% mmc.setProperty('TTL Switch (DT)','State','0');%Back to 0 - generates the falling edge
% mmc.setProperty('TTL Shutter (DT)','OnOff','0');
% disp('switched pumps');
%         end
        
end %end of loop through timepoints (t)

%Close acquisitions to return to Matlab command line.
gui.closeAllAcquisitions();

%to add: Event triggering - using TTL inputs to drive syringe pump programs
%........Image processing - flip the DIC image and shift to allign with
%        fluorescence
%
%- custom txt file with experiment information
%- running DIC image open for looking at cell growth
%-lots of testing.

