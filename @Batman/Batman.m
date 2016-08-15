classdef Batman<Microscope
    properties (Constant)
        BrightnessControls=struct('BrightField',struct('device','','property',''),...
            'DIC',struct('device','','property',''),...
            'pHluorin405',struct('device','DTOL-DAC-1','property','Volts'),...
            'GFP',struct('device','DTOL-DAC-2','property','Volts'),...
            'YFP',struct('device','DTOL-DAC-2','property','Volts'),...
            'pHluorin488',struct('device','DTOL-DAC-2','property','Volts'),...
            'GFPWide',struct('device','DTOL-DAC-2','property','Volts'),...
            'mKo2',struct('device','DTOL-DAC-3','property','Volts'),...
            'mCherry',struct('device','DTOL-DAC-3','property','Volts'),...
            'cy5',struct('device','DTOL-DAC-3','property','Volts'));
    end
    methods
        function obj=Batman
            obj.Name='Batman';
            obj.nameImage=imread('Batman.jpg');
            obj.Config='C:\Micromanager config files\MMConfig_3_3_16_YFP.txt';
            obj.InitialChannel='DIC';
            obj.Autofocus=Autofocus('PFS');
            obj.pumpComs(1).com='COM8';%pump1
            obj.pumpComs(2).com='COM7';%pump2
            obj.pumpComs(1).baud=19200;
            obj.pumpComs(2).baud=19200;
            obj.OmeroInfoPath='D:/AcquisitionDataBatman/Swain Lab/Ivan/omeroinfo_donottouch/';
            obj.OmeroCodePath='C:/Omero';
            obj.DataPath='D:/AcquisitionDataBatman';
            obj.XYStage='XYStage';
            obj.ZStage='TIZDrive';
        end
    end
    
end