classdef switches
   properties
      times%double vector, times at which switch should occur
      initialPump%intgeger, The number of the dominant pump at the start of the experiment
      switched%logical vector, indicates if each switch has occurred
      switchedTo%double vector, number of the pump that has the faster pumping rate after each switch
      switchedFrom%double vector, number of the pump that has the slower pumping rate after each switch
      switchedToContents%string, contents of the pump to switch to
      switchedFromContents%string, contents of the pump to switch to
      switchTimes%double vector, record of the times at which each switch event has occurred
      flowPostSwitch%2xnumber of switches double array, Flow rates of each pump after switching
      switchParams%structure, with the parameters governing switching
      numSwitches%number of switching events
      pumpNames%Micromanager config device names for each pump in a cell array of strings
   end
   
   methods
       function obj=switches(switchedToContents, switchedFromContents)
          obj.switchedToContents=switchedToContents;
          obj.switchedFromContents=switchedFromContents;
          
          %Default parameters
          obj.times=0;
          obj.initialPump=1;
          obj.switchParams.withdrawVol=50;%vol in microlitres
          obj.switched=true;
          obj.switchedTo=2;
          obj.switchedFrom=1;
          obj.numSwitches=0;
          obj.switchTimes=zeros(1,obj.numSwitches);
          obj.flowPostSwitch=[.4 ; 4];%flow rates in microlitres/min
          obj.pumpNames={'Aladdin';'Aladdin2'};
          
          %Define default switching parameters
          obj.switchParams.withdrawVol=50;%vol in microlitres
          obj.switchParams.rate=100;%rate of pumping during switching in microlitres/min

       end
       
       function obj=setTimes(obj, times,highFlow, lowFlow, initialPump)
           %Generates switching parameters from input times
           obj.initialPump=initialPump;
           obj.numSwitches=length(times);
           obj.times=times;
           obj.switched=false(1,obj.numSwitches);
           obj.flowPostSwitch=repmat([highFlow;lowFlow],1,obj.numSwitches);
           obj.switchTimes=zeros(1,obj.numSwitches);        
           
       end
       
       function obj=setPeriodic(obj,switchInterval,switchStart,switchStop,highFlow,lowFlow)
           %Generates periodic switching parameters
           obj.numSwitches=floor((switchStop-switchStart)/switchInterval);
           obj.times=switchStart:switchInterval:switchStop;            
           obj.switched=false(1,obj.numSwitches);
           obj.flowPostSwitch=repmat([highFlow;lowFlow],1,obj.numSwitches);
           obj.switchTimes=zeros(1,obj.numSwitches);          
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
          if currTime>=nextSwitchTime
             %If statement here - is this a switching experiment - if not
             %change pump flow rates without infusion/withdrawal step.
             logstring=['Switching pumps at ',datestr(clock) '. Fast infusion/withdrawal step: Rate=' num2str(obj.switchParams.rate) '. Volume=' num2str(obj.switchParams.withdrawVol)];acqData.logtext=writelog(logfile,'',logstring);
             
             %Fast pump/withdraw phase to remove hysteresis
             mmc.setProperty((obj.pumpNames{obj.switchedTo}),'Direction','Infuse');
             mmc.setProperty((obj.pumpNames{obj.switchedTo}),'FlowRate-uL/min',num2str(obj.switchParams.rate));
             mmc.setProperty((obj.pumpNames{obj.switchedTo}),'Volume-uL',num2str(obj.switchParams.withdrawVol));

             mmc.setProperty((obj.pumpNames{obj.switchedFrom}),'Direction','Withdraw');
             mmc.setProperty((obj.pumpNames{obj.switchedFrom}),'FlowRate-uL/min',num2str(obj.switchParams.rate));
             mmc.setProperty((obj.pumpNames{obj.switchedFrom}),'Volume-uL',num2str(obj.switchParams.withdrawVol));
             
             mmc.setProperty((obj.pumpNames{obj.switchedFrom}),'Run','1');
             mmc.setProperty((obj.pumpNames{obj.switchedTo}),'Run','1');
             
             %Then reset pump flow rates and volumes
             mmc.setProperty((obj.pumpNames{obj.switchedTo}),'FlowRate-uL/min',num2str(obj.flowPostSwitch(2)));
             mmc.setProperty((obj.pumpNames{obj.switchedFrom}),'FlowRate-uL/min',num2str(obj.flowPostSwitch(1)));         
             mmc.setProperty((obj.pumpNames{obj.switchedTo}),'Volume-uL',num2str(0));%Zero volume = pump indefinitely
             mmc.setProperty((obj.pumpNames{obj.switchedFrom}),'Volume-uL',num2str(0));%Zero volume = pump indefinitely          
             mmc.setProperty((obj.pumpNames{obj.switchedFrom}),'Direction','Infuse');
             
             logstring=strcat('Pump switch complete at: ',datestr(clock));acqData.logtext=writelog(logfile,'',logstring);
             logstring=['Dominant pump is now: ' obj.pumpNames{obj.swithchedTo} ' pumping at ' num2str(obj.flowPostSwitch(2)) 'ul/min'];acqData.logtext=writelog(logfile,'',logstring);
             logstring=['Dominant medium is now: ' obj.swithchedToContents];acqData.logtext=writelog(logfile,'',logstring);
             logstring=['Pump ' obj.pumpNames{obj.swithchedFrom} 'is pumping at ' num2str(obj.flowPostSwitch(1)) 'ul/min'];acqData.logtext=writelog(logfile,'',logstring);

             
             %Swap the pumps to be switched to and from at the next switch
             oldSwitchedTo=obj.switchedTo;
             oldSwitchedToContents=obj.switchedToContents;
             obj.switchedTo=obj.switchedFrom;
             obj.switchedToContents=obj.switchedFromContents;
             obj.switchedFrom=oldSwitchedTo;
             obj.switchedFromContents=oldSwitchedToContents;
          end
          
       end
       
       function obj=setSwitchParams(obj)
          %runs user dialogue to determine the parameters for switching.
          defaults={'50','10'};
          answers=inputdlg({'Volume for fast pumping stage of switch (ul)','Flow rate for fast pumping stage of switch (ul/min)'},'Switching parameters',1,defaults);
          obj.switchParams.withdrawVol=str2num(answers{1});
          obj.switchParams.rate=str2num(answers{2});
           
       end
       
      
       
       
   end
    
    
    
end