classdef Joker<Microscope
    methods
        function obj=Joker
            obj.Name='Joker';
            obj.nameImage=imread('joker.jpg');
            path=mfilename('fullpath');
            k=strfind(path,filesep);
            obj.Config=[path(1:k(end-1)) 'MMJokerConfig.cfg'];
            obj.InitialChannel='DIC';
            obj.Autofocus=Autofocus('none');
            obj.pumpComs(1).com='dummy';%pump1
            obj.pumpComs(2).com='dummy';%pump2
            obj.pumpComs(1).baud=19200;
            obj.pumpComs(2).baud=19200;
            obj.OmeroInfoPath='';
            obj.OmeroCodePath='~/Documents/Omero code';
            obj.DataPath='~/Documents/DemoAcquisitionData';
            obj.XYStage='XY';
            obj.ZStage='DStage';
        end
    end
end