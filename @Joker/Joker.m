classdef Joker<Microscope
    methods
        function obj=Joker
            obj.Name='Joker';
            obj.nameImage=imread('joker.jpg');
            obj.Config='MMJokerConfig.cfg';
            obj.InitialChannel='DIC';
            obj.Autofocus=Autofocus('');
            obj.pumpComs(1).com='dummy';%pump1
            obj.pumpComs(2).com='dummy';%pump2
            obj.pumpComs(1).baud=19200;
            obj.pumpComs(2).baud=19200;
            obj.OmeroInfoPath='~/OmeroDsTemp/';
            obj.OmeroCodePath='~/Documents/Omero code';
            obj.DataPath=['/Volumes/Users/' char(java.lang.System.getProperty('user.name')) '/OmeroTemp/'];
            obj.XYStage='DXYStage';
            obj.ZStage='DStage';
        end
    end
end