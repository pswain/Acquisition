function      returnData=capturePosition(obj,acqData,logfile,folder,pos,t,CHsets)

%Captures, saves and returns the data for a given position. This method
%currently used by the Nikon microscopes Batman and Batgirl while the Robin
%subclass overrides this method. This version sets the channel first and
%captures all Z sections for each channel seperately.

%% Move to the correct XY position
acqData.microscope.visitXY(logfile,acqData.points(pos,:),acqData.z(3),acqData.logtext);%sets the xy position of the stage

%% Determine if any channels do sectioning at this position.
anyZThisPos=false;
for n=1:size(acqData.channels,1)
    if str2num(char(acqData.points(pos,7)))>0 && cell2mat(acqData.channels(n,4))==1
        %Channel number n does z sectioning and has a nonzero
        %exposure time at this timepoint
        anyZThisPos=true;
    end
end
%% Correct for any focus drift
%Call read drift will calculate drift relative to where the lens
%was when the point was marked and set the focus position to the
%centre of the stack. Only possible if the PFS is on
%(acqDat.z(3)==1)
if acqData.z(3)==1
    %Record the drift and make any adjustments to the PFS offset    
    logstring=strcat('Call to readDrift after moving to position',num2str(pos));acqData.logtext=writelog(logfile,acqData.logtext,logstring);
    acqData.microscope=acqData.microscope.readDrift(logfile,acqData.points{pos,4},acqData.points(pos,5));
else
    %The PFS is not in use - just set the z position
    if ~anyZThisPos
        acqData.microscope.setZ(acqData.points{pos,4});
    end
end
    %% Set the Z position for stack capture if necessary
    %Z position has been set to the position entry (corrected for
    %drift. For Z stack capture need to move to the bottom of the
    %stack (if any channels at this position do sectioning).    
%     if anyZThisPos
%         startPos=acqData.points{pos,4}+acqData.microscope.Autofocus.Drift;%Z drive position - centre of stack
%         sliceInterval=acqData.z(2);
%         nSlices=acqData.z(1);
%         firstSlice=startPos-((nSlices-1)/2*sliceInterval);
%         acqData.microscope.setZ(firstSlice);
%     end
    
    %% Call captureChannels to capture the data
    [returnData]=acqData.microscope.captureChannels(acqData,logfile,folder,pos,t,CHsets);



