function [posFileName]=savePoints(acqData,exptFolder)

if nargin>1
    directory=exptFolder;
else
    startDir=char(acqData.info(3));
    if exist (startDir,'dir')~=7
        mkdir(startDir);
    end
    directory=uigetdir(startDir,'Choose directory to save points');
end
%Open the position file
acqName=char(acqData.info(1));
posFileName=strcat(directory,'\',acqName,'Pos.txt');
posFile=fopen(posFileName,'wt');

for n=1:size(acqData.points,1)
   fprintf(posFile,'%s',char(acqData.points(n,1)));%1. position name
   fprintf(posFile,'%s',',');
   fprintf(posFile,'%d',cell2mat(acqData.points(n,2)));%2. X stage position
   fprintf(posFile,'%s',',');
   fprintf(posFile,'%d',cell2mat(acqData.points(n,3)));%3. Y stage position
   fprintf(posFile,'%s',',');
   fprintf(posFile,'%d',cell2mat(acqData.points(n,4)));%4. Z drive position
   fprintf(posFile,'%s',',');
   fprintf(posFile,'%f',cell2mat(acqData.points(n,5)));%5. PFS offset
   fprintf(posFile,'%s',',');
   fprintf(posFile,'%d',cell2mat(acqData.points(n,6)));%6. Exposure time (for expose by point)
   fprintf(posFile,'\r\n');
end

fclose(posFile);