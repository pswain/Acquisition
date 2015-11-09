function returnData=captureStack(obj,acqData,CHsets,logfile, folder, pos,t)
%Captures, saves and returns a Z stack using Robin. All required channels
%are captured (through call to the captureChannels method) after each Z
%movement. This saves time as the Robin Z drive is slow.

global mmc;
nSlices=acqData.z(1);
sliceInterval=acqData.z(2);
anyZ=acqData.z(4);

pauseDur=.1;
returnData.images=zeros(obj.ImageSize(1),obj.ImageSize(2),size(acqData.channels,1),nSlices);
returnData.images=uint16(returnData.images);
returnData.max=zeros(size(acqData.channels,1),1);

%Set the device used for sectioning
sectDevice='ZStage';  
startPos=mmc.getPosition(sectDevice);%starting position of the sectioning device (microns)
if anyZ%this is a stack acquisition
    %Define vector of relative positions to visit (relative to the z
    %position defined in pos)
    zStep=-(nSlices-1)/2+[0:nSlices-1];
    zStep=zStep*sliceInterval;%Check the need to multiply by 2 - not sure why it's there for Robin
    %[b index]=sort(abs(zStep));%Only used by pfsOn method - wierd order of visiting the sections
else
    zStep=0;
    nSlices=1;
end
        
for z=1:nSlices%start of z sectioning loop
    %Position of current slice        
    %slicePosition=startPos-((nSlices-1)*p*sliceInterval)/2+(p*((z-1)*sliceInterval));
    slicePosition=startPos+zStep(z);
    mmc.setPosition(sectDevice,slicePosition);
    pause(pauseDur);%Test if this duration is correct
    %Capture all channels at this Z position
    images=obj.captureChannels(acqData,logfile,folder,pos,t,z,CHsets);
    returnData.images(:,:,:,z)=images;
    %Calculate Max values
    for ch=1:size(acqData.channels,1)
        returnData.max(ch)=max(returnData.max(ch),max(max(images(:,:,ch))));
    end
end
end

