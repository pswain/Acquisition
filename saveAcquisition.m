function [acqFileName]=saveAcquisition(acqData,exptFolder)

%Make experiment directory if it's not made already

if exist (exptFolder,'dir')~=7
    mkdir(exptFolder);
end

%Open the acquisition file
acqName=char(acqData.info(1));
acqFileName=strcat(exptFolder,'\',acqName,'Acq.txt');
acqFile=fopen(acqFileName,'wt');

%Saving of acquisition parameters
%Channels
fprintf(acqFile,'%s','Channels:');
nChannels=size(acqData.channels,1);%number of channels
fprintf(acqFile,'\n');
fprintf(acqFile,'Channel name, Exposure time, Skip, Z sect., Start time, Camera mode, EM gain, Voltage\n');
for n=1:nChannels
    fprintf(acqFile,'%12s, %13u, %4u, %7u, %10u, %11u, %7u, %7.3f\n',...
        char(acqData.channels(n,1)), ... 1. channel name
        cell2mat(acqData.channels(n,2)), ... 2. exposure time in ms
        cell2mat(acqData.channels(n,3)),... 3. skip number
        cell2mat(acqData.channels(n,4)), ... 4. use z sectioning 1 or 0
        cell2mat(acqData.channels(n,5)),... 5. starting timepoint
        cell2mat(acqData.channels(n,6)),... 6. Camera mode (1, 2 or 3)
        cell2mat(acqData.channels(n,7)),... 7. Starting EM gain
        cell2mat(acqData.channels(n,8)));%8. LED voltage
end
%Z sectioning
fprintf(acqFile,'Z_sectioning:\n');
fprintf(acqFile,'Sections,Spacing,PFSon?,AnyZ?,Drift,Method\n');
fprintf(acqFile,'%8u,%7.2f,%6u,%5u,%5u,%6u\n',...
    acqData.z(1), ... 1. Sections
    acqData.z(2), ... 2. Spacing
    acqData.z(3), ... 3. PFS on
    acqData.z(4), ... 4. Any Z
    acqData.z(5), ... 5. Drift (always zero at start of expt)
    acqData.z(6));  % 6. Sectioning method

%timelapse settings
fprintf(acqFile,'%s','Time_settings:');
fprintf(acqFile,'\n');
fprintf(acqFile,'%u',acqData.time(1));%use timelapse (1 or 0)
fprintf(acqFile,'%s',',');
fprintf(acqFile,'%u',acqData.time(2));%interval in s
fprintf(acqFile,'%s',',');
fprintf(acqFile,'%u',acqData.time(3));%number of time points
fprintf(acqFile,'%s',',');
fprintf(acqFile,'%u',acqData.time(4));%total time in s
fprintf(acqFile,'\n');
%Points to visit
fprintf(acqFile,'Points:\n');%need to check if any point visiting with an
%if statement
nPoints=size(acqData.points,1);
if nPoints>0
    savePoints(acqData,acqFile);
end

%Flow control
fprintf(acqFile,'\n');
fprintf(acqFile,'%s','Flow_control:');
fprintf(acqFile,'\n');
%Call functions to write details from the pump and flowChanges objects
fprintf(acqFile,'%s',['Syringe pump details: ' num2str(length(acqData.flow{4})) ' pumps.']);
fprintf(acqFile,'\r\nPump states at beginning of experiment:\r\n');
fprintf(acqFile,'Pump port, Diameter, Current rate, Direction, Running, Contents\n');
for n=1:length(acqData.flow{4})
    acqData.flow{4}(n).writePumpDetails(acqFile);
end
acqData.flow{5}.writeChangeDetails(acqFile);
fclose(acqFile);


%Finally save the acquisition filename in a constant file (but different for different users) - this can
%be accessed to allow loading of the last saved acquisition
user=getenv('USERNAME');
lastSavedPath=strcat('C:\Documents and Settings\All Users\multiDGUIfiles\',user,'lastSaved.txt');
lastSavedAcq=fopen(lastSavedPath,'wt');
if lastSavedAcq~=-1
fprintf(lastSavedAcq,'%s',acqFileName);
fclose(lastSavedAcq);
end


