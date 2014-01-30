%Makes log file and folders for multiD acquisition
%Calls saveAcquisition to save acquisition settings.
%Input is structure carrying the acquisition settings
%3 outputs:
%logFile - ID of the log file that is created to record events during the
%          experiment
%exptFolder - path of folder in which data is to be stored
%directories - cell array of strings. Paths of the folders to store images
%              from each individual position in point visiting experiments
%              an empty cell array if no point visiting.

function [logFile,exptFolder,directories]=initializeFiles(acqData)
%Make experiment directory
root=acqData.info(3);
acqName=acqData.info(1);
dir=char(strcat(root,'/',acqName));
exptNum=0;
exptNumString=sprintf('%02d',exptNum);
exptFolder=char(strcat(dir,'_',exptNumString));
while exist(exptFolder,'dir')==7
    exptNum=(exptNum+1);
    exptNumString=sprintf('%02d',exptNum);
    exptFolder=char(strcat(dir,'_',exptNumString));
end
mkdir(exptFolder);

%save acquisition settings
saveAcquisition(acqData,exptFolder);
%Open log file and write preliminary stuff
logname=char(strcat(exptFolder,'/',acqName,'log.txt'));
logFile=fopen(logname,'w');%Then can write to logfile later using fprintf(logfile,'string goes here');
fprintf(logFile,'%s','Swain Lab microscope experiment log file');
fprintf(logFile,'\r\n');
today=date;
fprintf(logFile,'%s',today);
fprintf(logFile,'\r\n');
fprintf(logFile,'%s','Acquisition settings are saved in:');
fprintf(logFile,'\r\n');
acqName=acqData.info(1);
acqFileName=char(strcat(exptFolder,'/',acqName,'Acq.txt'));
fprintf(logFile,'%s',acqFileName);
fprintf(logFile,'\r\n');
fprintf(logFile,'%s','Experiment details:');
fprintf(logFile,'\r\n');
% if iscell(acqData.info(4))
%      acqData.info(4)=acqData.info{4};
% end
fprintf(logFile,'%s',char(acqData.info(4)));
fprintf(logFile,'\r\n');

%Record omero project name and tags
if isfield(acqData,'omero')
   if ~isempty(acqData.omero.project)
        fprintf(logFile,'%s','Omero project:');
        fprintf(logFile,'\r\n');
        try
            fprintf(logFile,'%s',acqData.omero.project.name);
        catch
            fprintf(logFile,'%s',acqData.omero.project);
        end
        fprintf(logFile,'\r\n');
   end
   if ~isempty(acqData.omero.tags)
        fprintf(logFile,'%s','Omero tags:');
        fprintf(logFile,'\r\n');
        for n=1:length(acqData.omero.tags)
            fprintf(logFile,'%s',acqData.omero.tags{n});
            fprintf(logFile,'%s',',');
        end
        fprintf(logFile,'\r\n');
   end   
end



%Make individual directories for each point if it's a multiPoint
%acquisition
sizePoints=size(acqData.points);
numPositions=sizePoints(1);
directories={''};
if numPositions>0
    for n=1:numPositions
    directories(n)=cellstr(strcat(exptFolder,'\',char(acqData.points(n,1))));
    mkdir (char(directories(n)));
    end
end
%save the point list (if there is one)
if numPositions>0
   savePoints(acqData,exptFolder);
end

%Create a temporary file to indicate that the experiment is in progress -
%this will be deleted when the experiment is completed.
tempname=char(strcat(exptFolder,'/temp_InProgress.txt'));
tempFile=fopen(tempname,'w');
fprintf(tempFile,'%s',[exptFolder,'/',char(acqName)]);
fprintf(tempFile,'\r\n');
fprintf(tempFile,'%s','This experiment is in progress. Will not be uploaded to Omero database.');
fclose (tempFile);
