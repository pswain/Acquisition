%Capture channels function for Robin. Capture is ordered to optimize speed
%given the Z drive on Robin is slow - so all channels captured sequentially
%at each Z position. Before calling, the Z drive should be moved to the
%position defined by the current point.

%Inputs
%acqData - structure with the experiment details
%logfile - id of the log file.
%folder - directory to save images
%pos - number of the point that is being captured - should be 0 if this is
%not a point visiting experiment
%t - timepoint - should be 0 if this is not a timelapse

%CHsets: Array with with the EM camera settings - not used in the Robin
%function
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

function images=captureChannels(obj,acqData,logfile,folder,pos,t,z,CHsets)

global mmc;
%returnData.images=zeros(numChannels,acqData.imagesize(1),acqData.imagesize(2));%(up to) 3d array holding the captured data
%returnData.max=zeros(numChannels,1);
expName=char(acqData.info(1));
groupid=cell2mat(acqData.points(pos,6));%gives the group number
groups=[acqData.points{:,6}];%the list of groups
gp=find(groups==groupid);%gp is the (logical) index to the entry for this position group in CHsets
height=obj.ImageSize(1);
width=obj.ImageSize(2);
numChannels=size(acqData.channels,1);
images=zeros(height,width,numChannels);
images=uint16(images);

for ch=1:numChannels%loop through the channels
    chName=char(CHsets.names(ch,gp));
    %should this channel skip this timepoint or not image because we haven't reached its starttp?
    if rem(t-1,CHsets.skip(ch))==0 && t>=acqData.channels{ch,5} %never skip time point 1. Using t-1  instead of t makes this happen.
        %Does this channel do z sectioning, if not should this section be imaged?
        if acqData.channels{ch,4}==0
            %The channel does not do z sectioning
            %Image the channel if it's the central one (or near it)
            if z==ceil(acqData.z(1)/2)
                imageThis=true;
            else
                imageThis=false;
            end
        else
            imageThis=true;           
        end
        if imageThis
            %create a filename - includes the channel name, z section and the path via folder
            filename=strcat(folder,'\',expName,'_',sprintf('%06d',t),'_',chName);
            sliceFileName=strcat(filename,'_',sprintf('%03d',z),'.png');
            
            %get exposure time
            expos=CHsets.values(ch,5,gp);
            
            %Only capture anything if exposure time is not zero
            if expos~=0
                %set exposure and dye configuration (filters and LEDs)
                mmc.setExposure(expos);
                mmc.setConfig('Channel', chName);
                mmc.waitForConfig('Channel', chName);
                
                logstring=strcat('Channel:',chName,' set at:',datestr(clock));A=writelog(logfile,1,logstring);
                logstring=strcat('Exposure time:',num2str(expos),'ms');A=writelog(logfile,1,logstring);
                
                mmc.snapImage();
                img=mmc.getImage;
                img2=typecast(img,'uint16');
                img2=reshape(img2,[height,width]);
                imwrite(img2,char(sliceFileName));
                images(:,:,ch)=img2;
                if strcmp(acqData.points(pos,ch+6),'double')==1%This position needs a double exposure - to monitor bleaching
                    filename2=strcat(sliceFileName,'_2ndexposure');
                    mmc.snapImage();
                    img=mmc.getImage;
                    img2=typecast(img,'uint16');
                    img2=reshape(img2,[height,width]);
                    imwrite(img2,char(filename2));
                end
                
                
                
            end%end of if statement - exposure time zero or not
            
        end
    else %this time point is to be skipped
        logstring=strcat('Time point:',num2str(t),'_is skipped by channel_',chName);A=writelog(logfile,1,logstring);
    end
    
end%end of loop through the channels

