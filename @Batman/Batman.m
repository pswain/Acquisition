classdef Batman<Microscope
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
            obj.BrightnessControls(1).chName='DIC';
            obj.BrightnessControls(1).device='';%Cannot control the brightness of this channel on Batman
            obj.BrightnessControls(1).property='';
            obj.BrightnessControls(1).chName='Brightfield';
            obj.BrightnessControls(1).device='';%Cannot control the brightness of this channel on Batman
            obj.BrightnessControls(1).property='';
            %Remaining channels need to be defined - need access to Batman
            %config file

        end
    end
    
end