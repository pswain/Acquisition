%Captures and saves data for all channels of the acquisition

%Inputs
%acqData - structure with the experiment details
%logfile - id of the log file.
%folder - directory to save images
%pos - number of the point that is being captured - should be 0 if this is
%not a point visiting experiment
%t - timepoint - should be 0 if this is not a timelapse

%CHsets: Array with with the EM camera settings
%array: CHsets.values(channel,column (see below),position group)
%column 1: gain for this channel
%column 2: correction factor for any changes to exposure time
%column 3: saturation level for these EM camera settings
%column 4: maximum value at positions in the group at the previous timepoint
%column 5: exposure time for this position group and this channel

%output
%returnData - a structure with two fields:
%returnData.max - the maximum value of all the initially-capture images for each channel (before any correction for exposure time) - 1d array (1x number of channels)
%returnData.images - 3d array - has an image for display (from middle of the stack if a stack) for each channel

function [returnData]=captureChannels(obj,acqData,logfile,folder,pos,t,CHsets)

global mmc;
numChannels=size(acqData.channels,1);
returnData.images=zeros(numChannels,acqData.imagesize(1),acqData.imagesize(2));%(up to) 3d array holding the captured data
returnData.max=zeros(numChannels,1);
EMgain=acqData.microscope.getEMGain;
expName=char(acqData.info(1));
groupid=cell2mat(acqData.points(pos,6));%gives the group number
groups=[acqData.points{:,6}];%the list of groups
gp=find(groups==groupid);%gp is the (logical) index to the entry for this group in CHsets

if ~strcmp(acqData.microscope.Name,'Robin')
    for ch=1:numChannels%loop through the channels
        chName=char(CHsets.names(ch,gp));
        %should this channel skip this timepoint or not image because we haven't reached its starttp?
        if rem(t-1,CHsets.skip(ch))==0 && t>=acqData.channels{ch,5}%never skip time point 1. Using t-1  instead of t makes this happen.
            
            %create a filename - includes the channel name and the path via folder
            filename=strcat(folder,'\',expName,'_',sprintf('%06d',t),'_',chName);
            
            %set offset
            offset=cell2mat(acqData.channels(ch,5));%WILL USE THIS ONE DAY
            
            %get exposure time
            expos=CHsets.values(ch,5,gp);
            
            %Only capture anything if exposure time is not zero
            if expos~=0
                %set exposure and dye configuration (filters and LEDs)
                mmc.setExposure(expos);
                mmc.setConfig('Channel', chName);
                mmc.waitForConfig('Channel', chName);
                %Set LED voltage based on information in acqData.channels
                acqData.microscope.setLEDVoltage(acqData.channels{ch,8});
                
                %Uncomment for taking dark field/camera noise images
                %mmc.setProperty('EmissionFilterWheel','Label','Closed2');
                %logstring=strcat('Emission filter wheel closed for dark field image');A=writelog(logfile,1,logstring);
                
                
                logstring=strcat('Channel:',chName,' set at:',datestr(clock));A=writelog(logfile,1,logstring);
                logstring=strcat('Exposure time:',num2str(expos),'ms');A=writelog(logfile,1,logstring);
                
                %set the camera read mode - based on the information in CHsets.
                %Don't set if the port is already right - setting the port makes
                %the next LED exposure (not camera exposure) longer.
                
                acqData.microscope.setPort(acqData.channels(ch,:),CHsets,logfile);
                
                
                
                %does this channel do z sectioning?
                zsect=cell2mat(acqData.channels(ch,4));
                EM=cell2mat(acqData.channels(ch,6));
                
                %Need to calculate E - correction factor for any changes in exposure
                %time that may have occured during the timelapse due to the threat of
                %approaching saturation
                if cell2mat(acqData.channels(ch,6))==1%this channels is using the EM mode
                    E=CHsets.values(ch,2,gp);%correction factor for any changes to exposure time
                else
                    E=1;
                end
                
                [resultStack,maxValue]=acqData.microscope.captureStack(filename,zsect,acqData.z,0,EM,E,acqData.imagesize(1),acqData.imagesize(2));
                
                
                if strcmp(acqData.points(pos,ch+6),'double')==1%This position needs a double exposure - to monitor bleaching
                    filename2=strcat(filename,'_2ndexposure');
                    [resultStack maxValue]=acqData.microscope.captureStack(filename2,zsect,acqData.z,0,EM,E,acqData.imagesize(1),acqData.imagesize(2));%z stack capture
                end
                
                %assign data to the positionData array - gets returned to calling program
                if size(resultStack,3)==1
                    returnData.images(ch,:,:)=resultStack;
                else
                    midsection=floor(acqData.z(1)/2);
                    returnData.images(ch,:,:)=resultStack(acqData.imagesize(1),acqData.imagesize(2),midsection);
                end
                returnData.max(ch)=maxValue;%the maximum recorded value for each channel (before applying any corrections based on E)
                
            end%end of if statement - exposure time zero or not
        else %this time point is to be skipped
            logstring=strcat('Time point:',num2str(t),'_is skipped by channel_',chName);A=writelog(logfile,1,logstring);
        end
        
    end%end of loop through the channels
elseif strcmp(acqData.microscope.Name,'Robin')
    chImage=[];chName=[];filename=[];expos=[];
    chInfo=[];
    sectDevice='ZStage';
    mmc.waitForDevice(sectDevice);
    startPos=mmc.getPosition(sectDevice);%starting position of the sectioning device (microns)
    %setup all of the z-position stuffs
    zInfo=acqData.z;
    nSlices=zInfo(1);
    sliceInterval=zInfo(2);
    
    for ch=1:numChannels%loop through the channels
        chInfo{ch}.CHsets=CHsets;
        chInfo{ch}.logfile=logfile;
        chInfo{ch}.chName=char(CHsets.names(ch,gp));
        chInfo{ch}.chImage=rem(t-1,CHsets.skip(ch))==0 && t>=acqData.channels{ch,5};%never skip time point 1. Using t-1  instead of t makes this happen.
        chInfo{ch}.filename=strcat(folder,'\',expName,'_',sprintf('%06d',t),'_',chInfo{ch}.chName);
        
        %get exposure time
        chInfo{ch}.expos=CHsets.values(ch,5,gp);
        %does this channel do z sectioning?
        chInfo{ch}.zsect=cell2mat(acqData.channels(ch,4));
        chInfo{ch}.chSlicesToTakePic = chInfo{ch}.chImage * chInfo{ch}.zsect * (ones(1,nSlices));
        %only take picture of the middle slice if not a stack
        if ~any(chInfo{ch}.chSlicesToTakePic) & chInfo{ch}.chImage & nSlices>1
            chInfo{ch}.chSlicesToTakePic(ceil(nSlices/2))=1;
        end
        chInfo{ch}.EM=cell2mat(acqData.channels(ch,6));
        if cell2mat(acqData.channels(ch,6))==1%this channels is using the EM mode
            chInfo{ch}.E=CHsets.values(ch,2,gp);%correction factor for any changes to exposure time
        else
            chInfo{ch}.E=1;
        end
    end
    
    if (abs(startPos-acqData.points{pos,4})) <= .25 % if the currentposition is within 0.1microns, assume it is in the middle of the slice
        startPos=acqData.points{pos,4}-((nSlices-1)*sliceInterval)/2;
        mmc.setPosition(sectDevice,startPos);
        mmc.waitForDevice(sectDevice);
    end
    if startPos>acqData.points{pos,4} %if the currentposition is above where it should be, go down
        sliceInterval=-sliceInterval;
        zNumInt=nSlices:-1:1;
    elseif startPos<acqData.points{pos,4}
        zNumInt=1:nSlices;
        sliceInterval=sliceInterval;
        anyZ=zInfo(4);
    end
    zInfo=[];
    %zInfo.zNumInt=zNumInt;
    for z=1:nSlices%start of z sectioning loop
        %Position of current slice
        zInfo.slicePosition(z)=startPos+((z-1)*sliceInterval);
    end
    %Only capture anything if exposure time is not zero
    [resultStack,maxValue]=acqData.microscope.captureStack(filename,thisZ, zInfo, 0);
    (obj,filename,thisZ,zInfo,offset,EM,E,height,width)
%Commented this because it doesn't work. - error at line 163 above
   % [resultStack,maxValue]=acqData.microscope.captureStackFastRobin(chInfo,zInfo,acqData);
end

%assign data to the positionData array - gets returned to calling program
if size(resultStack,3)==1
    returnData.images(ch,:,:)=resultStack;
else
    midsection=floor(acqData.z(1)/2);
    returnData.images(ch,:,:)=resultStack(acqData.imagesize(1),acqData.imagesize(2),midsection);
end
returnData.max(ch)=maxValue;%the maximum recorded value for each channel (before applying any corrections based on E)

end of if statement - exposure time zero or not

% for ch=1:numChannels%loop through the channels
%    chName=char(CHsets.names(ch,gp));
%     %should this channel skip this timepoint or not image because we haven't reached its starttp?
%    if rem(t-1,CHsets.skip(ch))==0 && t>=acqData.channels{ch,5}%never skip time point 1. Using t-1  instead of t makes this happen.
%     
%     %create a filename - includes the channel name and the path via folder
%     filename=strcat(folder,'\',expName,'_',sprintf('%06d',t),'_',chName);
% 
%     %set offset
%     offset=cell2mat(acqData.channels(ch,5));%WILL USE THIS ONE DAY
% 
%     %get exposure time
%     expos=CHsets.values(ch,5,gp);
% 
%     %Only capture anything if exposure time is not zero
%     if expos~=0
%         %set exposure and dye configuration (filters and LEDs)
%         mmc.setExposure(expos);
%         mmc.setConfig('Channel', chName);
%         mmc.waitForConfig('Channel', chName);       
%         %Set LED voltage based on information in acqData.channels
%         acqData.microscope.setLEDVoltage(acqData.channels{ch,8});
% 
%         
% 
%         %Uncomment for taking dark field/camera noise images
%         %mmc.setProperty('EmissionFilterWheel','Label','Closed2');
%         %logstring=strcat('Emission filter wheel closed for dark field image');A=writelog(logfile,1,logstring);
% 
%         
%         logstring=strcat('Channel:',chName,' set at:',datestr(clock));A=writelog(logfile,1,logstring);
%         logstring=strcat('Exposure time:',num2str(expos),'ms');A=writelog(logfile,1,logstring);
% 
%         %set the camera read mode - based on the information in CHsets.
%         %Don't set if the port is already right - setting the port makes
%         %the next LED exposure (not camera exposure) longer.
%         
%         acqData.microscope.setPort(acqData.channels(ch,:),CHsets,logfile);
%        
%         
%          %EM camera mode only - do camera settings need to be changed?
%          if cell2mat(acqData.channels(ch,6))~=2
%              if CHsets.values(ch,1,gp)~=EMgain %check if gain for this channel needs to be changed
%                 %change the camera settings here - if altering E don't forget to multiply the data by this number. 
%                 mmc.setProperty('Evolve','MultiplierGain',num2str(CHsets.values(ch,1,gp)));
%                 logstring=strcat('EM gain changed to:',num2str(CHsets.values(ch,1,gp)),datestr(clock));A=writelog(logfile,1,logstring);
%                 EMgain=CHsets.values(ch,1,gp);
% 
%              end
%          end
% 
% 
%         %does this channel do z sectioning?
%         zsect=cell2mat(acqData.channels(ch,4));
%         EM=cell2mat(acqData.channels(ch,6));
% 
%         %Need to calculate E - correction factor for any changes in exposure
%         %time that may have occured during the timelapse due to the threat of
%         %approaching saturation
%         if cell2mat(acqData.channels(ch,6))==1%this channels is using the EM mode
%             E=CHsets.values(ch,2,gp);%correction factor for any changes to exposure time
%         else
%             E=1;
%         end
%         
%         [resultStack,maxValue]=acqData.microscope.captureStack(filename,zsect,acqData.z,0,EM,E,acqData.imagesize(1),acqData.imagesize(2));
%         
% 
%         if strcmp(acqData.points(pos,ch+6),'double')==1%This position needs a double exposure - to monitor bleaching
%             filename2=strcat(filename,'_2ndexposure');
%             [resultStack maxValue]=acqData.microscope.captureStack(filename2,zsect,acqData.z,0,EM,E,acqData.imagesize(1),acqData.imagesize(2));%z stack capture
%         end
% 
%         %assign data to the positionData array - gets returned to calling program
%         if size(resultStack,3)==1
%             returnData.images(ch,:,:)=resultStack;
%         else
%             midsection=floor(acqData.z(1)/2);
%             returnData.images(ch,:,:)=resultStack(acqData.imagesize(1),acqData.imagesize(2),midsection);
%         end
%         returnData.max(ch)=maxValue;%the maximum recorded value for each channel (before applying any corrections based on E)
% 
%         end%end of if statement - exposure time zero or not
%     else %this time point is to be skipped
%         logstring=strcat('Time point:',num2str(t),'_is skipped by channel_',chName);A=writelog(logfile,1,logstring);
%     end 
%     
% end%end of loop through the channels

