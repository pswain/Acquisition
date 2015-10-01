classdef (Abstract) Microscope<handle
    %Superclass for microscope objects. Defines properties and methods
    %requied by all microscopes and provides shared functions that can be
    %overriden by subclasses for specific scopes.
    properties
        Name
        nameImage%Icon to display in GUI
        Config%String, path of micromanager config file
        InitialChannel%To be set when starting up
        Filters%Structure - will hold information on the filters installed
        Channels%Structure - holds information on the microscope configuration for each channel
        Autofocus%autofocus device object - provides methods to run PFS or alternative autofocus device
        cameraFormat;
        pumpComs;%structure, Com port and baud numbers for the syringe pumps
        OmeroInfoPath%string, full path to stored Omero database information
        OmeroCodePath%string, full path to local copy of the Omero code
        DataPath
        %Microscope devices
        XYStage%string, micromanager config name of the XY stage device
        ZStage;%string, micromanager config name of the Z focus device
        ImageSize;
        pinchComPort %com port for the pinch valve relays
    end
    
    methods (Abstract)
        initializeScope(obj);
    end
    methods
        loadConfig(obj)
        setInitialChannel(obj)
        handles=setGUI(obj, handles)
        lightToCamera(obj)
        LED=getLED(obj)
        [device, voltProp]=getLEDVoltProp(obj,LED)
        setLEDVoltage(obj, voltage)
        figTitle=setCamMode(obj, mode,figTitle,EMgain)
        obj=getFilters(obj)
        [x, y, z, AF]=definePoint(obj)
        status=getAutofocusStatus(obj,logfile)
        returnData=capturePosition(obj,acqData,logfile,folder,pos,t,CHsets)
        

        function gain=getEMGain(obj)
            global mmc;
            switch obj.Name
                case {'Batman','Batgirl'}
                    gain=str2double(mmc.getProperty('Evolve','MultiplierGain'));
                case 'Robin'
                    gain=0;
            end
        end
        
        function setPort(obj, channel,CHsets, logfile)
            %Sets the appropriate camera port (or any other channel-specific camera setting) for the input channel
            global mmc;
            switch obj.Name
                case 'Batman'
                    port=mmc.getProperty('Evolve','Port');
                    if cell2mat(channel(6))==2%if this channel uses the normal (CCD) port
                        if strcmp(port,'Normal')~=1%set port to normal if it's not set already
                            mmc.setProperty('Evolve','Port','Normal');
                            logstring=strcat('Camera port changed to normal:',datestr(clock));A=writelog(logfile,1,logstring);
                        end
                    else%if this channel doesn't use the normal port
                        if strcmp(port,'EM')~=1%if it isn't EM already then set port to EM
                            mmc.setProperty('Evolve','Port','Multiplication Gain');
                            logstring=strcat('Camera port changed to EM:',datestr(clock));A=writelog(logfile,1,logstring);
                        end
                        
                        %EM camera mode only - do camera settings need to be changed?
                        if CHsets.values(ch,1,gp)~=EMgain %check if gain for this channel needs to be changed
                            %change the camera settings here - if altering E don't forget to multiply the data by this number.
                            mmc.setProperty('Evolve','MultiplierGain',num2str(CHsets.values(ch,1,gp)));
                            logstring=strcat('EM gain changed to:',num2str(CHsets.values(ch,1,gp)),datestr(clock));A=writelog(logfile,1,logstring);
                            EMgain=CHsets.values(ch,1,gp);
                            
                        end
                    end
                    
                case 'Batgirl'
                    port=mmc.getProperty('Evolve','Port');
                    if cell2mat(channel(6))==2%if this channel uses the normal (CCD) port
                        if strcmp(port,'Normal')~=1%set port to normal if it's not set already
                            mmc.setProperty('Evolve','Port','Normal');
%                             logstring=strcat('Camera port changed to normal:',datestr(clock));A=writelog(logfile,1,logstring);
                        end
                    else%if this channel doesn't use the normal port
                        if strcmp(port,'EM')~=1%if it isn't EM already then set port to EM
                            mmc.setProperty('Evolve','Port','Multiplication Gain');
%                             logstring=strcat('Camera port changed to EM:',datestr(clock));A=writelog(logfile,1,logstring);
                        end
                    end
            end
        end
        
        function [stack,maxvalue]=captureStack(obj,filename,thisZ,zInfo,offset,EM,E,height,width)
            %Captures and saves a Z stack using the current microscope. Z
            %position is moved using the appropriate device for this
            %microscope. If Batman is in use then there are 3 alternative
            %methods for moving in Z, determined by zInfo(6).
            
            %Before calling this function:
            %1. Imaging configuration (LED, exposure time, filter positions etc) must
            %   be set
            %2. If any channel in the acquisition does z sectioning the z position
            %should be moved to the top of the stack before calling this.
            %If not, the focus should be positioned at the desired focal position.
            
            %Arguments:
            %1. filename - complete path for a directory to save the files into. Note - a
            %slice number is added to this filename when each image is saved
            %2. thisZ - 1 if this is a stack
            %3. acqData.z - with the z sectioning information for this experiment -
            %nSlices and interval
            %4. offset value - to position stack in a non standard place
            %5. EM - 1 if this channel uses the EM mode of the camera (ie image should
            %be flipped)
            %6. E - a scalar to multiply the data by (if in the EM mode) - useful for
            %correcting for any changes in exposure time that have occured to avoid
            %saturation in the data.
            global mmc;
            nSlices=zInfo(1);
            sliceInterval=zInfo(2);
            anyZ=zInfo(4);
            fprintf('no longer uses passed height/width\n');
            height=obj.ImageSize(1);
            width=obj.ImageSize(2);
            stack=zeros(height,width,nSlices);
            %Set the device used for sectioning
            switch obj.Name
                case 'Batman'
                    switch zInfo(6)
                        case 1
                            sectDevice='PIFOC';
                        case 2
                            sectDevice='PIFOC';
                        case 3
                            sectDevice='PFS';
                            sectDevice='TIPFSOffset';
                    end
                case 'Robin'
                    sectDevice='ZStage';
                case 'Batgirl'
                    switch zInfo(6)
                        case 1
                            sectDevice='ZStage';
                            keepPFSON=false;
                        case 2
                            sectDevice='ZStage';
                            keepPFSON=true;
                    end
                    sectDevice='ZStage';
            end
            %Wait until the device is ready before getting position (not
            %convinced this line does anything, hence the pause for Robin
            %next.
            
            if ~strcmp(sectDevice,'TIPFSOffset')
                if ~keepPFSON
                    mmc.waitForDevice(sectDevice);
                end
            end
            %             pause(.2);
            %Pause to make sure that the stage has finished moving before
            %getting the start position
            %if strcmp(obj.Name, 'Robin')
            %   pause(.5);
            %end
            startPos=mmc.getPosition(sectDevice);%starting position of the sectioning device (microns)
            maxvalue=0;
            %Need to multiply distances by 2 if using PIFOC because for some reason PIFOC moves 0.5microns when you tell it
            %to move 1.
            if strcmp(sectDevice,'PIFOC')
                p=2;
            elseif strcmp(sectDevice,'TIPFSOffset')
                p=8;
            else
                p=1;
            end
            if thisZ==1%this is a stack acquisition
                %make sure the PFS or other focus device is off
                if ~keepPFSON
                    locked=obj.Autofocus.isLocked;
                    if locked
                        obj.Autofocus.switchOff;
                    end
                end
                zStep=-floor(nSlices/2)+[0:nSlices-1];
                zStep=zStep*2*sliceInterval;
                [b index]=sort(abs(zStep));

                %Temp fix
                %startPos=startPos+2;
                
                
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
                
            else%single section acquisition
                %If any of the channels in this acquisition do z sectioning then need
                %to use the sectioning device to position focus to the middle of the stack. If not
                %then just capture an image.
                if ~strcmp(obj.Name, 'Robin')
                    if anyZ==1
                        z=nSlices/2;
                        slicePosition=startPos+(p*((z-1)*sliceInterval));
                        mmc.setPosition(sectDevice,slicePosition+offset);
                        pause(0.005);
                    end
                    mmc.snapImage();
                    img=mmc.getImage;
                    img2=typecast(img,'uint16');
                    maxvalue=max(img2);%need to record the maximum measured value
                    img2=E.*img2;
                    img2=reshape(img2,[height,width]);
                    stack(:,:,1)=img2;
                    sliceFileName=strcat(filename,'_',sprintf('%03d'),'.png');
                    if EM==1
                        img2=flipud(img2);
                    end
                    imwrite(img2,char(sliceFileName));
                    %imshow(img2,[]);
                    %drawnow;
%                     if ~strcmp(obj.Name, 'Robin')
%                         mmc.setPosition(sectDevice,startPos);
%                         if strcmp(obj.Name, 'Robin')
%                             pause(.02);
%                         end
%                     end
                end
            end
            
            %Restore z position
            mmc.setPosition(sectDevice,startPos);
            
        end
        
        
        
        function imageSize=getImageSize(obj,bin)
            %Returns a 2-element vector specifying the size of the images
            %for a given camera bin setting. Input is a string, either 1,
            %2x2 or 4x4
            switch obj.Name
                case 'Robin'
                    switch bin
                        case '1'
                            imageSize=[1940 1460];
                        case '2x2'
                            imageSize=[970 730];
                        case '4x4'
                            imageSize=[485 365];
                    end
                case 'Batman'
                    switch bin
                        case '1'
                            imageSize=[512 512];
                        case '2x2'
                            imageSize=[256 256];
                        case '4x4'
                            imageSize=[128 128];
                    end
                case 'Batgirl'
                    switch bin
                        case '1'
                            imageSize=[512 512];
                        case '2x2'
                            imageSize=[256 256];
                        case '4x4'
                            imageSize=[128 128];
                    end
            end
            obj.ImageSize=imageSize;
            
        end
        
        function setBin(obj,bin)
            %Sets the bin on the camera
            %input is a string, the first character of which is the binning
            %number (eg '2x2')
            obj.getImageSize(bin);
            bin=str2mat(bin(1));
            global mmc
            switch obj.Name
                case 'Robin'
                    mmc.setProperty('Myo','Binning',bin);
                case {'Batman','Batgirl'}
                    mmc.setProperty('Evolve','Binning',bin);
            end
            
            
            
        end
        
        
        
        
    end
    
    
end
