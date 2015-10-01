classdef Batman<Microscope
    
    methods
        function obj=Batman
            obj.Name='Batman';
            obj.nameImage=imread('Batman.jpg');
            obj.Config='C:\Micromanager config files\MMConfig_2_3_15.cfg';
            obj.InitialChannel='DIC';
            obj.Autofocus=Autofocus('PFS');
            obj.pumpComs(1).com='COM8';%pump1
            obj.pumpComs(2).com='COM7';%pump2
            obj.pumpComs(1).baud=19200;
            obj.pumpComs(2).baud=19200;
            obj.OmeroInfoPath='D:/AcquisitionDataBatman/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
            obj.OmeroCodePath='D:/AcquisitionData/Omero code';
            obj.DataPath='D:/AcquisitionDataBatman';
            obj.XYStage='XYStage';
            obj.ZStage='TIZDrive';
        end
    end
    
end