%Loads acquisition settings saved in a text file using the saveAcquisition
%function and modifies the acquisition structure that can be used by
%runAcquisition
%Only input is a file name

function [acqData]=loadAcquisition(acqData,filename)
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
       fgetl(fid);%To skip the heading line
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
           %currentState is still 'Channels' - this will allow subsequent
           %channels lines to be recorded
       case 'Z sectioning'
           zVect=textscan(currentLine,'%8u%7.2f%6u%5u%5u%6u\n','Delimiter',{','});
           zVect=cellfun(@double,zVect);
           acqData.z=zVect;
           currentState='None';
       case 'Time settings'
           tVect=textscan(currentLine,'%u%u%u%u\n','Delimiter',{','});
           tVect=cell2mat(tVect);
           acqData.t=tVect;
           currentState='None';
       case 'Points'
           %When loading the points - need to be careful about z positions
           %- set all Z positions to the current Z - this will avoid
           %potentially visiting points that are too high up and smashing
           %through the coverslip.
           currentZ=acqData.microscope.getZ;
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
                   acqData.points{size(acqData.points,1),4}=currentZ;
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
           pumpArray=acqData.flow{4};
           for p=1:numPumps
               currentLine=fgetl(fid);
               currentLine=textscan(currentLine,'%9s%8.2f%12.2f%9s%7u%s\n','Delimiter',{','});
               pumpArray(p).pumpName=char(currentLine{1});
               pumpArray(p).diameter=currentLine{2};
               pumpArray(p).currentRate=currentLine{3};
               pumpArray(p).direction=char(currentLine{4});
               pumpArray(p).contents=char(currentLine{6});
           end
           acqData.flow{4}=pumpArray;
           %Update the pumps with the new settings
           for p=1:numPumps
               pumpArray(p).updatePumps;
           end
           currentState='None';
       case 'Dynamic flow'
           dynamicFlow=flowChanges({pumpArray(1),pumpArray(2)});%Pump array is input and saved as a cell array in flowChanges object.
           flowState='';
           done=false;
           while ~done
               if strcmp(currentLine,'Number of pump changes:')
                   flowState='Number';
                   currentLine=fgetl(fid);
               end
               if strcmp(currentLine,'Switching parameters:')
                   flowState='SwitchParams';
                   currentLine=fgetl(fid);
               end 
               if strcmp(currentLine,'Infuse/withdraw volumes:')
                   flowState='Volumes';
                   currentLine=fgetl(fid);
               end
               if strcmp(currentLine,'Infuse/withdraw rates:')
                   flowState='Rates';
                   currentLine=fgetl(fid);
               end              
               if strcmp(currentLine,'Times:')
                   flowState='Times';
                   currentLine=fgetl(fid);
               end
               if strcmp(currentLine,'Switched to:')
                   flowState='Switched to';
                   currentLine=fgetl(fid);
               end
               if strcmp(currentLine,'Switched from:')
                   flowState='Switched from';
                   currentLine=fgetl(fid);
               end
               if strcmp(currentLine,'Flow post switch:')
                   flowState='Flow post switch';
                   currentLine=fgetl(fid);
               end

               switch flowState 
                   case 'Number'
                       dynamicFlow.numChanges=str2double(currentLine);
                   case 'Volumes'                       
                       currentLine=textscan(currentLine,'%s','Delimiter',',');
                       currentLine=currentLine{:};
                       dynamicFlow.switchParams.withdrawVol=str2double(currentLine)';                       
                   case 'Rates'
                       currentLine=textscan(currentLine,'%s','Delimiter',',');
                       currentLine=currentLine{:};
                       dynamicFlow.switchParams.rate=str2double(currentLine)';      
                   case 'Times'
                       currentLine=textscan(currentLine,'%s','Delimiter',',');
                       currentLine=currentLine{:};
                       dynamicFlow.times=str2double(currentLine)';
                   case 'Switched to'
                       currentLine=textscan(currentLine,'%s','Delimiter',',');
                       currentLine=currentLine{:};
                       dynamicFlow.switchedTo=str2double(currentLine)';
                   case 'Switched from'
                       currentLine=textscan(currentLine,'%s','Delimiter',',');
                       currentLine=currentLine{:};
                       dynamicFlow.switchedFrom=str2double(currentLine)';
                   case 'Flow post switch'
                       dynamicFlow.flowPostSwitch=[];
                       %There will be a line for each pump
                       for p=1:numPumps
                           if isempty(currentLine)%This is needed to allow loading of files saved by an older version
                               currentLine=fgetl(fid);
                           end
                           currentLine=textscan(currentLine,'%s','Delimiter',',');
                           currentLine=currentLine{:};
                           dynamicFlow.flowPostSwitch(p,:)=str2double(currentLine)';
                           currentLine=fgetl(fid);
                       end
                       %This is the last entry in the flow changes section
                       done=true;
               end
               currentLine=fgetl(fid);
           end
           
           dynamicFlow.switched=false(1,length(dynamicFlow.times));
           dynamicFlow.timesSwitched=zeros(1,length(dynamicFlow.times));
           acqData.flow{5}=dynamicFlow;
           
   end
   
currentLine=fgetl(fid);

end


fclose(fid);