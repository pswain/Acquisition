%Capture channels script using the quant view feature of the camera
%Alters the gain and electrons per grey level settings when camera
%approaches saturation for a given channel.

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

for ch=1:numChannels%loop through the channels
    chName=acqData.channels{ch,1};
    %should this channel skip this timepoint or not image because we haven't reached its starttp?
    if rem(t-1,CHsets.skip(ch))==0 && t>=acqData.channels{ch,5}%never skip time point 1. Using t-1  instead of t makes this happen.
        
        %create a filename - includes the channel name and the path via folder
        filename=strcat(folder,'\',expName,'_',sprintf('%06d',t),'_',chName);
                
        %get exposure time
        expos=str2num(acqData.points{pos,6+ch});%Removed ref to CHsets - needs put back in to get changing exposures in EMsmart mode to work
        
        %Only capture anything if exposure time is not zero
        if expos~=0
            %set exposure and dye configuration (filters and LEDs)
            mmc.setExposure(expos);
            mmc.setConfig('Channel', chName);
            mmc.waitForConfig('Channel', chName);
            
            %Set LED voltage based on information in acqData.channels
            acqData.microscope.setLEDVoltage(acqData.channels{ch,8});
            %set the camera read mode - based on the information in CHsets.
            %Don't set if the port is already right - setting the port makes
            %the next LED exposure (not camera exposure) longer.
            acqData.microscope.setPort(acqData.channels(ch,:),CHsets,logfile);
            %Set the EM gain if using EM mode                     
            if acqData.channels{ch,6}==1 || acqData.channels{6}==3
                acqData.microscope.setEMGain(acqData.channels{7},CHsets,logfile);
            end
                        
            %Uncomment for taking dark field/camera noise images
            %mmc.setProperty('EmissionFilterWheel','Label','Closed2');
            %logstring=strcat('Emission filter wheel closed for dark field image');A=writelog(logfile,1,logstring);
            
            logstring=strcat('Channel:',chName,' set at:',datestr(clock));A=writelog(logfile,1,logstring);
            logstring=strcat('Exposure time:',num2str(expos),'ms');A=writelog(logfile,1,logstring);

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
            pause(0.3);
            [resultStack,maxValue]=acqData.microscope.captureStack(filename,zsect,acqData.z,0,EM,E,acqData.points(pos));
            
            
            if strcmp(acqData.points(pos,ch+6),'double')==1%This position needs a double exposure - to monitor bleaching
                filename2=strcat(filename,'_2ndexposure');
                [resultStack maxValue]=acqData.microscope.captureStack(filename2,zsect,acqData.z,0,EM,E,acqData.points(pos));%z stack capture
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
end

% %assign data to the positionData array - gets returned to calling program
% if size(resultStack,3)==1
%     returnData.images(ch,:,:)=resultStack;
% else
%     midsection=floor(acqData.z(1)/2);
%     returnData.images(ch,:,:)=resultStack(acqData.imagesize(1),acqData.imagesize(2),midsection);
% end
% returnData.max(ch)=maxValue;%the maximum recorded value for each channel (before applying any corrections based on E)
