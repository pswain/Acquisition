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

    acqData.microscope.visitXY(logfile,acqData.points(pos,:),acqData.z(3),acqData.logtext);%sets the xy position of the stage
    %Determine if any channels do sectioning at this position.
    anyZThisPos=false;
    for n=1:size(acqData.channels,1)
        if str2num(char(acqData.points(pos,7)))>0 && cell2mat(acqData.channels(n,4))==1
            %Channel number n does z sectioning and has a nonzero
            %exposure time at this timepoint
            anyZThisPos=true;
        end
    end
    %% Correct for any focus drift
    %Call correct drift will calculate drift relative to where the lens
    %was when the point was marked and set the focus position to the
    %centre of the stack. Only possible if the PFS is on
    %(acqDat.z(3)==1)
    if acqData.z(3)==1
        %obj=correctDrift(obj,logfile, zref, PFSOffset);
        logstring=strcat('Call to correctDrift after moving to position',num2str(pos));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
        acqData.microscope=acqData.microscope.correctDrift(logfile,acqData.points{pos,4},acqData.points(pos,5));
    else
        %The PFS is not in use - just set the z position (not necessary
        %if any channel does Z sectioning - will be set to the bottom
        %of the stack below
        if ~anyZThisPos
            acqData.microscope.setZ(acqData.points{pos,4});
        end
    end
    %% Set the Z position for stack capture if necessary
    %Z position has been set to the position entry (corrected for
    %drift. For Z stack capture need to move to the bottom of the
    %stack (if any channels at this position do sectioning).    
    if anyZThisPos
        startPos=acqData.points{pos,4}+acqData.microscope.AutoFocus.drift;%Z drive position - centre of stack
        sliceInterval=acqData.z(2);
        nSlices=acqData.z(1);
        firstSlice=startPos-((nSlices-1)/2*sliceInterval);
        %Switch off the PFS unless the z sectioning method is PFSon
        if acqData.z(6)~=2%Method 2 is pfsOn on both Batgirl and Batman
            acqData.microscope.Autofocus.switchOff;
            pause(0.4);%Gives it time to switch off - is pretty slow
        end
        acqData.microscope.setZ(firstSlice);
    end
    
    %% Call captureChannels to capture the data

    [returnData]=captureChannels(acqData,logfile,folder,pos,t,CHsets);




