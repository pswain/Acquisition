classdef Batgirl<Microscope
    methods
        function obj=Batgirl
            obj.Name='Batgirl';
            obj.nameImage=imread('Batgirl.jpg');
            obj.Config='C:\Micromanager config files\Batgirl11_9_15pHluorin.cfg';
            obj.InitialChannel='DIC';
            obj.Autofocus=Autofocus('PFS');
            obj.pumpComs(1).com='COM5';%pump1
            obj.pumpComs(2).com='COM6';%pump2
            obj.pumpComs(1).baud=19200;
            obj.pumpComs(2).baud=19200;
            %                 obj.OmeroInfoPath='D:/AcquisitionDataBatgirl/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
            obj.OmeroInfoPath='C:/AcquisitionDataBatgirl/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
            
            obj.OmeroCodePath='C:/AcquisitionDataBatgirl/Omero code';
            obj.DataPath='D:/AcquisitionDataBatgirl';
            obj.XYStage='XYStage';
            obj.ZStage='TIZDrive';
            obj.pinchComPort=9;
        end
    end
end