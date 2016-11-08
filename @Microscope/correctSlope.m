function acqData=correctSlope(obj, acqData,logfile)
%Visits all points and ensures that they are all set to equivalent focus
%positions, using the PFS. The PFS must be on and locked before calling
%this method.

%Start loop through the positions
numPositions=size(acqData.points,1);%number of positions to visit - will be zero if no points have been defined
for pos=1:numPositions
    point=acqData.points(pos,:);
    %Move to the XY position
    %move to XY position defined in point input.
    mmc.setXYPosition('XYStage',x,y);
    %Set the offset if necessary
    currentOffset=mmc.getPosition('PFSOffset','Offset');
    if currentOffset~=point{pos,5}
        mmc.setPosition('PFSOffset',point{pos,5});
        pause(1);
    end
    %Wait for the PFS to adjust the Z drive position
    status=obj.getAutofocusStatus;%Returns true (=locked) or false
    while ~status
        status=obj.getAutofocusStatus;%Returns true (=locked) or false
        pause (0.2);
    end
    %Z drive is now focused correctly
    acqData.points{pos,4}=obj.getZ;
end