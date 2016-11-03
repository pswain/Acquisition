function      returnData=capturePosition(obj,acqData,logfile,folder,pos,t,CHsets)
%Captures, saves and returns the data for a given position. This method
%currently used by the Nikon microscopes Batman and Batgirl while the Robin
%subclass overrides this method. This version sets the channel first and
%captures all Z sections for each channel seperately.


%% Determine the position group of the current point
groupid=cell2mat(acqData.points(pos,6));
groups=[acqData.points{:,6}];%the list of groups
gp=find(groups)==groupid;%gp is the (logical) index to the entry for this group in CHsets
%% Write log entries for this position
logstring=strcat('Position:',num2str(pos),', ',char(acqData.points(pos,1)));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
logstring=strcat('Position group:',num2str(groupid)); acqData.logtext=writelog(logfile,acqData.logtext,logstring);
%%Determine if this is a single position and section experiment.
%Autofocus handling is simpler if there's only one position and no
%z-sectioning -check if this is the case
if numPositions==1 && acqData.z(4)==0;%1 position, no z sectioning
    single=1;
else
    single=0;
end
%% Case in which the PFS is in use and there is movement (in z, xy or both)
if acqData.z(3)==1 && single==0
    %using the PFS and things are moving (either in z or xy) - need to switch it off for capture - therefore need to correct for drift
    acqData.microscope.visitXY(logfile,acqData.points(pos,:),acqData.z(3),acqData.logtext);%sets the xy position of the stage
    if acqData.z(4)~=0% == 1 if any channel does z sectioning.
        %Call correct drift with the z position of the bottom of the
        %stack as the input reference position - will calculate drift
        %relative to where the lens was when the point was
        %marked and set the focus to the bottom of the stack.
        if acqData.z(6)==1%Visiting the bottom of the stack only works if the PFS is off
            logstring=strcat('Call to correctDrift after moving to position',num2str(pos));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
            %Calculate position of the bottom of the stack - call
            %correctDrift with that as the input.
            startPos=acqData.points{pos,4};%Z drive position
            sliceInterval=acqData.z(2);
            nSlices=acqData.z(1);
            firstSlice=startPos-((nSlices-1)/2*sliceInterval);
            acqData.microscope=acqData.microscope.correctDrift(logfile,firstSlice,acqData.points(pos,5));
            %
            %
            %CALL TO VISITZ REPLACED BY THE CALL TO CORRECTDRIFT - Z
            %POSITION WILL BE SET IN THAT FUNCTION
            %startingZ=visitZ(logfile,acqData.z,acqData.points(pos,:)); % This has been (re)added 4_4_14 - needs to be tested
            %
            %
            acqData.microscope.Autofocus.switchOff;
            pause(0.4);%Gives it time to switch off - is pretty slow
        end
        %Does any channel at this position do z sectioning?
        anyZThisPos=false;
        for n=1:size(acqData.channels,1)
            try
                if str2num(char(acqData.points(pos,7)))>0 && cell2mat(acqData.channels(n,4))==1
                    %Channel number n does z sectioning and
                    %has a nonzero exposure time at this
                    %timepoint
                    anyZThisPos=true;
                end
            catch
            end
        end
        
    else
        logstring=strcat('No call to visitZ - no points do z sectioning',num2str(pos));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
    end
else
    %Either the PFS is not in use or there is no movement
    %either in z or xy (ie single==1).
    %This is a single position and section acquisition -
    %no need to call correctDrift or adjust the Z position
    %do not switch PFS off or correct for drift if only 1
    %position and no z sectioning - in this case the PFS
    %can stay on all the time and do all the drift
    %correcting itself.
    logstring=strcat('Single position and Z section or the PFS is off. No call to correctDrift');acqData.logtext=writelog(logfile,acqData.logtext,logstring);
    acqData.microscope.visitXY(logfile,acqData.points(pos,:),acqData.z(3),acqData.logtext);%sets the xy position of the stage
    
    if acqData.z(4)~=0%anyZ = 1 if any channel does z sectioning.
        %At least one channel does z sectioning.
        %Does any channel at this position do z sectioning?
        anyZThisPos=false;
        for n=1:size(acqData.channels,1)
            if str2num(char(acqData.points(pos,7)))>0 && cell2mat(acqData.channels(n,4))==1
                %Channel number n does z sectioning and
                %has a nonzero exposure time at this
                %timepoint
                anyZThisPos=true;
            end
            
        end
        if anyZThisPos
            %Need to move the Z drive to the bottom of the stack. The
            %PFS must be off or the code above (involving the call to
            %correctDrift) would have been run
            startPos=acqData.points{pos,4};%Z drive position
            sliceInterval=acqData.z(2);
            nSlices=acqData.z(1);
            firstSlice=startPos-((nSlices-1)/2*sliceInterval);
            acqData.microscope.setZ(firstSlice);
        else
            %No z sectioning at this position, move the Z drive and PFS if in use to
            %the defined position
            acqData.setZ(acqData.points{pos,4}+acqData.z{5});%Set z drive position + any recorded drift
            if acqData.z{3}==1
                acqData.microscope.setAutofocusOffset(acqData.points{pos,5});
            end
        end
    end
end
if numPositions>1
    posFolder=posDirectories(pos);
else
    posFolder=exptFolder;
end

positionData=acqData.microscope.capturePosition(acqData,logfile,posFolder,pos,t,CHsets);%data for all channels stored for this position in the position variable


















[returnData]=captureChannels(acqData,logfile,folder,pos,t,CHsets);




end