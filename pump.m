classdef pump
   
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
           
           fprintf(obj.serial,'STP');pause(.1);
           fprintf(obj.serial,['DIA' num2str(obj.diameter)]);pause(.1);
           
           fprintf(obj.serial,'PHN1');pause(.1);
           fprintf(obj.serial,'FUNRAT');pause(.1);
           fprintf(obj.serial,['RAT' num2str(obj.currentRate) 'UM']);pause(.1);
           fprintf(obj.serial,'VOL0');pause(.1);
           fprintf(obj.serial,['DIR' obj.direction]);pause(.1);
           if obj.running
               fprintf(obj.serial,'RUN1');pause(.1);
           end
       end
       
       function writePumpDetails(obj,file)
           %Records the details contained in the pump object in the file
           %represented by the input file identifier. Must refer to a
           %valid, open text file. Used, eg., for writing details to a
           %microscope experiment Acq file.
           fprintf(file,'%s:,%.2f,%.2f,%s,%i,%s',obj.pumpName,obj.diameter,...
               obj.currentRate,obj.direction,obj.running,obj.contents); 
           fprintf(file,'\r\n');

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
       function openPump(obj)
           %Opens the pump for sending and receiving commands
           [idum,hostname]= system('hostname');
           if strfind(hostname,'SCE-BIO-C02471')>0                
                fopen(obj.serial);
           else
               %Not running on the microscope computer - create a false
               %open command - to allow the software to run.
               obj.serial='Pump open';
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