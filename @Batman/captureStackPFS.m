elseif strcmp('PIFOC','TIPFSOffset')
    p=8;
    offset=0;
else
    p=1;
    offset=0;
end
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

                    mmc.setPosition('PIFOC',slicePosition+offset);
%                                         mmc.waitForDevice('PIFOC');
                    %                     if strcmp(obj.Name, 'Robin')
                    %                         pause(.01);
                    %                     end
                    pause(pauseDur);
                    mmc.snapImage();
                    if keepPFSON
                        mmc.setPosition('PIFOC',startPos);
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
                    if keepPFSON
                        sliceFileName=strcat(filename,'_',sprintf('%03d',index(z)),'.png');
                    else
                        sliceFileName=strcat(filename,'_',sprintf('%03d',z),'.png');
                    end
                    if EM==1 || EM==3
                        img2=flipud(img2);
                    end
                    img2=E.*img2;
                    if keepPFSON
                        stack(:,:,index(z))=img2;
                    else
                        stack(:,:,z)=img2;
                    end
                    imwrite(img2,char(sliceFileName));
%                     pause(.1)
                end
                
            
            
            %Restore z position
            mmc.setPosition('PIFOC',startPos);
            