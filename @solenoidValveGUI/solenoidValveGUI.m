classdef solenoidValveGUI<handle
    properties
        figure = [];
        
        relay0Button
        relay1Button
        relay2Button
        relay3Button
        currentGUI;

        cTimelapse=[]
        cCellVision=[];
        channel=1;
        
        relayStates=[0 0 0 0];
        solenoidPort
        
        nRelays
    end
    
    properties (SetObservable)
        ActiveContourButtonState = 1;
        
    end % properties
    %% Displays timelapse for a single trap
    %This can either dispaly the primary channel (DIC) or a secondary channel
    %that has been loaded. It uses the trap positions identified in the DIC
    %image to display either the primary or secondary information.
    methods
        function cSolenoidValveGUI=solenoidValveGUI(comPort)
            
            if nargin<1
                comPort='COM16';
            else
                comPort=['COM' num2str(comPort)];
            end
            
            cSolenoidValveGUI.solenoidPort = serial(comPort,'baudrate',9600,'Terminator','CR');
            fopen(cSolenoidValveGUI.solenoidPort);

            fprintf(cSolenoidValveGUI.solenoidPort,'reset');
            
            scrsz = get(0,'ScreenSize');
            cSolenoidValveGUI.figure=figure('MenuBar','none','CloseRequestFcn',@(src,event)figClose(cSolenoidValveGUI),'Position',[scrsz(3)/3 scrsz(4)/3 scrsz(3)/6 scrsz(4)/8]);
                        
            cSolenoidValveGUI.relay0Button = uicontrol(cSolenoidValveGUI.figure,'Style','pushbutton','String','Relay 0','BackgroundColor','red',...
                'Units','normalized','Position',[.025 .5 .65 .5],'Callback',@(src,event)toggleRelay(cSolenoidValveGUI,0));
            cSolenoidValveGUI.relay1Button = uicontrol(cSolenoidValveGUI.figure,'Style','pushbutton','String','Relay 1','BackgroundColor','red',...
                'Units','normalized','Position',[.025 .0 .65 .5],'Callback',@(src,event)toggleRelay(cSolenoidValveGUI,1));
            cSolenoidValveGUI.relay2Button = uicontrol(cSolenoidValveGUI.figure,'Style','pushbutton','String','Relay 2','BackgroundColor','red',...
                'Units','normalized','Position',[.525 .5 .65 .5],'Callback',@(src,event)toggleRelay(cSolenoidValveGUI,2));
            cSolenoidValveGUI.relay3Button = uicontrol(cSolenoidValveGUI.figure,'Style','pushbutton','String','Relay 3','BackgroundColor','red',...
                'Units','normalized','Position',[.525 .0 .65 .5],'Callback',@(src,event)toggleRelay(cSolenoidValveGUI,3));

            
        end
        
        % Other functions
        function figClose(cSolenoidValveGUI)
            % Close request function
            % to display a question dialog box
            selection = questdlg('Close This Figure?',...
                'Close Request Function',...
                'Yes','No','Yes');
            switch selection,
                case 'Yes',
                    fclose(cSolenoidValveGUI.solenoidPort);
                    delete(gcf)
                case 'No'
                    return
            end
        end
        
        function toggleRelay(cSolenoidValveGUI,relayNum)
            valveState=cSolenoidValveGUI.relayStates(relayNum+1);
            if valveState
                cmd='off';
                cSolenoidValveGUI.relayStates(relayNum+1)=0;
                colorRelay='red';
            else
                cmd='on';
                cSolenoidValveGUI.relayStates(relayNum+1)=1;
                colorRelay='green';
            end
            fprintf(cSolenoidValveGUI.solenoidPort,['relay ' cmd ' ' num2str(relayNum)]);
            switch relayNum
                case 0
                    set(cSolenoidValveGUI.relay0Button,'BackgroundColor',colorRelay)
                case 1
                    set(cSolenoidValveGUI.relay1Button,'BackgroundColor',colorRelay)
                case 2
                    set(cSolenoidValveGUI.relay2Button,'BackgroundColor',colorRelay)
                case 3
                    set(cSolenoidValveGUI.relay3Button,'BackgroundColor',colorRelay)
            end
        end
        
        function changeRelayState(cSolenoidValveGUI,relayNum, newState)
            %newState should be binary
            if newState
                cmd='on';
                cSolenoidValveGUI.relayStates(relayNum+1)=1;
                colorRelay='green';
            else
                cmd='off';
                cSolenoidValveGUI.relayStates(relayNum+1)=0;
                colorRelay='red';
            end
            fprintf(cSolenoidValveGUI.solenoidPort,['relay ' cmd ' ' num2str(relayNum)]);
            switch relayNum
                case 0
                    set(cSolenoidValveGUI.relay0Button,'BackgroundColor',colorRelay)
                case 1
                    set(cSolenoidValveGUI.relay1Button,'BackgroundColor',colorRelay)
                case 2
                    set(cSolenoidValveGUI.relay2Button,'BackgroundColor',colorRelay)
                case 3
                    set(cSolenoidValveGUI.relay3Button,'BackgroundColor',colorRelay)
            end
        end
    end
end