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
                        %Code below required to get EMsmart method working
                        %- needs debugged
                        %EM camera mode only - do camera settings need to be changed?
%                         if CHsets.values(ch,1,gp)~=EMgain %check if gain for this channel needs to be changed
%                             %change the camera settings here - if altering E don't forget to multiply the data by this number.
%                             mmc.setProperty('Evolve','MultiplierGain',num2str(CHsets.values(ch,1,gp)));
%                             logstring=strcat('EM gain changed to:',num2str(CHsets.values(ch,1,gp)),datestr(clock));A=writelog(logfile,1,logstring);
%                             EMgain=CHsets.values(ch,1,gp);
%                             
%                         end
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
