function returnData=capturePosition(obj,acqData,logfile,folder,pos,t,CHsets)
%Captures, saves and returns the data for a given position on Robin.
%This overrides the equivalent Microscope (superclass) method. This
%function calls captureStack instead of captureChannels because the Z drive
%on Robin is slow - so Z movement occurs first then all channels are
%captured at each Z position.

global mmc;
%Visit the starting Z position for this point (if different from the
%previous one)
zNow=acqData.points{pos,4};
if pos>1
    zOld=acqData.points{pos-1,4};
else
    zOld=1e9;
end
if zNow~=zOld
    mmc.setPosition(acqData.microscope.ZStage,acqData.points{pos,4});
    pause(.5);%Ensures no image is captured until the Z stage stops moving
end

%Run captureStack. This will capture all channels at each of the Z
%positions.
returnData=obj.captureStack(acqData,CHsets, logfile,folder, pos,t);
