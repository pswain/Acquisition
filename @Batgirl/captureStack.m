function [stack,maxvalue]=captureStack(obj,filename,thisZ,zInfo,offset,EM,E,point)
            %Captures and saves a Z stack using the current microscope. Z
            %position is moved using the appropriate device for this
            %microscope. If Batman is in use then there are 3 alternative
            %methods for moving in Z, determined by zInfo(6).
            
            %Before calling this function:
            %1. Imaging configuration (LED, exposure time, filter positions etc) must
            %   be set
            %2. If any channel in the acquisition does z sectioning the z position
            %should be moved to the bottom of the stack before calling this.
            %If not, the focus should be positioned at the desired focal position.
            
            %Arguments:
            %1. filename - complete path for a directory to save the files into. Note - a
            %slice number is added to this filename when each image is
            %saved. If empty the stack will be returned but no data will be
            %saved
            %2. thisZ - 1 if this is a stack
            %3. acqData.z - with the z sectioning information for this experiment -
            %nSlices and interval
            %4. offset value - INPUT OFFSET IS NOT USED - NOW USED TO
            %CONTROL THE VALUES SENT TO THE PIFOC
            %5. EM - 1 if this channel uses the EM mode of the camera (ie image should
            %be flipped)
            %6. E - a scalar to multiply the data by (if in the EM mode) - useful for
            %correcting for any changes in exposure time that have occured to avoid
            %saturation in the data.
            %7. Point - row of the acqData.points cell array that refers to
            %the current position.
            global mmc;
            nSlices=zInfo(1);
            sliceInterval=zInfo(2);
            anyZ=zInfo(4);
            height=obj.ImageSize(1);
            width=obj.ImageSize(2);
            stack=zeros(height,width,nSlices);
            switch zInfo(6)
                case 1
                    keepPFSON=false;
                case 2
                    keepPFSON=true;
            end
            sectDevice='ZStage';
            %Wait until the device is ready before getting position (not
            %convinced this line does anything, hence the pause for Robin
            %next.
            
            if ~keepPFSON
                mmc.waitForDevice(sectDevice);
            end
            
            startPos=mmc.getPosition(sectDevice);%starting position of the sectioning device (microns)
            maxvalue=0;
            p=1;
            offset=0;
            if thisZ==1%this is a stack acquisition
                %make sure the PFS or other focus device is off
                if ~keepPFSON
                    locked=obj.Autofocus.isLocked;
                    if locked
                        obj.Autofocus.switchOff;
                    end
                end
                %zstep values required for PFSon method
                zStep=-floor(nSlices/2)+[0:nSlices-1];
                zStep=zStep*2*sliceInterval;
                [b, index]=sort(abs(zStep));
                                                
                for z=1:nSlices%start of z sectioning loop
                    %                     %Position of current slice
                    
                    slicePosition=startPos-((nSlices-1)*p*sliceInterval)/2+(p*((z-1)*sliceInterval));
                    if keepPFSON
                        zMov=zStep(index(z));
                        slicePosition=startPos+zMov;
                        pauseDur=.005;
                    else
                        pauseDur=.01;
                    end

                    mmc.setPosition(sectDevice,slicePosition+offset);
%                                         mmc.waitForDevice(sectDevice);
                    %                     if strcmp(obj.Name, 'Robin')
                    %                         pause(.01);
                    %                     end
                    pause(pauseDur);
                    mmc.snapImage();
                    if keepPFSON
                        mmc.setPosition(sectDevice,startPos);
                        if z==1
                            pause(.02);
                        end
                    end
                    img=mmc.getImage;
%                     if keepPFSON
%                         pause(pauseDur*5);
%                     end
                    
                    
                    
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
                    if keepPFSON
                        stack(:,:,index(z))=img2;
                    else
                        stack(:,:,z)=img2;
                    end
                    %Define the file name and save
                    if ~isempty(filename)
                        if keepPFSON
                            sliceFileName=strcat(filename,'_',sprintf('%03d',index(z)),'.png');
                        else
                            sliceFileName=strcat(filename,'_',sprintf('%03d',z),'.png');
                        end                        
                        imwrite(img2,char(sliceFileName));
                    end
                end
                
            else%single section acquisition
                %If any of the channels in this acquisition do z sectioning then need
                %to use the sectioning device to position focus to the middle of the stack. If not
                %then just capture an image.
                if ~strcmp(obj.Name, 'Robin')
                    if anyZ==1
                        slicePosition=startPos+(p*((nSlices-1)/2*sliceInterval));
                        mmc.setPosition(sectDevice,slicePosition);
                        pause(0.005);
                    end
                    mmc.snapImage();
                    img=mmc.getImage;
                    img2=typecast(img,'uint16');
                    maxvalue=max(img2);%need to record the maximum measured value
                    img2=E.*img2;
                    img2=reshape(img2,[height,width]);
                    if EM==1 || EM==3
                        img2=flipud(img2);
                    end
                    stack(:,:,1)=img2;
                    if ~isempty(filename)
                        sliceFileName=strcat(filename,'_',sprintf('%03d'),'.png');                        
                        imwrite(img2,char(sliceFileName));
                    end

                end
            end
            
            %Restore z position
            mmc.setPosition(sectDevice,startPos);
            
        end