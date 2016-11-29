function acqData=correctSlope(obj, acqData)
%Visits all points and ensures that they are all set to equivalent focus
%positions, using the PFS. The PFS must be on and locked before calling
%this method.
global mmc;
status=obj.getAutofocusStatus;%Returns true (=locked) or false
if ~status
   mmc.setProperty('TIPFSStatus','State','On');
end

%Start loop through the positions
numPositions=size(acqData.points,1);%number of positions to visit - will be zero if no points have been defined
for pos=1:numPositions
    point=acqData.points(pos,:);
    %Move to the XY position
    %move to XY position defined in point input.
    x=point{2};y=point{3};
    mmc.setXYPosition('XYStage',x,y);
    acqData.microscope.setZ(point{4});
    %Moving the Z drive turns the PFS off automatically - need to turn it
    %on again.
    mmc.setProperty('TIPFSStatus','State','On');
    tic;mmc.waitForDevice('TIPFSStatus');
    toc
    status=obj.getAutofocusStatus;%Returns true (=locked) or false
    currentOffset=mmc.getPosition('TIPFSOffset');
    if currentOffset~=point{5}
        mmc.setPosition('TIPFSOffset',point{pos,5});
        pause(1);
    end
    %Wait for the PFS to adjust the Z drive position
    tic;mmc.waitForDevice('TIZDrive');
    toc
    
    %Z drive is now focused correctly
    acqData.points{pos,4}=obj.getZ;
end