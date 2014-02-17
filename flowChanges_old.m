classdef flowChanges
    properties
        times%double vector, times at which changes should occur
        switched%logical vector, indicates if each switch has occurred
        pumps%cell array of pump objects
        switchedTo%double vector, number (index in obj.pumps) of the pump that has the faster pumping rate after each switch - zero for events that don't require fast infuse/withdraw step
        switchedFrom%double vector, number (index in obj.pumps)of the pump that has the slower pumping rate after each switch - zero for events that don't require fast infuse/withdraw step
        timesSwitched%double vector, record of the times at which each switch event has occurred
        flowPostSwitch%n * number of switches double array, Flow rates of each pump after switching (n=number of pumps)
        switchParams%structure, with the parameters governing switching
        numChanges%number of switching events
    end
    
    methods
        function obj=flowChanges(pumps)
            
            %Default parameters
            obj.times=0;
            obj.switched=true;
            obj.switchedTo=0;
            obj.switchedFrom=0;
            obj.numChanges=0;
            obj.timesSwitched=zeros(1,obj.numChanges);
            obj.flowPostSwitch=[.4 ; 4];%flow rates in microlitres/min
            obj.pumps=pumps;
            %Define default switching parameters
            obj.switchParams.withdrawVol=50;%vol in microlitres
            obj.switchParams.rate=10;%rate of pumping during switching in microlitres/min
        end
        
        function obj=setTimes(obj, times, flowRate)
            %Generates switching parameters from input times and flow rates
            %times = double vector (times in min of changes)
            %flowRate = m*n double matrix, where m=number of pumps and n = number of changes
            obj.numChanges=length(times);
            obj.times=times;
            obj.switched=false(1,obj.numChanges);
            obj.flowPostSwitch=flowRate;
            obj.timesSwitched=zeros(1,obj.numChanges);
            [maxFlow obj.switchedTo]=max(obj.flowPostSwitch);
            [minFlow obj.switchedFrom]=min(obj.flowPostSwitch);
            
        end
        
        function obj=setPeriodic(obj,switchInterval,switchStart,switchStop,highFlow,lowFlow,pumpIndices)
            
            %Generates periodic switching parameters
            if nargin<7
                pumpIndices=[1 2];
            end
            obj.numChanges=floor((switchStop-switchStart)/switchInterval);
            obj.times=switchStart:switchInterval:switchStop;
            obj.switched=false(1,obj.numChanges);
            obj.flowPostSwitch=[];
            tempHigh=repmat([highFlow lowFlow], 1, ceil(obj.numChanges/2));
            tempLow=repmat([lowFlow highFlow], 1, ceil(obj.numChanges/2));
            obj.flowPostSwitch(pumpIndices(1),1:obj.numChanges)=tempHigh(1,1:obj.numChanges);
            obj.flowPostSwitch(pumpIndices(2),1:obj.numChanges)=tempLow(1,1:obj.numChanges);
            obj.timesSwitched=zeros(1,obj.numChanges);
            [maxFlow obj.switchedTo]=max(obj.flowPostSwitch);
            [minFlow obj.switchedFrom]=min(obj.flowPostSwitch);
            
        end
        
        function obj=makeLinearRamp(obj,rampStart,rampStop,highFlow,lowFlow,highIndex, lowIndex)
            %Creates changes for linear pump ramp
            %highIndex=index (in obj.pumps) of the pump with the higher flow
            %rate at the start of the ramp.
            
            if nargin<6
                highIndex=1;
                lowIndex=2;
            end
            volString=pump.getVolString(obj.pumps{highIndex}.diameter);
            minRate=pump.getMinFlow(volString);
            minRate=minRate/60;%Conversion to ul/min from ul/hr
            rateStep=minRate/4;
            flowDrop=highFlow-lowFlow;
            rampTime=rampStop-rampStart;
            ratio=rateStep/flowDrop;
            rampInterval=ratio*rampTime;
            obj.numChanges=floor((rampStop-rampStart)/rampInterval);
            obj.times=rampStart:rampInterval:rampStop;
            obj.switched=false(1,obj.numChanges);
            obj.flowPostSwitch=[];
            obj.flowPostSwitch(lowIndex,1:obj.numChanges)=lowFlow+rateStep:rateStep:highFlow;
            obj.flowPostSwitch(highIndex,1:obj.numChanges)=highFlow-rateStep:-rateStep:lowFlow;
            obj.timesSwitched=zeros(1,obj.numChanges);
            %             [maxFlow obj.switchedTo]=max(obj.flowPostSwitch);
            %             [minFlow obj.switchedFrom]=min(obj.flowPostSwitch);
            obj.switchedTo=false(1,obj.numChanges);
            obj.switchedFrom=false(1,obj.numChanges);

        end
        
        function obj=shouldChange(obj, currTime, logfile)
            %Checks if switching should occur at the input time and does the
            %switching
            %Inputs:
            %obj = object of class switches
            %currTime = double, time in minutes
            %logFile = double, identifier of the log file
            global mmc;
            [nextSwitchTime ind]=min(obj.times(obj.switched==false));
            ind=min(find(obj.switched==false));
            if currTime>=nextSwitchTime
                
                if obj.switchedTo(ind)>0
                    %Experiment requires switching with fast infuse/withdraw
                    %step
                    logstring=['Switching pumps at ',datestr(clock) '. Fast infusion/withdrawal step: Rate=' num2str(obj.switchParams.rate) '. Volume=' num2str(obj.switchParams.withdrawVol)];acqData.logtext=writelog(logfile,'',logstring);
                    obj.switchFast(ind);
                    obj.switched(ind)=true;
                    obj.timesSwitched(ind)=currTime;
                    logstring=strcat('Pump switch complete at: ',datestr(clock));acqData.logtext=writelog(logfile,'',logstring);
                    logstring=['Dominant pump is now: ' obj.pumps{obj.switchedTo(ind)}.pumpName ' pumping at ' num2str(obj.flowPostSwitch(2)) 'ul/min'];acqData.logtext=writelog(logfile,'',logstring);
                    logstring=['Dominant medium is now: ' obj.pumps{obj.switchedTo(ind)}.contents];acqData.logtext=writelog(logfile,'',logstring);
                else
                    %Not a switching experiment - just need to alter the
                    %pump rates.
                    %Stop the pumps in preparation for changing pumping
                    %rates
                    mmc.setProperty((obj.pumps{1}.pumpName),'Run','0');
                    mmc.setProperty((obj.pumps{2}.pumpName),'Run','0');
                    obj.switched(ind)=true;
                    obj.timesSwitched(ind)=currTime;

                end
    
                  %Then reset pump flow rates and volumes
                  mmc.setProperty((obj.pumps{1}.pumpName),'FlowRate-uL/min',num2str(obj.flowPostSwitch(1,ind)));
                  mmc.setProperty((obj.pumps{2}.pumpName),'FlowRate-uL/min',num2str(obj.flowPostSwitch(2,ind)));
                  mmc.setProperty((obj.pumps{1}.pumpName),'Volume-uL',num2str(0));%Zero volume = pump indefinitely
                  mmc.setProperty((obj.pumps{2}.pumpName),'Volume-uL',num2str(0));%Zero volume = pump indefinitely
                  mmc.setProperty((obj.pumps{1}.pumpName),'Run','1');
                  mmc.setProperty((obj.pumps{2}.pumpName),'Run','1');
                  logstring=['Pump: ' (obj.pumps{1}.pumpName) ' running at: ' num2str(obj.flowPostSwitch(1,ind)) 'ul/min'];acqData.logtext=writelog(logfile,'',logstring);
                  logstring=['Pump: ' (obj.pumps{2}.pumpName) ' running at: ' num2str(obj.flowPostSwitch(2,ind)) 'ul/min'];acqData.logtext=writelog(logfile,'',logstring);                  
            end
            
        end
        
        function obj=switchFast(obj,ind)
            %Fast pump/withdraw phase to remove hysteresis
            global mmc;
            mmc.setProperty((obj.pumps{obj.switchedFrom(ind)}.pumpName),'Direction','Withdraw');
            mmc.setProperty((obj.pumps{obj.switchedFrom(ind)}.pumpName),'Run','0');
            mmc.setProperty((obj.pumps{obj.switchedTo(ind)}.pumpName),'Run','0');
            %             mmc.setProperty((obj.pumps{obj.switchedTo(ind)}.pumpName),'Direction','Infuse');
            mmc.setProperty((obj.pumps{obj.switchedTo(ind)}.pumpName),'FlowRate-uL/min',num2str(obj.switchParams.rate));
            mmc.setProperty((obj.pumps{obj.switchedFrom(ind)}.pumpName),'FlowRate-uL/min',num2str(obj.switchParams.rate));
            mmc.setProperty((obj.pumps{obj.switchedTo(ind)}.pumpName),'Volume-uL',num2str(obj.switchParams.withdrawVol+1.5*1e3));
            mmc.setProperty((obj.pumps{obj.switchedFrom(ind)}.pumpName),'Volume-uL',num2str(obj.switchParams.withdrawVol-0));
            
            mmc.setProperty((obj.pumps{obj.switchedTo(ind)}.pumpName),'Run','1');
            mmc.setProperty((obj.pumps{obj.switchedFrom(ind)}.pumpName),'Run','1');
            
            toc
            finished=false;
            while ~finished
               pumpOn=mmc.getProperty(obj.pumps{obj.switchedTo(ind)}.pumpName,'Run');
               if strcmp(pumpOn,'0')
                   finished=true;
               end
               pause(0.1);
            end
            toc
         mmc.setProperty((obj.pumps{obj.switchedFrom(ind)}.pumpName),'Direction','Infuse');

        end
        
        function obj=setSwitchParams(obj)
            %runs user dialogue to determine the parameters for switching.
            defaults={'50','10'};
            answers=inputdlg({'Volume for fast pumping stage of switch (ul)','Flow rate for fast pumping stage of switch (ul/min)'},'Switching parameters',1,defaults);
            obj.switchParams.withdrawVol=str2num(answers{1});
            obj.switchParams.rate=str2num(answers{2});
            
        end
        
        function writeChangeDetails(obj,file)
            %Records the details contained in the changes object in the file
            %represented by the input file identifier. Must refer to a
            %valid, open text file. Used, eg., for writing details to a
            %microscope experiment Acq file.
            fprintf(file,'\r\n');
            fprintf(file,'Dynamic flow details:');
            fprintf(file,'\r\n');
            fprintf(file,['Number of pump changes:' num2str(obj.numChanges)]);
            fprintf(file,'\r\n');            
            fprintf(file,['Switching parameters:' num2str(obj.switchParams.withdrawVol) ',' num2str(obj.switchParams.rate)]);
            fprintf(file,'\r\n');
            timeString=obj.makeString(obj.times);           
            fprintf(file,['Times:' timeString]);
            fprintf(file,'\r\n');
            fprintf(file,'Pump names:');
            for n=1:length(obj.pumps)
                if n>1 fprintf(file,','); end
                fprintf(file, obj.pumps{n}.pumpName);
            end
            fprintf(file,'\r\n');
            switchedToString=obj.makeString(obj.switchedTo);
            fprintf(file,['Switched to:' switchedToString]);
            fprintf(file,'\r\n');
            switchedFromString=obj.makeString(obj.switchedFrom);
            fprintf(file,['Switched from:' switchedFromString]);
            fprintf(file,'\r\n');
            fprintf(file,['Flow post switch:']);
            for n=1:size(obj.flowPostSwitch,1)
                fprintf(file,'\r\n');
                fprintf(file, obj.makeString(obj.flowPostSwitch(n,:)));
            end           
        end
        
        function obj=loadChangeDetails(obj,file)
            %Reads the details for a flowChanges object from the input
            %file identifier , which should refer to file in which details
            %have been written by the writeChangeDetails method.
            rawdata = textscan(file,'%s','Delimiter','\n');
            rawdata=rawdata{:};
            
            numLine=strncmp('Number of pump changes:',rawdata,23);
            obj.numChanges=str2num(rawdata{numLine}(24:end));
            
            paramLine=strncmp('Switching parameters:',rawdata,21);paramLine=find(paramLine);paramLine=paramLine(end);
            params=textscan(rawdata{paramLine},'%s','Delimiter',',');
            params{1}=strrep(params{1},'Switching parameters:','');
            params=params{1};
            params=str2double(params);
            obj.switchParams.withdrawVol=params(1);
            obj.switchParams.rate=params(2);
            
            timesLine=strncmp('Times:',rawdata,6);timesLine=find(timesLine);timesLine=timesLine(end);
            times=textscan(rawdata{timesLine},'%s','Delimiter',',');
            times{1}=strrep(times{1},'Times:','');
            times=times{1};
            times=str2double(times);
            obj.times=times';
            
            %Pumps created using the pump class - should be assigned to the
            %flowChanges object.pumps elsewhere
            
            switchedToLine=strncmp('Switched to:',rawdata,12);switchedToLine=find(switchedToLine);switchedToLine=switchedToLine(end);
            switchedTo=textscan(rawdata{switchedToLine},'%s','Delimiter',',');
            switchedTo{1}=strrep(switchedTo{1},'Switched to:','');
            switchedTo=switchedTo{1};
            switchedTo=str2double(switchedTo);
            obj.switchedTo=switchedTo';
            
            switchedFromLine=strncmp('Switched from:',rawdata,14);switchedFromLine=find(switchedFromLine);switchedFromLine=switchedFromLine(end);
            switchedFrom=textscan(rawdata{switchedFromLine},'%s','Delimiter',',');
            switchedFrom{1}=strrep(switchedFrom{1},'Switched from:','');
            switchedFrom=switchedFrom{1};
            switchedFrom=str2double(switchedFrom);
            obj.switchedFrom=switchedFrom';
            
            flowPostLine=strncmp('Flow post switch:',rawdata,17);flowPostLine=find(flowPostLine);flowPostLine=flowPostLine(end)            
            pump1=textscan(rawdata{flowPostLine+1},'%s','Delimiter',',');
            pump1{1}=strrep(pump1{1},'Flow post switch:','');
            pump1=pump1{1};
            pump1=str2double(pump1);
            obj.flowPostSwitch=pump1';
            
            pump2=textscan(rawdata{flowPostLine+2},'%s','Delimiter',',');
            pump2{1}=strrep(pump2{1},'Flow post switch:','');
            pump2=pump2{1};
            pump2=str2double(pump2);
            obj.flowPostSwitch(2,:)=pump2';
        end
            
        
        
        
    end
    methods (Static)
        function outString = makeString(numbers)
            %Function to format vectors and matrices for writing to file
            outString=num2str(numbers,'%g,');
            outString=strrep(outString,' ','');
            if strcmp(outString(end),',')
                outString=outString(1:end-1);
            end
        end
    end
    
    
    
end