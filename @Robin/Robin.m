classdef Robin<Microscope
    
    methods 
        function obj=Robin
            obj.Name='Robin';
            obj.nameImage=imread('Robin.jpg');
            obj.Config='C:\Users\Public\MM config files\LeicaConfig_3colour2.cfg';
            obj.InitialChannel='BrightField';
            obj.Autofocus=Autofocus('none');
            obj.pumpComs(1).com='COM14';%pump1
            obj.pumpComs(2).com='COM15';%pump2
            obj.pumpComs(1).baud=19200;
            obj.pumpComs(2).baud=19200;
            obj.OmeroInfoPath='C:/AcquisitionDataRobin/Swain Lab/Ivan/software in progress/omeroinfo_donottouch/';
            obj.OmeroCodePath='C:/Omero';
            obj.DataPath='C:/AcquisitionDataRobin';
            obj.XYStage='XYStage';
            obj.ZStage='ZStage';
            obj.pinchComPort=16;
        end
    end
end
