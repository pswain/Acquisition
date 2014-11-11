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

function [returnData]=captureChannels(acqData,logfile,folder,pos,t,CHsets)
global mmc;
numChannels=size(acqData.channels,1);
returnData.images=zeros(numChannels,512,512);%(up to) 3d array holding the captured data
returnData.max=zeros(numChannels,1);
EMgain=str2double(mmc.getProperty('Evolve','MultiplierGain'));
expName=char(acqData.info(1));
groupid=cell2mat(acqData.points(pos,6));%gives the group number
groups=[acqData.points{:,6}];%the list of groups
gp=find(groups)==groupid;%gp is the (logical) index to the entry for this group in CHsets

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
        LED=mmc.getProperty('DTOL-Switch','State');

        if ~isnumeric(LED)
            LED=str2num(LED);
        end
        switch LED
            case 1
                dac=[];%The bright field LED cannot have its voltage adjusted - not wired to the DAC card
            case 2%The CFP LED - adjust DAC-1
                dac='DTOL-DAC-1';
            case 4%The GFP/YFP LED - adjust DAC-1
                dac='DTOL-DAC-2';
            case 8%The mCherry/cy5/tdTomato LED - adjust DAC-1
                dac='DTOL-DAC-3';
        end
        if ~isempty(dac)
            mmc.setProperty(dac,'Volts', acqData.channels{ch,8});
        end
        
        %Uncomment for taking dark field/camera noise images
        %mmc.setProperty('EmissionFilterWheel','Label','Closed2');
        %logstring=strcat('Emission filter wheel closed for dark field image');A=writelog(logfile,1,logstring);

        
        logstring=strcat('Channel:',chName,' set at:',datestr(clock));A=writelog(logfile,1,logstring);
        logstring=strcat('Exposure time:',num2str(expos),'ms');A=writelog(logfile,1,logstring);

        %set the camera read mode - based on the information in CHsets.
        %Don't set if the port is already right - setting the port makes
        %the next LED exposure (not camera exposure) longer.

        port=mmc.getProperty('Evolve','Port');
        if cell2mat(acqData.channels(ch,6))==2%if this channel uses the normal (CCD) port
            if strcmp(port,'Normal')~=1%set port to normal if it's not set already
                mmc.setProperty('Evolve','Port','Normal');
                logstring=strcat('Camera port changed to normal:',datestr(clock));A=writelog(logfile,1,logstring);
            end
        else%if this channel doesn't use the normal port
            if strcmp(port,'EM')~=1%if it isn't EM already then set port to EM 
                mmc.setProperty('Evolve','Port','Multiplication Gain');
                logstring=strcat('Camera port changed to EM:',datestr(clock));A=writelog(logfile,1,logstring);
            end

            %EM camera mode only - do camera settings need to be changed?
            if CHsets.values(ch,1,gp)~=EMgain %check if gain for this channel needs to be changed
               %change the camera settings here - if altering E don't forget to multiply the data by this number. 
               mmc.setProperty('Evolve','MultiplierGain',num2str(CHsets.values(ch,1,gp)));
               logstring=strcat('EM gain changed to:',num2str(CHsets.values(ch,1,gp)),datestr(clock));A=writelog(logfile,1,logstring);
               EMgain=CHsets.values(ch,1,gp);

            end
        end


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
        %Dummy exposure - to fix first exposure long problem
%         dummy;
        [stack maxvalue]=captureStack(filename,zsect,acqData.z,0,EM,E);%z stack capture

        if strcmp(acqData.points(pos,ch+6),'double')==1%This position needs a double exposure - to monitor bleaching
            filename2=strcat(filename,'_2ndexposure');
            [stack maxvalue]=captureStack(filename2,zsect,acqData.z,0,EM,E);%z stack capture
        end

        %assign data to the positionData array - gets returned to calling program
        if size(stack,3)==1
            returnData.images(ch,:,:)=stack;
        else
            midsection=floor(acqData.z(1)/2);
            returnData.images(ch,:,:)=stack(512,512,midsection);
        end
        returnData.max(ch)=maxvalue;%the maximum recorded value for each channel (before applying any corrections based on E)

        end%end of if statement - exposure time zero or not
    else %this time point is to be skipped
        logstring=strcat('Time point:',num2str(t),'_is skipped by channel_',chName);A=writelog(logfile,1,logstring);
    end 
    
end%end of loop through the channels

