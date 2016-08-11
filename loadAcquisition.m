%Loads acquisition settings saved in a text file using the saveAcquisition
%function and creates an acquisition structure that can be used by
%runAcquisition
%Only input is a file name

function [acqData]=loadAcquisition(filename)
fid=fopen(filename);
currentState='';
currentLine=fgetl(fid);
counter=1;
while ischar(currentLine)
   if strcmp(currentLine,'Channels:')
       currentState='Channels';
       fgetl(fid);%To skip the heading line
       currentLine=fgetl(fid);
       counter=1;
       continue;
   end
   if strcmp(currentLine,'Z_sectioning:')
       currentState='Z sectioning';
       currentLine=fgetl(fid);
   end
   
    if strcmp(currentLine,'Time_settings:')
       currentState='Time settings';
       currentLine=fgetl(fid);
   end
   if strcmp(currentLine,'Points:')
       currentState='Points';
       currentLine=fgetl(fid);      
   end
   if strcmp(currentLine,'Flow_control:')
       currentState='Pumps';
       currentLine=fgetl(fid);
   end
   if strcmp(currentLine,'Dynamic flow details:')
       currentState='Dynamic flow';
       currentLine=fgetl(fid);      
   end
   
   
   switch currentState
       case 'Channels'
           chanCell=textscan(currentLine,'%12s%13u%4u%7u%10u%11u%7u%7.3f\n','Delimiter',{', '});
           chanCell{1}=char(chanCell{1});
           acqData.channels(counter,:)=chanCell;
           counter=counter+1;
           currentState='None';
       case 'Z sectioning'
           zVect=textscan(currentLine,'%2f%2.3f\n','Delimiter',{','});
           zVect=cell2mat(zVect);
           acqData.z=zVect;
           currentState='None';
       case 'Time settings'
           tVect=textscan(currentLine,'%u%u%u%u\n','Delimiter',{','});
           tVect=cell2mat(tVect);
           acqData.t=tVect;
           currentState='None';
       case 'Points'
           acqData.points={};
           done=false;%Keep track of whether all points have yet been read
           while ~done
               currentLine=fgetl(fid);
               if isempty(currentLine)
                   done=true;
               else
                   currentLine=textscan(currentLine,'%s','Delimiter',',');
                   currentLine=currentLine{:};
                   acqData.points{size(acqData.points,1)+1,1}=currentLine{1};
                   acqData.points{size(acqData.points,1),2}=str2double(currentLine{2});
                   acqData.points{size(acqData.points,1),3}=str2double(currentLine{3});
                   acqData.points{size(acqData.points,1),4}=str2double(currentLine{4});
                   acqData.points{size(acqData.points,1),5}=str2double(currentLine{5});
                   acqData.points{size(acqData.points,1),6}=str2double(currentLine{6});
                   for channel=1:size(acqData.channels,1)
                       %Exposure for each channel:
                       acqData.points{size(acqData.points,1),6+channel}=currentLine{6+channel};
                   end
              end
           end
           currentState='None';
       case 'Pumps'
           %Get number of pumps (currentLine is eg 'Syringe pump details: 2 pumps.')
           numPumps=str2double(currentLine(23:end-7));
           %Move through the next 3 lines which have no data
           currentLine=fgetl(fid);currentLine=fgetl(fid);currentLine=fgetl(fid);currentLine=fgetl(fid);
           microscope=chooseScope;
           
           for p=1:numPumps
               currentLine=fgetl(fid);
               currentLine=textscan(currentLine,'%9s%8.2f%12.2f%9s%7u%s\n','Delimiter',{','});
               pumpName=char(currentLine{1});
               BR=microscope.pumpComs(p).baud;
               diameter=currentLine{2};
               currentRate=currentLine{3};
               direction=char(currentLine{4});
               running=currentLine{5};
               contents=char(currentLine{6});
               pumpArray(p)=pump(pumpName,BR,diameter, currentRate, direction, running, contents);
           end
           acqData.flow{4}=pumpArray;
           currentState='None';
       case 'Dynamic flow'
           dynamicFlow=flowChanges(pumpArray);
           flowState='';
           done=false;
           while ~done
               if strcmp(currentLine,'Number of pump changes:')
                   flowState='Number';
                   currentLine=fgetl(fid);
               end
               if strcmp(currentLine,'Switching parameters:')
                   flowState='Params';
                   currentLine=fgetl(fid);
               end
               if strcmp(currentLine,'Times:')
                   flowState='Times';
                   currentLine=fgetl(fid);

               end
               if strcmp(currentLine,'Switched to:')
                   flowState='Switched to';
               end
               if strcmp(currentLine,'Switched from:')
                   flowState='Switched from';
               end
               if strcmp(currentLine,'Flow post switch:')
                   flowState='Flow post switch';
               end

               switch flowState 
                   case 'Number'
                       dynamicFlow.numChanges=str2double(currentLine);
                   case 'Params'
                       currentLine=textscan(currentLine,'%f%f','Delimiter',{','});
                       dynamicFlow.switchParams.withdrawVol=currentLine{1};
                       dynamicFlow.switchParams.rate=currentLine{2};
                   case 'Times'
                       
                   case 'Switched to'
                   case 'Switched from:'
                   case 'Flow post switch'                  
                        done=true;
               end
               currentLine=fgetl(fid);
           end
           
           
           acqData.flow{5}=dynamicFlow;
   end
   
currentLine=fgetl(fid);

end
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
microscope=chooseScope;
%Load the pumps
for n=1:nPumps
    if n==1
        pumpN=pump('Aladdin');
    else
        pumpN=pump(['Aladdin' num2str(n)]);;
    end
    pump.loadPumpDetails(fid);
    acqData.flow{4}(n)=pump;
end

%Load dynamic flow object:
acqData.flow{5}=flowChanges(acqData.flow{4});
acqData.flow{5}.loadChangeDetails(fid);

fclose(fid);