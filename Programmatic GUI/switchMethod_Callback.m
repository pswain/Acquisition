function switchMethod_Callback(hObject, eventdata)
%

handles=guidata(hObject);
contents=get(hObject,'String');
choice=contents{get(hObject,'Value')};
dispFlowChanges=true;
switch choice
    case 'Enter switch times'
        %Define a variable to check if inputs are OK
        problem=false;
        %Define default values (based on contents of the switching object)
        %Times (as comma, separated string)
        defaults{1}=commaString(handles.acquisition.flow{5}.times);
        %Initially-dominant pump
        defaults{2}=num2str(handles.acquisition.flow{5}.initialPump);
        %Post-switch flow rates
        %Pump to switch to is the highest flow rate between the first two
        %entries in switches.flowPostSwitch
        defaults{3}=num2str(max(handles.acquisition.flow{5}.flowPostSwitch(:,1)));
        defaults{4}=num2str(min(handles.acquisition.flow{5}.flowPostSwitch(:,1)));
        %Get user input
        answers=inputdlg({'Enter switching times in min after start of timelapse (separated by commas): ','Which pump has the higher flow rate initially?','Enter flow rates (after switching) of pump to switch to (in ul/min, separated by commas)','Enter flow rates (after switching) of pump to switch from (in ul/min, separated by commas)'},'Switching parameters',1,defaults);
        %Process switching times
        times=answers{1};
        %CONVERT TO VECTOR OF DOUBLES
        txtTimes=textscan(times,'%f','Delimiter',',');
        txtTimes=cell2mat(txtTimes);
        regTimes=regexp(times,[','],'Split');
        %Initial pump
        initialPump=answers{2};
        initialPump=str2num(initialPump);
        if isempty(initialPump)
            problem=true;
            errorMessage='Initial pump must be either 1 or 2';
        else
            if ~(initialPump==2||initialPump==1)
                problem=true;
                errorMessage='Initial pump must be either 1 or 2';
            end
        end
        
        
        %Flow rates
        hFlw=answers{3};
        highFlow=textscan(hFlw,'%f','Delimiter',',');
        highFlow=cell2mat(highFlow)';
        lFlw=answers{4};
        lowFlow=textscan(lFlw,'%f','Delimiter',',');
        lowFlow=cell2mat(lowFlow)';
        if ~any(isnan([highFlow lowFlow]))
            if length(txtTimes)==length(regTimes)
                flowRates=[highFlow; lowFlow];
                if size(flowRates,2)==1
                    %A single pair of flow rates has been entered -
                    %alternate these at each switch
                    ind=logical(mod(1:length(txtTimes),2));%Logical index to the odd number entries (entry 1, 3, 5 etc).
                    oldFlow=flowRates;
                    flowRates=repmat(flowRates,1,length(txtTimes));
                    %Now all entries are the same - first flow input
                    %followed by second. Swap the even entries
                    
                    if initialPump==1
                        flowRates(1,ind)=oldFlow(2);%The lower flow rate - for times 1, 3, 5 etc.
                        flowRates(1,logical(1-ind))=oldFlow(1);%The higher flow rate - for times 2, 4, 6 etc.
                        flowRates(2,ind)=oldFlow(1);%The higher flow rate - for times 1, 3, 5 etc
                        flowRates(2,logical(1-ind))=oldFlow(2);%The lower flow rate - for times 2, 4, 6 etc
                        
                    else
                        %Pump 2 is dominant at the start of the experiment
                        %- 1st switch is to pump 1 - so that has the higher
                        %rate after the odd numbered switches.
                        flowRates(1,ind)=oldFlow(1);%The higher flow rate - for switches 1, 3, 5 etc.
                        flowRates(1,logical(1-ind))=oldFlow(2);%The lower flow rate - for times 2, 4, 6 etc.
                        flowRates(2,ind)=oldFlow(2);%The lower flow rate - for times 1, 3, 5 etc
                        flowRates(2,logical(1-ind))=oldFlow(1);%The higher flow rate - for times 2, 4, 6 etc
                        
                    end
                end
                if ~problem
                    handles.acquisition.flow{5}=handles.acquisition.flow{5}.setSwitchTimes(txtTimes,flowRates,initialPump);
                end
            else
                problem=true;
                errorMessage='Answer contains invalid times';
            end
        else
            problem=true;
            errorMessage='Answer contains invalid times';
        end
        if problem
            errordlg(errorMessage);
        end
    case 'Periodic'
        defaults={'30','0',num2str(handles.acquisition.time(4)/60),'4','.4'};
        input = inputdlg({'Switch the flow every....min','Start switching at ... min','Stop switching at ... min','Flow rate of dominant pump (ul/min)','Flow rate of non-dominant pump (ul/min)'},'Periodic switching',1,defaults);
        interval=input{1};
        switchInterval=str2double(interval);
        switchStart=str2double(input{2});
        switchStop=str2double(input{3});
        highFlow=str2double(input{4});
        lowFlow=str2double(input{5});
        if ~any(isnan([switchInterval switchStart switchStop highFlow lowFlow]))
            handles.acquisition.flow{5}=handles.acquisition.flow{5}.setPeriodic(switchInterval,switchStart,switchStop,highFlow, lowFlow);
        else
            errordlg('All inputs must be numbers');
        end
        handles.period=switchInterval;
        
    case 'Linear Ramp'
        defaults={'1',num2str(handles.acquisition.time(4)/60),'4','.4','1','2'};
        input = inputdlg({'Start ramp at....min','End ramp at... min','Flow rate at high end of ramp (ul/min)','Flow rate at low end of ramp (ul/min)','Starting Pump High','Ending Pump High'},'Create linear flow ramp',1,defaults);
        rampStart=str2double(input{1});
        rampStop=str2double(input{2});
        highFlow=str2double(input{3});
        lowFlow=str2double(input{4});
        startPump=str2double(input{5});
        endPump=str2double(input{6});
        handles.acquisition.flow{5}=handles.acquisition.flow{5}.makeLinearRamp(rampStart,rampStop,highFlow,lowFlow,startPump,endPump);
        
    case 'Design flow transition'
        d=transitionGUI;
        % handles.acquisition.flow{5}.times=d(:,1);
        % handles.acquisition.flow{5}.flowPostSwitch=d(:,[2 3]);
        handles.acquisition.flow{5}=handles.acquisition.flow{5}.setFlowTimes(d(:,1)', d(:,[2 3])');
        handles.acquisition.flow{5}.switchedTo=0;
        handles.acquisition.flow{5}.switchedFrom=0;
        
        
    case 'Enter times'
        if handles.acquisition.flow{5}.times==0
            defaults={'0', '4', '.4'};
        else
            timeString='';
            pump1String='';
            pump2String='';
            for n=1:length(handles.acquisition.flow{5}.times)
                thisTimeString=num2str(handles.acquisition.flow{5}.times(n));%String made from the time entry
                charsT=length(thisTimeString);%Number of characters in the time entry for this change
                thisP1String=num2str(handles.acquisition.flow{5}.flowPostSwitch(1,n));
                charsP1=length(thisP1String);
                thisP2String=num2str(handles.acquisition.flow{5}.flowPostSwitch(2,n));
                charsP2=length(thisP2String);
                if n<length(handles.acquisition.flow{5}.times)
                    timeString(length(timeString)+1:length(timeString)+1+charsT)=[thisTimeString ','];
                    
                    pump1String(length(pump1String)+1:length(pump1String)+1+charsP1)=[thisP1String ','];
                    pump2String(length(pump2String)+1:length(pump2String)+1+charsP2)=[thisP2String ','];
                    
                else%This is the last change - don't add a comma
                    timeString(length(timeString)+1:length(timeString)+charsT)=thisTimeString;
                    pump1String(length(pump1String)+1:length(pump1String)+charsP1)=thisP1String;
                    pump2String(length(pump2String)+1:length(pump2String)+charsP2)=thisP2String;
                    
                end
            end
            defaults={timeString,pump1String,pump2String};
        end
        answers=inputdlg({'Enter flow times in min after start of timelapse (separated by commas): ','Enter flow rates of pump 1 (in ul/min, separated by commas)','Enter flow rates of pump 2 (in ul/min, separated by commas)'},'Flow parameters',1,defaults);
        times=answers{1};
        %CONVERT TO VECTOR OF DOUBLES
        txtTimes=textscan(times,'%f','Delimiter',',');
        txtTimes=cell2mat(txtTimes);
        regTimes=regexp(times,[','],'Split');
        %Flow rates
        hFlw=answers{2};
        pump1flow=textscan(hFlw,'%f','Delimiter',',');
        pump1flow=cell2mat(pump1flow)';
        lFlw=answers{3};
        pump2flow=textscan(lFlw,'%f','Delimiter',',');
        pump2flow=cell2mat(pump2flow)';
        if ~any(isnan([pump1flow pump2flow]))
            if length(txtTimes)==length(regTimes)
                flowRates=[pump1flow; pump2flow];
                if size(flowRates,2)==1
                    flowRates=repmat(flowRates,1,length(txtTimes));
                end
                handles.acquisition.flow{5}=handles.acquisition.flow{5}.setFlowTimes(txtTimes,flowRates);
            else
                errordlg('Answer contains invalid times');
            end
        else
            errordlg('Answer contains invalid times');
        end
    case 'Switch Pinch Valves'
        if isempty(handles.acquisition.flow{5}.solenoidGUI)

            handles.acquisition.flow{5}.solenoidGUI=solenoidValveGUI(handles.acquisition.microscope.pinchComPort);
        end
        guidata(hObject, handles);

        if true %handles.acquisition.flow{5}.times==0
            defaults={'0', '4', '.4',''};
            defaults={'0', '4', '.4','0'};

        else
            timeString='';
            pump1String='';
            pump2String='';
            for n=1:length(handles.acquisition.flow{5}.times)
                thisTimeString=num2str(handles.acquisition.flow{5}.times(n));%String made from the time entry
                charsT=length(thisTimeString);%Number of characters in the time entry for this change
                thisP1String=num2str(handles.acquisition.flow{5}.flowPostSwitch(1,n));
                charsP1=length(thisP1String);
                thisP2String=num2str(handles.acquisition.flow{5}.flowPostSwitch(2,n));
                charsP2=length(thisP2String);
                if n<length(handles.acquisition.flow{5}.times)
                    timeString(length(timeString)+1:length(timeString)+1+charsT)=[thisTimeString ','];
                    
                    pump1String(length(pump1String)+1:length(pump1String)+1+charsP1)=[thisP1String ','];
                    pump2String(length(pump2String)+1:length(pump2String)+1+charsP2)=[thisP2String ','];
                    
                else%This is the last change - don't add a comma
                    timeString(length(timeString)+1:length(timeString)+charsT)=thisTimeString;
                    pump1String(length(pump1String)+1:length(pump1String)+charsP1)=thisP1String;
                    pump2String(length(pump2String)+1:length(pump2String)+charsP2)=thisP2String;
                    
                end
            end
            defaults={timeString,pump1String,pump2String};
        end
        answers=inputdlg({'Enter flow times in min after start of timelapse (separated by commas): ','Enter flow rates of pump 1 (in ul/min, separated by commas)','Enter flow rates of pump 2 (in ul/min, separated by commas)',...
            'Enter times for all solenoid valves to switch'},'Flow parameters',1,defaults);
        times=answers{1};
        %CONVERT TO VECTOR OF DOUBLES
        txtTimes=textscan(times,'%f','Delimiter',',');
        txtTimes=cell2mat(txtTimes);
        regTimes=regexp(times,[','],'Split');
        %Flow rates
        hFlw=answers{2};
        pump1flow=textscan(hFlw,'%f','Delimiter',',');
        pump1flow=cell2mat(pump1flow)';
        lFlw=answers{3};
        pump2flow=textscan(lFlw,'%f','Delimiter',',');
        pump2flow=cell2mat(pump2flow)';
        solSwT=answers{4};
        solSwitchTimes=textscan(solSwT,'%f','Delimiter',',');
        solSwitchTimes=cell2mat(solSwitchTimes)';

        if ~any(isnan([pump1flow pump2flow]))
            if length(txtTimes)==length(regTimes)
                flowRates=[pump1flow; pump2flow];
                if size(flowRates,2)==1
                    flowRates=repmat(flowRates,1,length(txtTimes));
                end
                handles.acquisition.flow{5}=handles.acquisition.flow{5}.setFlowTimes(txtTimes,flowRates,solSwitchTimes);
            else
                errordlg('Answer contains invalid times');
            end
        else
            errordlg('Answer contains invalid times');
        end
        dispFlowChanges=false;

end

if dispFlowChanges
    handles.acquisition.flow{5}.displayFlowChanges;
end

guidata(hObject, handles)