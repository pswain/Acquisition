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
        %Post-switch flow rates
        %Pump to switch to is the highest flow rate between the first two
        %entries in switches.flowPostSwitch
        flowPostSwitch = handles.acquisition.flow{5}.flowPostSwitch;
        defaults{2} = strjoin(arrayfun(@num2str,flowPostSwitch(1,:),'UniformOutput',false),',');
        defaults{3} = strjoin(arrayfun(@num2str,flowPostSwitch(2,:),'UniformOutput',false),',');
        %Get user input
        answers=inputdlg({'Enter switching times in min after start of timelapse (separated by commas): ',...
            'Enter flow rates (after switching) of PUMP 1 (in ul/min; separated by commas)',...
            'Enter flow rates (after switching) of PUMP 2 (in ul/min; separated by commas)'},...
            'Switching parameters',1,defaults);
        %Process switching times
        times=answers{1};
        %CONVERT TO VECTOR OF DOUBLES
        txtTimes=textscan(times,'%f','Delimiter',',');
        txtTimes=cell2mat(txtTimes);
        regTimes=regexp(times,[','],'Split');
                
        %Flow rates
        p1Flw=answers{2};
        p1Flow=textscan(p1Flw,'%f','Delimiter',',');
        p1Flow=cell2mat(p1Flow)';
        p2Flw=answers{3};
        p2Flow=textscan(p2Flw,'%f','Delimiter',',');
        p2Flow=cell2mat(p2Flow)';
        if ~any(isnan([p1Flow p2Flow]))
            if length(txtTimes)==length(regTimes)
                flowRates=[p1Flow; p2Flow];
                if size(flowRates,2)==1
                    %A single pair of flow rates has been entered -
                    %alternate these at each switch
                    ind=logical(mod(1:length(txtTimes),2));%Logical index to the odd number entries (entry 1, 3, 5 etc).
                    oldFlow=flowRates;
                    flowRates=repmat(flowRates,1,length(txtTimes));
                    %Now all entries are the same - first flow input
                    %followed by second. Swap the even entries
                    flowRates(1,~ind)=oldFlow(2);%The pump2 flow rate - for times 2, 4, 6 etc.
                    flowRates(2,~ind)=oldFlow(1);%The pump1 flow rate - for times 2, 4, 6 etc
                end
                if ~problem
                    handles.acquisition.flow{5}=handles.acquisition.flow{5}.setSwitchTimes(txtTimes,flowRates,handles.acquisition.flow{5}.initialPump);
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
        p2Flow=str2double(input{4});
        p1Flow=str2double(input{5});
        if ~any(isnan([switchInterval switchStart switchStop p2Flow p1Flow]))
            handles.acquisition.flow{5}=handles.acquisition.flow{5}.setPeriodic(switchInterval,switchStart,switchStop,p2Flow, p1Flow);
        else
            errordlg('All inputs must be numbers');
        end
        handles.period=switchInterval;
        
    case 'Linear Ramp'
        defaults={'1',num2str(handles.acquisition.time(4)/60),'4','.4','1','2'};
        input = inputdlg({'Start ramp at....min','End ramp at... min','Flow rate at high end of ramp (ul/min)','Flow rate at low end of ramp (ul/min)','Starting Pump High','Ending Pump High'},'Create linear flow ramp',1,defaults);
        rampStart=str2double(input{1});
        rampStop=str2double(input{2});
        p2Flow=str2double(input{3});
        p1Flow=str2double(input{4});
        startPump=str2double(input{5});
        endPump=str2double(input{6});
        handles.acquisition.flow{5}=handles.acquisition.flow{5}.makeLinearRamp(rampStart,rampStop,p2Flow,p1Flow,startPump,endPump);
        
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
        p2Flw=answers{2};
        pump1flow=textscan(p2Flw,'%f','Delimiter',',');
        pump1flow=cell2mat(pump1flow)';
        p1Flw=answers{3};
        pump2flow=textscan(p1Flw,'%f','Delimiter',',');
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
        p2Flw=answers{2};
        pump1flow=textscan(p2Flw,'%f','Delimiter',',');
        pump1flow=cell2mat(pump1flow)';
        p1Flw=answers{3};
        pump2flow=textscan(p1Flw,'%f','Delimiter',',');
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

%Set the switchParams array
%Needs to have an entry for each switch - this is to allow different
%parameters to be used for each switch if required.
%Here all entries are set to be identical - equal to the first entry in the
%existing array
withdrawVol=handles.acquisition.flow{5}.switchParams.withdrawVol(1);
rate=handles.acquisition.flow{5}.switchParams.rate(1);
handles.acquisition.flow{5}.switchParams.withdrawVol=repmat(withdrawVol,[1,length(handles.acquisition.flow{5}.times)]);
handles.acquisition.flow{5}.switchParams.rate=repmat(rate,[1,length(handles.acquisition.flow{5}.times)]);

guidata(hObject, handles)