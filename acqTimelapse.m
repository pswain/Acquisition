function []=acqTimelapse(acqData,logfile,exptFolder,posDirectories)
global mmc;
startT=tic%start of timer - toc statement will give time since this tic

%Warn if autofocus device isn't on
if acqData.time(1)==1
    acqData.microscope.Autofocus.timelapseWarning;
end



acqData.logtext=1;
logstring=strcat('Experiment started at: ',datestr(clock));acqData.logtext=writelog(logfile,acqData.logtext,logstring);


isTimelapse=acqData.time(1);
if isTimelapse==1
    numTimepoints=acqData.time(3);%number of timepoints
    interval=acqData.time(2);%time interval in s
else
    numTimepoints=1;
    interval=0;
end

numPositions=size(acqData.points,1);%number of positions to visit - will be zero if no points have been defined
%If only one position is defined then go there before starting the
%timepoint loop - then no need to revisit
 if numPositions==1
     acqData.microscope.visitXY(logfile,acqData.points(1,:),acqData.z(3),acqData.logtext);%sets the xy position of the stage
     startingZ=visitZ(logfile,acqData.z,acqData.logtext,acqData.points(1,:));
     if acqData.z(3)==1;
        acqData.microscope.Autofocus.switchOn;
     end
 end
 
numChannels=size(acqData.channels,1);

if numPositions==0
    %need to define a position here - so that the measured z drift can be
    %corrected for by moving the z drive
    [x y z PFS]=acqData.microscope.definePoint;%call to function that gets position data from scope
    acqData.points(1,1:6)={'pos1',x,y,z,PFS,1};%add data to acquisition data
    numChannels=size(acqData.channels,1);
    for ch=1:numChannels
        acqData.points(1,6+ch)={num2str(acqData.channels{ch,2})};%this has to be a string
    end
    numPositions=1;
end


groups=[acqData.points{:,6}];
%determine the number of groups
numGroups=size(unique(groups),2);
%Initialise array to take the maximum value measured for each channel in each position
%group.
maxgroups=zeros(numGroups,numChannels);
%Initialise Channel settings structure - these are defined seperately for each group
%of positions so that they may be altered independently in response to the
%data
%
%(At present the initial values for each position are identical, except for exposure time - doesn't
%need to be the case (but would need to alter the gui to record this - eg to record different fluorescent proteins in different position groups)
%Would also need to add a dimension (pos) to CHsets.names)
%
%CHsets.values(channel,column (see below),group)
%CHsets.names (channel,group) - cell array of the channel names in use for this position - to be used by captureChannels to determine which channel to set.
%CHsets.original(channel,group) - double array of exposure times - the
%starting exposure times provided by the GUI (needed to calculate correction factors for changed exposures)
%CHsets.skip (channel) - double array. Put into this structure so that it can eventually be defined for each group if desired (but that's not in the gui yet so just defined per channel so far
%
%
%The columns in CHsets.values are as follows:
%column 1: gain for this channel (in this group)
%column 2: exposure time correction factor - initially 1 for all groups and channels (in this group)
%column 3: saturation level for these EM camera settings
%column 4: maximum measured value at the previous timepoint - gives an idea of the rate at which the max value of the signal is changing.
%column 5: Exposure time

satFactor=729531;
satPower=-1.001;

CHsets.values=zeros(numChannels,5,numGroups);
CHsets.original=zeros(numChannels,numGroups);
for gp=1:numGroups%gp is index to the entry in the groups array - not the id number of the group
    for ch=1:numChannels
        CHsets.names(ch,gp)=acqData.channels(ch,1);%record name of channel 
        %To define the exposure time need to find a position in the
        %group that does not have  'double' as it's entry in the
        %exposure column. The following code will go horribly wrong
        %(infinite loop) if all positions in a group have 'double'. This
        %MUST be avoided in the gui.
        groupid=groups(gp);%the id number of the group - not the same as its index in the groups array
        positions=find(groups==groupid);
        pos=positions(1);
        exposure=acqData.points(pos,6+ch);
        if strcmp(char(exposure),'double')==0
             CHsets.values(ch,5,gp)=str2double(acqData.points(pos,6+ch));%exposure time - may change in the time course
             CHsets.original(ch,gp)=str2double(acqData.points(pos,6+ch));%initial exposure time - defined by user - this will not change
        else%this position is to have a double exposure
            double=1;
            nextpos=2;
            while double==1
                pos=positions(nextpos);
                exposure=acqData.points(pos,6+ch);
                if strcmp(char(exposure),'double')==0
                     CHsets.values(ch,5,gp)=str2double(acqData.points(pos,6+ch));%exposure time - may change in the time course
                     CHsets.original(ch,gp)=str2double(acqData.points(pos,6+ch));%initial exposure time - defined by user -this will not change
                     double=0;
                end
            nextpos=nextpos+1;                   
            end
        end      
        %Remaining entries defined only for channels using the EM mode
        if acqData.channels{ch,6}==1 ||acqData.channels{ch,6}==3%this channel will use the EM mode of the camera
           CHsets.values(ch,1,gp)=acqData.channels{ch,7};%initial camera EM gain setting - this may change in the time course
           CHsets.values(ch,2,gp)=1;%initial exposure correction factor
           CHsets.values(ch,3,gp)=satFactor.*((CHsets.values(ch,1,gp)).^satPower);%saturation level for this gain
           %CHsets.values(ch,4,group)=zeros; %max value will not be used until there is meaningful data         
        end
    end
end
%Initialise CHsets.skip
for ch=1:numChannels
    CHsets.skip(ch)=cell2mat(acqData.channels(ch,3));
end

%Ensure the Z sectioning method is not PFSOn if the PFS isn't on
if acqData.z(3)==0
    %Ensure the Z sectioning method is not PFSOn if the PFS isn't on
    acqData.z(6)=1;
    logstring='Sectioning method has been set to PFS off because the PFS is not on and locked';acqData.logtext=writelog(logfile,acqData.logtext,logstring);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for t=1:numTimepoints%start of timepoint loop.
    
%% Log entries for start of the timepoint
    fprintf(logfile,'\r\n');
    acqData.logtext=writelog(logfile,acqData.logtext,'');
    logstring=strcat('------Time point_',num2str(t),'------');acqData.logtext=writelog(logfile,acqData.logtext,logstring);
    startOfTimepoint=toc(startT);
    endOfTimepoint=(startOfTimepoint+interval);
    disp(strcat('Start of timepoint:',num2str(t)));
    %Log memory info
    if ispc
        m=memory;
    else
        m.MemAvailableAllArrays=0;
        m.MemUsedMATLAB=0;
    end
    logString=['Memory available for all arrays: ' num2str(m.MemAvailableAllArrays)];
    acqData.logtext=writelog(logfile,acqData.logtext,logString);
    logString=['Memory used by Matlab: ' num2str(m.MemUsedMATLAB)];
    acqData.logtext=writelog(logfile,acqData.logtext,logString);
%%  Start of the positions loop
   maxgroups=zeros(numGroups,numChannels);
   
   %loop through the positions
   for pos=1:numPositions
%% First check if the user has clicked the Stop button
       drawnow;
       guiinfo=guidata(acqData.guihandle);
       if guiinfo.stop==1
          logstring=strcat('Experiment stopped by user at:',num2str(toc(startT)));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
          break%This leaves the position loop
       end
%% Run pump changing function if necessary and log the pump info if requested
       acqData.flow{5}=acqData.flow{5}.shouldChange(toc(startT)/60,logfile);
       if acqData.flow{5}.logRealInfo
           for pNum=1:length(acqData.flow{4})
              [acqData.flow{4}(pNum),~]=acqData.flow{4}(pNum).refreshPumpDetails(logfile);
           end
       end       
       
%% Determine the position group of the current point
       groupid=cell2mat(acqData.points(pos,6));
       groups=[acqData.points{:,6}];%the list of groups
       gp=find(groups)==groupid;%gp is the (logical) index to the entry for this group in CHsets
%% Write log entries for this position
       logstring=strcat('Position:',num2str(pos),', ',char(acqData.points(pos,1)));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
       logstring=strcat('Position group:',num2str(groupid)); acqData.logtext=writelog(logfile,acqData.logtext,logstring);
       %% Run acquisition code for this position
       thisPosFolder=posDirectories(pos);
       returnData=acqData.microscope.capturePosition(acqData,logfile,thisPosFolder,pos,t,CHsets);
       
       
       
              
%        %Record the maximum value measured for each channel - if it is the highest of
%        %any position in this position group
%        %Loop through the channels - if any of them show values
%        %approaching the saturation level then need to reduce the gain
%        %or exposure
%        
%        for ch=1:numChannels
%            %Calculate the maximum value measured for the position
%            %group at this channel - if data has been captured at this
%            %timepoint for this channel - ie if it hasn't been skipped
%            %and t>= the defined starttp
%            if rem(t-1,CHsets.skip(ch))==0 && t>=acqData.channels{ch,5}
%                 maxgroups(gp,ch)=max(maxgroups(gp,ch),positionData.max(ch));
%                logstring=strcat('Maximum grey level measured for ',char(acqData.channels{ch,1}),'_at position:',char(acqData.points(pos,1)),':',num2str(maxgroups(gp,ch)));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
%                if acqData.channels{ch,6}==1;%ie this channel is using EM mode.
%                    logstring=strcat('(Gain:',num2str(CHsets.values(ch,1,gp)),',E=',num2str(CHsets.values(ch,2,gp)),',Saturation at: ',num2str(CHsets.values(ch,3,gp)),')');acqData.logtext=writelog(logfile,acqData.logtext,logstring);
%                end
%            elseif rem(t-1,CHsets.skip(ch))~=0
%                logstring=['Channel: ' char(acqData.channels{ch,1}) 'skipped at this timepiont.'];acqData.logtext=writelog(logfile,acqData.logtext,logstring);
%            elseif t<acqData.channels{ch,5}
%                logstring=['Channel: ' char(acqData.channels{ch,1}) 'not captured until timepoint ' num2str(acqData.channels{ch,5})];acqData.logtext=writelog(logfile,acqData.logtext,logstring);
%            end
%        end
%        %Assign image from this position to the timepoint image array
%        %for display - This may be useful one day - leave commented
%        timepointData(pos,:,:,:)=positionData.images;
if acqData.z(3)==1
    acqData.microscope.Autofocus.switchOn;
end
   end%Of the positions capture loop
   
   
   
   %Change the pumps if necessary
   acqData.flow{5}=acqData.flow{5}.shouldChange(toc(startT)/60,logfile);
   
   if acqData.z(3)==1
       mmc.setProperty('TIPFSStatus','State','On');
   end
   %For OT experiment
   %LEDon;
   clear positionData;
   %Are any changes to exposure or gain settings required? ie are any channels
   %approaching saturation levels at any position?

   for gp=1:numGroups
       group=groups(gp);%in case the group numbers are not consecutive integers - 1,2,3...
       %Loop through the channels
       for ch=1:numChannels
           logstring=strcat('Position group_',num2str(group),'. Channel:',char(CHsets.names(ch)));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
           logstring=strcat('Maximum intensity measured in position group_',num2str(group), '_is:',num2str(maxgroups(gp,ch)));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
           %decide if a change in gain or exposure is required - only for
           %channels using EM mode
           if acqData.channels{ch,6}==1%this channels is using the Smart EM mode
               if CHsets.values(ch,4,gp)>0%maximum measured value at this position at the previous timepoint. If zero then this is the first timepoint - do nothing.
                   maxdiff=maxgroups(gp,ch)-CHsets.values(ch,4,gp);%the difference in max value between the last two timepoints
                   predictedmax=maxgroups(gp,ch)+maxdiff;%the predicted maximum measured value at the next timepoint (based on a simple linear change)
                   %Do we need to change the settings? Change if the predicted max is 3/4 of the current saturation level
                   if predictedmax>=0.75*CHsets.values(ch,3,gp)%the saturation level at the current EM and exposure settings
                       desiredSaturation=1.5*predictedmax;%The 1.5 is an important parameter to think about: higher value here = safer to avoid saturation. Lower value=potentially more sensitive to dim pixels at the next timepoint (ie higher gain)
                       logstring=strcat('Difference in max value from last timepoint:',num2str(maxdiff));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
                       logstring=strcat('Desired saturation level for next timepoint:',num2str(desiredSaturation));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
                       %How to achieve the desired saturation level at the
                       %next time point? If the gain needed is 100 or greater then alter the gain
                       desiredGainE1=nthroot(desiredSaturation/satFactor,satPower);
                       desiredGainE1=round(desiredGainE1);
                       if desiredGainE1<=300 && desiredGainE1>=100
                           CHsets.values(ch,1,gp)=desiredGainE1;
                           CHsets.values(ch,2,gp)=1;%epg==1
                           logstring=strcat('Gain will be changed to:',num2str(desiredGainE1),'for next time point.');acqData.logtext=writelog(logfile,acqData.logtext,logstring);
                       end
                       %If the desired gain is lower than 100 then set the gain to 100 and alter the exposure time to reduce intensity
                       if desiredGainE1<100
                           CHsets.values(ch,1,gp)=100;
                           %calculate the desired exposure with the gain set at 100
                           gain=100;
                           satlevel=satFactor*(gain^satPower);%saturation level with the gain set to 100 (no corrections)
                           currentexp=CHsets.values(ch,5,gp);%the exposure time used at the current time point
                           %If there was no saturation at the current timepoint
                           %then can calculate the new exposure as a ratio of
                           %the satlevel and the desiredSaturation:
                           if maxgroups(gp,ch)<=CHsets.values(ch,3,gp)-20%ie if there is no saturation - subtract 20 to allow for small differences in the actual and calculated saturation levels
                               newExp=satlevel*currentexp/desiredSaturation;%exposure time that should give data that saturates at desiredSaturation
                               newExp=round(newExp);
                           else%can't calculate the desired exposure time precisely as the max value is saturated -  ie not quantitative - just divide by 5 - will get to the correct level eventualll
                               newExp=round(currentexp/5);
                           end
                           if newExp<1%need a minimum exposure time - eg 1ms - if you get saturation at 1ms then repeat the experiment with the current to the relevant LED turned down
                               newExp=1;
                           end
                           logstring=strcat('Gain will be 100. Exposure time will be set to:',num2str(newExp),'for the next time point.');acqData.logtext=writelog(logfile,acqData.logtext,logstring);
                           CHsets.values(ch,1,gp)=100;%gain
                           CHsets.values(ch,2,gp)=CHsets.original(ch,gp)/newExp;%exposure correction factor
                           CHsets.values(ch,3,gp)=satlevel;
                           CHsets.values(ch,5,gp)=newExp;
                       end
                       
                       if desiredGainE1>300
                           fprintf(logfile,'%s','Gain limited to 300 - use longer exposure time or turn LED up for this sample for more sensitivity');
                           fprintf(logfile,'\r\n');
                           CHsets.values(ch,2,gp)=1;
                           CHsets.values(ch,1,gp)=300;
                       end
                       %After a change in the settings need to update CHsets with values relevant to the next timepoint
                       %gain altered within the if statements above - (CHsets.values(ch,1,gp));
                       %Saturation:
                       satlevel=satFactor*(CHsets.values(ch,1,gp)^satPower);%saturation level  (no corrections)
                       originalexpos=CHsets.original(ch,group);%exposure time at the first time point - defined by the user - used to correct all data subsequently taken with other exposure times
                       CHsets.values(ch,3,gp)=satlevel;
                       %Exposure time - already recorded in the if statements above.
                   else
                       logstring='Maximum intensity predicted for next timepoint is well below saturation. Camera settings not changed.';acqData.logtext=writelog(logfile,acqData.logtext,logstring);
                       
                   end
               else
                   if (CHsets.values(ch,1,gp))>0
                       logstring='First timepoint - change in max measured value not checked';acqData.logtext=writelog(logfile,acqData.logtext,logstring);
                   end
               end%of if statement - if a previous value has been recorded (ie if this is tp1)
           else%the channels is using the normal camera mode
               logstring='Channel does not use Smart EM camera mode. Settings remain unchanged.';acqData.logtext=writelog(logfile,acqData.logtext,logstring);
           end
           %Record the maximum intensity value (measured at the current timepoint)
           CHsets.values(ch,4,gp)=maxgroups(gp,ch);
       end%of loop through channels
   end%of loop through groups
                    

   %Include log file entries here - time point t completed at toc(startT)
   currTime=toc(startT);
   logstring=strcat('Timepoint: ',num2str(t),' completed at:',datestr(clock));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
   logstring=strcat('Time since start of timelapse: ',num2str(currTime));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
   [~]=acqData.microscope.getAutofocusStatus(logfile);%This method will write the status to the logfile
   
   clear timepointData;
   %Timer while statement to wait for the correct time to start the
   %next time point.
   if t<numTimepoints%wait only if experiment needs to continue
       guiinfo=guidata(acqData.guihandle);
       logstring=strcat('Time to next time point:',num2str(endOfTimepoint-currTime));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
       drawnow;
       while (currTime<endOfTimepoint)
           currTime=toc(startT);
           %Change the pumps if necessary
           acqData.flow{5}=acqData.flow{5}.shouldChange(toc(startT)/60, logfile);
           guiinfo=guidata(acqData.guihandle);
           drawnow;
           if guiinfo.stop==1
               logstring=strcat('Experiment stopped by user at:',num2str(currTime));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
               break%while loop
           end
       end
       if guiinfo.stop==1
           break;%Break out of the timepoint loop to end the experiment
       end
       clear guiinfo;
   end



end%of timepoint loop


%If pumps are to be stopped at the end of the experiment then stop them
%here
if guiinfo.stop~=1%Don't stop the pumps if the experiment has been interrupted with the stop button
    if length(acqData.flow)>=6
        if acqData.flow{6}==1
            for n=1:length(acqData.flow{4})
                fprintf(acqData.flow{4}(n).serial,'STP');
                acqData.flow{4}(n).running=0;
                acqData.flow{4}(n).updatePumps;%sends information to the syringe pumps
            end
            logstring=('All pumps switched off as acquisition complete.');acqData.logtext=writelog(logfile,acqData.logtext,logstring);
        end
    end
end


logstring=('Experiment completed');acqData.logtext=writelog(logfile,acqData.logtext,logstring);