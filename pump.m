classdef pump<handle
   
   properties
      diameter%double, in mm
      currentRate%ul/min
      direction%string
      running%logical
      contents%string
      pumpName%micromanager device name for the pump
      serial
      model%string, model number of the pump
   end
    
   methods
       function obj=pump(pumpName,BR,diameter, currentRate, direction, running, contents)
           obj.pumpName=pumpName;
           obj.serial=serial(obj.pumpName,'BaudRate',BR,'terminator','CR');
           if nargin>2
               obj.diameter=diameter;
               obj.currentRate=currentRate;
               obj.direction=direction;
               obj.running=running;
               obj.contents=contents;
           else
               obj.diameter=14.43;
               obj.currentRate=.4;
               obj.direction='INF';
               obj.running=false;
               obj.contents='2% raffinose in SC';
           end
           %Set the pump model - This needs edited if you ever move pumps
           %between computers. Can use the pumpName input to determine
           %which pump is which if you are running different models on the
           %same computer
           [idum,hostname]= system('hostname');
           if length(hostname)<14
               hostname(length(hostname)+1:14)=' ';
           end
           %Establish which computer is running this, and therefore which microscope
           k=strfind(hostname,'SCE-BIO-C03727');
           if ~isempty(k)
               %Robin
               obj.model='AL-1000';
           end
           k=strfind(hostname,'SCE-BIO-C03982');
           if ~isempty(k)
               %Batman
               obj.model='AL-1002X';
           end
           k=strfind(hostname,'SCE-BIO-C04078');
           if ~isempty(k)
               %Batgirl
               obj.model='AL-1002X';
           end
       end
       
       function updatePumps(obj)
           %Sets pump parameters according to the properties of the pump
           %object
           %             global mmc;
           %             if str2num(mmc.getProperty(obj.pumpName,'Run'))
           %                 mmc.setProperty((obj.pumpName),'Run',0);
           %             end
           %             mmc.setProperty((obj.pumpName),'FlowRate-uL/min',num2str(obj.currentRate));
           %             mmc.setProperty((obj.pumpName),'SyringeDiameter',num2str(obj.diameter));
           %             mmc.setProperty((obj.pumpName),'Volume-uL',num2str(0));%Zero volume = pump indefinitely
           %             mmc.setProperty((obj.pumpName),'Direction',obj.direction);
           %             mmc.setProperty((obj.pumpName),'Run',num2str(obj.running));
           disp(['Setting pump ' obj.pumpName '...']);
           fprintf(obj.serial,'STP');pause(.1);
           fprintf(obj.serial,['DIA' num2str(obj.diameter)]);pause(.1);
           disp(['Diameter' num2str(obj.diameter)]);
           fprintf(obj.serial,'PHN1');pause(.1);
           fprintf(obj.serial,'FUNRAT');pause(.1);
           fprintf(obj.serial,['RAT' num2str(obj.currentRate) 'UM']);pause(.1);
           disp(['Rate' num2str(obj.currentRate)]);
           fprintf(obj.serial,'VOL0');pause(.1);
           fprintf(obj.serial,['DIR' obj.direction]);pause(.1);
           if obj.running
               fprintf(obj.serial,'RUN1');pause(.1);
           end
       end
       
       function obj=writePumpDetails(obj,file)
           %Records the details contained in the pump object in the file
           %represented by the input file identifier. Must refer to a
           %valid, open text file. Used, eg., for writing details to a
           %microscope experiment Acq file.         
           %Heading line below to be run by the calling function (so that
           %heading only occurs once where there are multiple pumps).
           %fprintf(file,'Pump name, Diameter, Current rate, Direction, Running, Contents\n');
           fprintf(file,'%9s, %8.2f, %12.2f, %9s, %7u, %s\n',...
        obj.pumpName, ...
        obj.diameter, ...
        obj.currentRate, ...
        obj.direction, ...
        obj.running, ...
        obj.contents);
           

       end
       
       function loadPumpDetails(obj,file)
           %Loads the details from the input file and records to a pump
           %object. Input is a file identifier that must refer to a
           %valid, open text file, originally recorded by the
           %obj.writePumpDetails method. Used, eg., for loading details
           %from a microscope experiment Acq file.
           rawdata = textscan(file,'%s','Delimiter','\n');
           rawdata=rawdata{:};
            
           pumpLine=strncmp([obj.pumpName ':'],rawdata,length(obj.pumpName)+1);
           pumpDetails=textscan(rawdata{pumpLine},'%s','Delimiter',',');
           pumpDetails{1}=strrep(pumpDetails{1},':','');
           pumpDetails=pumpDetails{1};
           obj.diameter=str2num(pumpDetails{2});
           obj.currentRate=str2num(pumpDetails{3});
           obj.direction=pumpDetails{4};
           obj.running=str2num(pumpDetails{5});
           obj.contents=pumpDetails{6};
       end
       
       function reply=returnRate(obj)
           %Queries the pump to return the rate at which it is pumping.
           %This can be eg, written to the log file, or used to detect
           %pumping errors such as a stall
           %reply is a string, normally 'OOI*flowrate*UM', where flowrate
           %is the flow rate the pump is set at and UM is the units, in
           %this case microlitres/min
           %If the pump is in an error state (eg stalled) it will return:
           %  ' OOA?S'
           fprintf(obj.serial,'RAT');
           reply=fscanf(obj.serial);
       end
       
       function [obj warnings]=refreshPumpDetails(obj, logfile)
           %Input logfile is a handle to a text file in which to write the
           %output - optional
           warnings={''};
           disp(['Getting pump status for ' obj.pumpName '. Please wait...']);
           if nargin>1
                      fprintf(logfile,['Getting pump status for ' obj.pumpName]);
                      fprintf(logfile,'\r\n');
           end
           warnings='';
           %Queries the pump to set the correct values for all of the pump object properties
           %First 4 characters are always:
           % ' 00W' - pump is running
           % ' 00P' - paused (not running)
           % ' 00A?S - stalled
           %Error messages and warnings should be added to this function -
           %now only works for pumps that are switched on, connected and not stalled.
           %Diameter
           fprintf(obj.serial,'DIA');
           reply=fscanf(obj.serial);
           reply=textscan(reply,'%4s%f');  
           disp(['Diameter:' num2str(reply{2})]);
           if nargin>1
                fprintf(logfile,['Diameter:' num2str(reply{2})]);
                fprintf(logfile,'\r\n');
           end
           if ~isempty(reply{2})
           switch obj.model
               case 'AL-1000'
                   obj.diameter=reply{2};
               case 'AL-1002X'
                  obj.diameter=reply{2};
           end
           end
           %Rate (and running or not)
           fprintf(obj.serial,'RAT');
           reply=fscanf(obj.serial);
           reply=textscan(reply,'%4s%f');
           obj.currentRate=reply{2};
           pumpDetails=reply{1};          
           pumpStatus=pumpDetails{1};
           rateUnits=pumpDetails{2};
           if strcmp(pumpStatus(end),'I') || strcmp(pumpStatus(end),'W')
               obj.running=true;
           else
               obj.running=false;
           end
           
           %Report the results
           disp(['Status: ' pumpStatus]);
           disp(['Flow rate: ' num2str(reply{2})]);
           disp(['Rate units: ' rateUnits]);
           if nargin>1
                fprintf(logfile,['Status: ' pumpStatus]);
                fprintf(logfile,'\r\n');
                fprintf(logfile,['Flow rate: ' num2str(reply{2})]);
                fprintf(logfile,'\r\n');
                fprintf(logfile,['Rate units: ' rateUnits]);
                fprintf(logfile,'\r\n');
           end
           if isempty(strfind(rateUnits,'UM'))
               warnings{length(warnings)+1}='Pumping rate units are not microlitres/min! Reset before continuing.';
           end
           obj.running=strcmp(pumpStatus(end),'W');
           %Get the direction and volume in order to issue warnings if
           %necessary
           %Direction
           fprintf(obj.serial,'DIR');
           reply=fscanf(obj.serial);
           disp(['Direction: ' reply])
           if nargin>1
               fprintf(logfile,['Direction: ' reply]);
               fprintf(logfile,'\r\n');
           end
           if ~isempty(strfind(reply,'INF'))
                obj.direction='INF';
           end
           if ~isempty(strfind(reply,'WDR'))
                obj.direction='WDR';
                warnings{length(warnings)+1}='Pump is set to withdraw!';
           end
           %Volume
           fprintf(obj.serial,'VOL');
           reply=fscanf(obj.serial);
           disp(['Volume: ' reply])
           if nargin>1
               fprintf(logfile,['Volume: ' reply]);           
               fprintf(logfile,'\r\n');                           
           end
           
           if isempty(strfind(reply,'UL'))
                obj.direction='WDR';
                warnings{length(warnings)+1}='Volume units are not microlitres! This will wreck any fast infuse/withdraw steps - set to microlitres before running.';
           end
           if ~isempty(warnings) && nargin>1
               fprintf(logfile,['Warning: ' char(warnings)]);           
               fprintf(logfile,'\r\n'); 
           end
       end
       function delete(obj)
          if isa(obj.serial,'serial')
          fclose(obj.serial);
          end
           
       end
      
      
       
   end
   methods (Static)
        function diameter=getDiameter(volString) 
           %Returns the diameter (mm) of Becton Dickinson syringes of the model
           %specified by volString. Data is from the Aladdin pump manual:
           %http://www.wpiinc.com/clientuploads/pdf/Aladdin-IM.pdf p60
           switch volString
               case '1ml'
                   diameter=4.699;
               case '3ml'
                   diameter=8.585;
               case '5ml'
                   diameter=11.99;
               case '10ml'
                   diameter=14.43;
               case '20ml'
                   diameter=19.05;
               case '30ml'
                   diameter=21.59;
               case '60ml'
                   diameter=26.59;               
           end          
       end
       
       function volString=getVolString(diameter)
           %Returns a string giving the model of Becton Dickinson syringes
           %with the input diameter. Data is from the Aladdin pump manual:
           %http://www.wpiinc.com/clientuploads/pdf/Aladdin-IM.pdf p60
           
           switch diameter
               case 4.699
                   volString='1ml';
               case 8.585
                   volString='3ml';
               case 11.99
                   volString='5ml';
               case 14.43
                   volString='10ml';
               case 19.05
                   volString='20ml';
               case 21.59
                   volString='30ml';
               case 26.59
                   volString='60ml';           
           end
       end
       
       function minFlow=getMinFlow(volString)
           %Returns the mininum flow rate (ul/hr) of Becton Dickinson syringes with
           %the volume described by volString
           switch volString
               case '1ml'
                   minFlow=.73;
               case '3ml'
                   minFlow=2.434;
               case '5ml'
                   minFlow=4.748;
               case '10ml'
                   minFlow=6.876;
               case '20ml'
                   minFlow=11.99;
               case '30ml'
                   minFlow=15.4;
               case '60ml'
                   minFlow=23.35;               
           end
       end
       

   
   
   
    
   end
end