%modified capture channels script to use quant view feature of the camera
%and alter the gain and electrons per grey level setting when camera
%approaches saturation.

%Inputs
%acqData - structure with the experiment details
%logfile - id of the log file.
%folder - directory to save images
%pos - number of the point that is being captured - should be 0 if this is
%not a point visiting experiment
%t - timepoint - should be 0 if this is not a timelapse
%max - 1D array with one value per channel - maximum grey level measured at
%the previous time point.

%output
%channelData - structure to carry the data. Returned to the calling
%function

function [channelData]=captureChannels_quant(acqData,logfile,folder,pos,t,max)
global mmc;

sizeChannels=size(acqData.channels);
numChannels=sizeChannels(1);
channelData=zeros(numChannels,acqData.z(1),512,512);
% 
% if acqData.channels(ch,4)==1%If z sectioning is being done for this channel
% ZTopPosition=cell2mat(point(5))-(sliceInterval*(floor(numSlices/2)));
% end
    
    
for ch=1:numChannels%loop through the channels
      
    %create a filename - includes the channel name and the path via folder
    chName=char(acqData.channels(ch,1));
    filename=strcat(folder,'\','img_',sprintf('%09d',t),'_',chName);
    %set offset
    offset=cell2mat(acqData.channels(ch,5));
    %set exposure time
    pointExp=cell2mat(acqData.channels(ch,3));
    if pointExp==1%expose by point
        if pos>0%is it a point visiting experiment?
        expos=cell2mat(acqData.points(pos,6));%Define exposure by the data in the point list
        else
        expos=cell2mat(acqData.channels(ch,2));%if it's not a point visiting expt use the default exposure  
        end   
    else%if expose by point is not selected use the default exposure
        expos=cell2mat(acqData.channels(ch,2));
    end
%Only capture anything if exposure time is not zero
if expos~=0
%set exposure and dye configuration (filters and LEDs)
mmc.setExposure(expos);
mmc.setConfig('Dye set', char(acqData.channels(ch,1)));
mmc.waitForConfig('Dye set', char(acqData.channels(ch,1)));
fprintf(logfile,'%s',strcat('Channel:',char(acqData.channels(ch,1)),' set at:',datestr(clock)));
fprintf(logfile,'\r\n');
%set the camera read mode - use EM mode for fluorescence and normal mode
%for DIC. Don't set if the port is already right - setting the port makes
%the next LED exposure (not camera exposure) longer.
port=mmc.getProperty('Evolve','Port');
if strcmp(acqData.channels(ch,1),'DIC')==1%if this channel is DIC
    if strcmp(port,'Normal')~=1%then set port to normal if it's not set already
    mmc.setProperty('Evolve','Port','Normal');
    fprintf(logfile,'%s',strcat('Camera port changed to normal for DIC:',datestr(clock)));
    fprintf(logfile,'\r\n');
    end
else%if this channel isn't DIC - ie it's a fluorescence channel
    if strcmp(port,'EM')~=1%then set port to EM - if it isn't EM already
        mmc.setProperty('Evolve','Port','EM');
        fprintf(logfile,'%s',strcat('Camera port changed to EM for fluorescence:',datestr(clock)));
        fprintf(logfile,'\r\n');
    end
end
%%HERE CAN GET THE MAX VALUES FROM EACH CHANNEL AT PREVIOUS TIMEPOINT (IF
%%T~=1 OR 0) AND DECIDE WHETHER TO CHANGE THE CAMERA GAIN OR E

%does the channel do z sectioning?
zsect=cell2mat(acqData.channels(ch,4));
if zsect==1%capture a z stack using information in acqData.z provided we 
    %are doing point visiting - z position will be correct because
    %visitpoint has been called
    if pos==0
        %If pos = 0 then this is not a point visiting experiment. If capturing a
%stack need to set the correct starting point as there has not been a call
%to visitpoint. Should be in the middle of the stack.
        sliceInterval=acqData.z(2);
        numSlices=acqData.z(1);
        pfsOn=strcmp(mmc.getProperty('PFSStatus','Status'),'Locked');
        currentPFS=mmc.getPosition('PFSOffset');
        fprintf(logfile,'%s',strcat('Current PFS position is:',num2str(currentPFS),':',datestr(clock)));
        fprintf(logfile,'\r\n');
        currentZDrive=mmc.getPosition('ZDrive');
        fprintf(logfile,'%s',strcat('Current Zdrive position is:',num2str(currentZDrive),':',datestr(clock)));
        fprintf(logfile,'\r\n');
        if pfsOn==1;%use PFS offset to move z if it's on and locked
            ZTopPosition= currentPFS-(sliceInterval*(floor(numSlices/2)));
             mmc.setPosition('PFSOffset',ZTopPosition);%move to stack starting position
             fprintf(logfile,'%s',strcat('Moved to Z top position (PFS):',num2str(ZTopPosition)));
             fprintf(logfile,'\r\n');
        else%otherwise use the z drive
            ZTopPosition=currentZDrive-(sliceInterval*(floor(numSlices/2)));
            mmc.setProperty('PFSStatus','Status','Off');
            mmc.setPosition('ZDrive',ZTopPosition);
            fprintf(logfile,'%s',strcat('Moved to Z top position (PFS):',num2str(ZTopPosition)));
            fprintf(logfile,'\r\n');
        end%end of is PFS on if statement
    end%end of code setting correct position if not a point visiting experiment
    mmc.setProperty('PFSStatus','State','Off');%this should eventually be subject to an if statement - if the PFS is on and locked at the start of the experiment
    stack=captureStack(filename,acqData.z(1),acqData.z(2),offset);%z stack capture
    %After stack capture need to return the Z positioning device to the
    %original position.
   mmc.setProperty('PFSStatus','State','On');%this should eventually be subject to an if statement - if the PFS is on and locked at the start of the experiment
   mmc.setPosition('PFSOffset',currentPFS);
   mmc.setPosition('ZDrive',currentZDrive);
    
    
else%capture a single image
    %before capturing single images need to make sure z position is correct. Should be
    %the original position if point visiting. Call to visit point will have
    %put it at the top of the stack if any of the points do a stack.
    if pos>0
        pfsOn=strcmp(mmc.getProperty('PFSStatus','Status'),'Locked');
        if pfsOn==1;%use PFS offset to move z if it's on and locked
            pfsOffset=cell2mat(acqData.points(pos,5));
            mmc.setProperty('PFSOffset','Position',num2str(pfsOffset));
        else%otherwise use the z drive
            zDrivePosition=cell2mat(acqData.points(pos,4));
            mmc.setProperty('PFSStatus','Status','Off');
            mmc.setPosition('ZDrive',zDrivePosition);
        end%end of is PFS on if statement
    end%end of code executed if this is a point visiting experiment
    
stack=captureStack(filename,1,0,offset);


end%end of if statement - z sectioning or not
end%end of if statement - exposure time zero or not
%assign data to the channelData array - gets returned to calling program
channelData(ch,:,:,:)=stack;
end%end of loop through the channels

