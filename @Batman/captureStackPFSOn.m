function [stack,maxvalue]=captureStackPFSOn(obj,filename,zInfo,EM,E)
%Captures and saves a z stack on Batman using the PIFOC sectioning device
%with the PFS switched on. The PFS will attempt to compensate for the
%movements of the PIFOC by moving the microscope Z drive so the images are
%captured in an unusual order in an attempt to outrun the PFS.

%The focus position should be positioned at the centre of the stack (ie the
%recorded z position for the current position (+ any drift) before this
%function is called
global mmc;
nSlices=zInfo(1);
sliceInterval=zInfo(2);
anyZ=zInfo(4);
height=obj.ImageSize(1);
width=obj.ImageSize(2);
stack=zeros(height,width,nSlices);

startPos=mmc.getPosition('PIFOC');%starting position of the sectioning device
maxvalue=0;
%Need to multiply distances by 2 if using PIFOC because for some reason PIFOC moves 0.5microns when you tell it
%to move 1.

%Also PIFOC can't accept negative numbers - so define an
%offset to compensate for that
%Calculate the first slice position (lowest focus position
%in the stack)
z=1;
firstSlice=startPos-((nSlices-1)*2*sliceInterval)/2+(2*((z-1)*sliceInterval));
offset=abs(firstSlice);


for z=1:nSlices%start of z sectioning loop
        
    %zstep values required for PFSon method
    zStep=-floor(nSlices/2)+[0:nSlices-1];
    zStep=zStep*2*sliceInterval;
    [b, index]=sort(abs(zStep));
    
    
    zMov=zStep(index(z));
    slicePosition=startPos+zMov;
    pauseDur=.005;
    
            
            mmc.setPosition('PIFOC',slicePosition+offset);
            %                                         mmc.waitForDevice('PIFOC');
            %                     if strcmp(obj.Name, 'Robin')
            %                         pause(.01);
            %                     end
            pause(pauseDur);
            mmc.snapImage();
                mmc.setPosition('PIFOC',startPos);
                if z==1
                    pause(.02);
                end
            img=mmc.getImage;
            img2=typecast(img,'uint16');
            %need to record the maximum measured value to return
            %This is done before any correction for changes in exposure time
            maxthisz=max(img2);
            maxvalue=max([maxthisz maxvalue]);
            img2=reshape(img2,[height,width]);
            if EM==1 || EM==3
                img2=flipud(img2);
            end
            img2=E.*img2;
            stack(:,:,index(z))=img2;
            if ~isempty(filename)
                sliceFileName=strcat(filename,'_',sprintf('%03d',index(z)),'.png');
                imwrite(img2,char(sliceFileName));
            end
    end

%Restore z position
mmc.setPosition('PIFOC',startPos);
