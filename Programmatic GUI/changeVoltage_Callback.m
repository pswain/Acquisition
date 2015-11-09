function changeVoltage_Callback(hObject, eventdata)
%Callback for all edit boxes changing the voltage applied across the
%relevant LED for a channel.

handles=guidata(hObject);


[chanName tagEnd]=getChannel(hObject,handles);
tag=get(hObject,'tag');
%Find which row represents the current channel
%cell array
channelRow=strcmp(handles.acquisition.channels,chanName);
channelRow=channelRow(:,1);
%Get the old value for the voltage - can then reset if the input is not
%usable
oldValue=handles.acquisition.channels{channelRow,8};
%Get the input value
input=get(hObject,'String');
input=str2num(input);
%Following code checks values are in range
%Could make this more sophisticated by defining the overload points of all
%LEDs and using a Microscope method to return limits for each channel.
switch handles.acquisition.microscope.Name
    case 'Batman'
        upLimit=4;
        lowLimit=0;
    case 'Batgirl'
        upLimit=100;
        lowLimit=0;
end
ok=false;
if ~isempty(input)
    if input>lowLimit && input<=upLimit
        ok=true;
        handles.acquisition.channels{channelRow,8}=input;
    end
end
if ~ok
    set(handles.(tag),'String', num2str(oldValue));
end

guidata(hObject, handles)