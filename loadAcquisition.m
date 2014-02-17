%Loads acquisition settings saved in a text file using the saveAcquisition
%function and creates an acquisition structure that can be used by
%runAcquisition
%Only input is a file name

function [acqData]=loadAcquisition(filename)
fid=fopen(filename);
rawdata = textscan(fid,'%s');
rawdata=rawdata{:};
channelPlace = strmatch('Channels:',rawdata);
zPlace=strmatch('Z_sectioning:',rawdata);
tPlace=strmatch('Time_settings:',rawdata);
pointsPlace=strmatch('Points:',rawdata);
flowPlace=strmatch('Flow_control:',rawdata);
infoPlace=strmatch('Flow_control:',rawdata);

%Get the channels data - need a loop because number of channels is not
%known
acqData.channels={};
nChannels=(zPlace-channelPlace-1);
if nChannels~=0
for ch=1:nChannels
    channel=rawdata(ch+channelPlace);%get an array with the info for this 
    %channel as comma-delimited string
    %The first entry is a string (the channel name), the rest are numbers
    %Need to know how many entries there are (depends on which version of
    %the software the file was saved from).
    
    
    channel=char(channel);
    chScan=textscan(channel,'%s %f %f %f %f %f %f %f','delimiter',',');
    chName=chScan{:};
    acqData.channels(ch,1)=chName(1);%convert to a string and put into
    %acqData
    %Remaining entries are numbers
    for n=2:size(chScan,2)
        acqData.channels(ch,n)=chScan(n);
    end
    
    %If the file was saved from the previous version of the GUI then chScan
    %will have only 5 entries, not 8. In this case add default values for
    %the last 3 entries to populate acqData.channels.
    
    if size(chScan,2)<6
       %default camera port is EM for fluorescence images but normal for
       %DIC.
       if strcmp(chName,'DIC')==1
            acqData.channels(ch,6)=num2cell(2);%normal camera port
       else
            acqData.channels(ch,6)=num2cell(1);%EM port
       end
       
       acqData.channels(ch,7)=num2cell(270);%starting gain default
       acqData.channels(ch,8)=num2cell(1);%starting epg default
        
    end
    
    
    
end%end of loop through the channels
end %Of if there are any channels defined

%Get Z sectioning data
zData=char(rawdata(zPlace+1));
zScan=textscan(zData,'%f','Delimiter',',');
zScan=zScan{:};
for n=1:size(zScan,1)
    acqData.z(n)=zScan(n);
end

%get timelapse data
tData=char(rawdata(tPlace+1));
tScan=textscan(tData,'%f','Delimiter',',');
tScan=tScan{:};
acqData.time(1)=tScan(1);
acqData.time(2)=tScan(2);
acqData.time(3)=tScan(3);
acqData.time(4)=tScan(4);

%Get point visiting data
acqData.points={};
nPoints=(flowPlace-pointsPlace-1);
for pos=1:nPoints
    point=rawdata(pos+pointsPlace);%The first entry is a string (the 
    %point name), the rest are numbers
    point=char(point);
    posScan=textscan(point,'%s %f %f %f %f %f','delimiter',',');
    posName=posScan{:};
    acqData.points(pos,1)=posName(1);%convert to a string and put into
    %acqData
    %Remaining entries are numbers
    for n=2:5
       acqData.points(pos,n)=posScan(n);
    end
end

%get flow control data

%First pump data:
%Get the number of pumps from the file:
rawdata = textscan(fid,'%s','Delimiter','\n');
rawdata=rawdata{:};
pumpLine=strncmp('Syringe pump details: ',rawdata,22);
split=textscan(rawdata{pumpLine},'%s','Delimiter',' ');
split=split{:};
nPumps=str2num(split{4});
%Load the pumps
for n=1:nPumps
    if n==1
        pumpN=pump('Aladdin');
    else
        pumpN=pump(['Aladdin' num2str(n)]);;
    end
    pumpN.loadPumpDetails(fid);
    acqData.flow{4}(n)=pumpN;
end

%Load dynamic flow object:
acqData.flow{5}=flowChanges(acqData.flow{4});
acqData.flow{5}.loadChangeDetails(fid);

fclose(fid);