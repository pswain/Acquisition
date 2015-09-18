classdef flowChanges
    properties
        times%double vector, times at which changes should occur
        initialPump%integer, The number of the dominant pump at the start of the experiment - used for switching experiments only
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
            obj.initialPump=1;
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
            obj.switchParams.rate=100;%rate of pumping during switching in microlitres/min
        end
        
        function obj=setSwitchTimes(obj, times, flowRate, initialPump)
            %Generates switching parameters from input times and flow rates
            %for switching experiments.
            
            %times = double vector (times in min of changes)
            %flowRate = m*n double matrix, where m=number of pumps and n = number of changes
            %initialPump = integer, the number of the initially dominant pump - flowing at the higher rate at the start of the acquisition
            
            obj.initialPump=initialPump;
            obj.numChanges=length(times);
            obj.times=times;
            obj.switched=false(1,obj.numChanges);
            obj.flowPostSwitch=flowRate;
            obj.timesSwitched=zeros(1,obj.numChanges);
%             [maxFlow obj.switchedTo]=max(obj.flowPostSwitch);
%             [minFlow obj.switchedFrom]=min(obj.flowPostSwitch);
            obj.switchedTo=ones(1,length(obj.times));           
            obj.switchedTo(initialPump:2:end)=2;
            obj.switchedFrom=ones(1,length(obj.times));
            obj.switchedFrom(3-initialPump:2:end)=2;

            
            
        end
        
        
        
        function obj=setPeriodic(obj,switchInterval,switchStart,switchStop,highFlow,lowFlow,pumpIndices)
            
            %Generates periodic switching parameters
            if nargin<7
                pumpIndices=[1 2];
            end
            obj.times=switchStart:switchInterval:switchStop;
            obj.numChanges=length(obj.times);
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
        
        function obj=setFlowTimes(obj,txtTimes,flowRates) 
            %Creates changes for linear pump ramp
            %highIndex=index (in obj.pumps) of the pump with the higher flow
            %rate at the start of the ramp.
                        
            obj.numChanges=length(txtTimes);
            obj.times=txtTimes;
            obj.switched=false(1,obj.numChanges);
            obj.flowPostSwitch=flowRates;
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
                    if ind==1
                        obj.setSwitchPhases;
                    end
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
                    flowrates=[obj.flowPostSwitch(1,ind) obj.flowPostSwitch(2,ind)];
                    ratioFlow=max(flowrates)/min(flowrates);
                    if ratioFlow>3
                        flowrates=flowrates * 1.5/6*(ratioFlow-3)+.5;
                    else
                        flowrates=flowrates*.5;
                    end
                    
                    p1=obj.pumps{1}.serial;
                    p2=obj.pumps{2}.serial;
                    fprintf(p1,'STP');fprintf(p2,'STP');pause(.05);
                    fprintf(p1,'PHN2');fprintf(p2,'PHN2');pause(.05);
                    fprintf(p1,'FUNRAT');fprintf(p2,'FUNRAT');pause(.05);
                    fprintf(p1,['RAT' num2str(obj.flowPostSwitch(1,ind)) 'UM']);fprintf(p2,['RAT' num2str(obj.flowPostSwitch(2,ind)) 'UM']);pause(.05);

%                     fprintf(p1,['RAT' num2str(flowrates(1))]);
%                     fprintf(p2,['RAT' num2str(flowrates(2))]);pause(.05);
                    
                    fprintf(p1,'VOL0');fprintf(p2,'VOL0');pause(.05);
                    fprintf(p1,'RUN2');fprintf(p2,'RUN2');
                    
                    obj.switched(ind)=true;
                    obj.timesSwitched(ind)=currTime;

                end
    
                  %Then reset pump flow rates and volumes
                  logstring=['Pump: ' (obj.pumps{1}.pumpName) ' running at: ' num2str(obj.flowPostSwitch(1,ind)) 'ul/min'];acqData.logtext=writelog(logfile,'',logstring);
                  logstring=['Pump: ' (obj.pumps{2}.pumpName) ' running at: ' num2str(obj.flowPostSwitch(2,ind)) 'ul/min'];acqData.logtext=writelog(logfile,'',logstring);                  
            end
            
        end
        
        function obj=switchFast(obj,ind)
            %Fast pump/withdraw phase to remove hysteresis
            sFrom=obj.pumps{obj.switchedFrom(ind)}.serial;
            sTo=obj.pumps{obj.switchedTo(ind)}.serial;
            
            fprintf(sFrom,'RUN4');
            fprintf(sTo,'RUN2');
            
            %Check that both pumps are set to the correct rate and
            %direction
            
        end
        
        function obj=setSwitchPhases(obj)
            p1=obj.pumps{1}.serial;
            p2=obj.pumps{2}.serial;
            
            %The next part is necessary because NE100 pumps pumps switch
            %their vol units from ul to ml if using 10ml syringes (diam 14.43)
            %or bigger. You can manually change
            %the units to nl on that pump - will be a disaster if someone
            %does this...            
            
            %Correct volume for units on pump1(obj.switchParams.withdrawVol
            %is in ul)
            switch obj.pumps{1}.model
                case 'AL-1000'
                    if obj.pumps{1}.diameter>=14.4
                        %Pump volume units will be ml.
                        wVol1=num2str(obj.switchParams.withdrawVol/1e3);
                    else
                        wVol1=num2str(obj.switchParams.withdrawVol);
                    end
                case 'AL-1002X'
                    wVol1=num2str(obj.switchParams.withdrawVol);
            end
            
            switch obj.pumps{2}.model
                case 'AL-1000'
                    if obj.pumps{2}.diameter>=14.4
                        %Pump volume units will be ml.
                        wVol2=num2str(obj.switchParams.withdrawVol/1e3);
                    else
                        wVol2=num2str(obj.switchParams.withdrawVol);
                    end
                case 'AL-1002X'
                    wVol2=num2str(obj.switchParams.withdrawVol);
            end

            
            fprintf(p1,'STP');fprintf(p2,'STP');pause(.05);
            fprintf(p1,'PHN2');fprintf(p2,'PHN2');pause(.05);
            fprintf(p1,'FUNRAT');fprintf(p2,'FUNRAT');pause(.05);
            fprintf(p1,['RAT' num2str(obj.switchParams.rate)  'UM']);fprintf(p2,['RAT' num2str(obj.switchParams.rate)  'UM']);pause(.05);
            fprintf(p1,['VOL' wVol1]);fprintf(p2,['VOL' wVol2]);pause(.05);
            fprintf(p1,'DIRINF');fprintf(p2,'DIRINF');pause(.05);
            fprintf(p1,'PHN3');fprintf(p2,'PHN3');pause(.05);
            fprintf(p1,'FUNRAT');fprintf(p2,'FUNRAT');pause(.05);

            fprintf(p1,['RAT' num2str(max(obj.flowPostSwitch(:))) 'UM']);fprintf(p2,['RAT' num2str(max(obj.flowPostSwitch(:))) 'UM']);pause(.05);

            fprintf(p1,'VOL0');fprintf(p2,'VOL0');pause(.05);
            fprintf(p1,'DIRINF');fprintf(p2,'DIRINF');pause(.05);
            
            fprintf(p1,'PHN4');fprintf(p2,'PHN4');pause(.05);
            fprintf(p1,'FUNRAT');fprintf(p2,'FUNRAT');pause(.05);
            fprintf(p1,['RAT' num2str(obj.switchParams.rate) 'UM']);fprintf(p2,['RAT' num2str(obj.switchParams.rate) 'UM']);pause(.05);
            fprintf(p1,['VOL' wVol1]);fprintf(p2,['VOL' wVol2]);pause(.05);
            fprintf(p1,'DIRWDR');fprintf(p2,'DIRWDR');pause(.05);
            fprintf(p1,'PHN5');fprintf(p2,'PHN5');pause(.05);
            fprintf(p1,'FUNRAT');fprintf(p2,'FUNRAT');pause(.05);
            fprintf(p1,['RAT' num2str(min(obj.flowPostSwitch(:)))  'UM']);fprintf(p2,['RAT' num2str(min(obj.flowPostSwitch(:))) 'UM']);pause(.05);
            fprintf(p1,'VOL0');fprintf(p2,'VOL0');pause(.05);
            fprintf(p1,'DIRINF');fprintf(p2,'DIRINF');pause(.05);
        end
        
        function obj=setSwitchParams(obj)
            %runs user dialogue to determine the parameters for switching.
            defaults={'50','100'};
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
        
        function obj=displayFlowChanges(obj)
        %Displays the information contained in the object - should allow
        %the user to check if things are correctly set up
        
        %This is unfinished (obviously)
        dispFig=figure('Toolbar','none','menubar','none','numbertitle','off','name','Switching experiment setup');
        %Convert times to comma-separated string
        timesString=commaString(obj.times);
        timesText=uicontrol('Parent',dispFig,'Style','Text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .90   1 .03],'String',['Switching times (min): ' timesString]);
        initialText=uicontrol('Parent',dispFig,'Style','text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .95   1 .03],'String',['Initial pump: ' num2str(obj.initialPump)]);
        switchedToText=uicontrol('Parent',dispFig,'Style','text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .85   1 .03],'String',['Pump switched to at each change: ' commaString(obj.switchedTo)]);
        switchedFromText=uicontrol('Parent',dispFig,'Style','text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .80   1 .03],'String',['Pump switched from at each change: ' commaString(obj.switchedFrom)]);
        postSwitch1Text=uicontrol('Parent',dispFig,'Style','text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .75   1 .03],'String',['Pump1 flow rate after each switch: ' commaString(obj.flowPostSwitch(1,:))]);
        postSwitch2Text=uicontrol('Parent',dispFig,'Style','text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .70   1 .03],'String',['Pump2 flow rate after each switch: ' commaString(obj.flowPostSwitch(2,:))]);
        volText=uicontrol('Parent',dispFig,'Style','text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .65   1 .03],'String',['Volume of fast infuse/withdraw step during switching:' num2str(obj.switchParams.withdrawVol)]);
        rateText=uicontrol('Parent',dispFig,'Style','text','HorizontalAlignment','left','Units', 'Normalized','Position',[.02 .60   1 .03],'String',['Rate of fast infuse/withdraw step during switching:' num2str(obj.switchParams.rate)]);
        %Plot a visual representation of the switching
        switchPlot=axes('Parent',dispFig,'Units','Normalized','Position',[.02 .05  .95 .45]);figure(gcf)
        %Set axis limits
        maxTime=1.1*max(obj.times);
        set(switchPlot, 'XLim',[0 maxTime]);
        maxRate=1.1*max(max(obj.flowPostSwitch(:)));
        set(switchPlot,'YLim',[0 maxRate]);
        set(switchPlot, 'XLim',[0 maxTime]);
        set(switchPlot,'YLim',[0 maxRate]);
        hold on
        timeVector=obj.times;
        timeVector(end+1)=maxTime;
        for n=2:length(timeVector)
            times=[timeVector(n) timeVector(n-1)];
            flow1=[obj.flowPostSwitch(1,n-1) obj.flowPostSwitch(1,n-1)];
            flow2=[obj.flowPostSwitch(2,n-1) obj.flowPostSwitch(2,n-1)];
            if n==length(timeVector)
                lStyle='--';
            else
                lStyle='-';
            end
            if flow1(1)==flow2(1)
                plot(times,flow1,'color','m','Linestyle',lStyle);
            else
                plot(times, flow1,'color','b','Linestyle',lStyle);
                plot(times, flow2,'color','r','Linestyle',lStyle);  
            end
        end

        
        l={['Pump1: ' obj.pumps{1}.contents] ['Pump2: ' obj.pumps{2}.contents]};
        legend(l,'Location','NorthOutside');
    
        
        end
    end
    methods (Static)
        function outString = makeString(numbers)
            %Function to format vectors and matrices for writing to file
            try 
                outString=num2str(numbers,'%g,');
                outString=strrep(outString,' ','');
                if strcmp(outString(end),',')
                    outString=outString(1:end-1);
                end
            catch error
                numbers=numbers';
                outString=num2str(numbers,'%g,');
                outString=strrep(outString,' ','');
                if strcmp(outString(end),',')
                    outString=outString(1:end-1);
                end
            end
        end
    end
    
    
    
end