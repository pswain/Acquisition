function starttpChannel_Callback(hObject, eventdata)
%Sets the starting timepoint for the appropriate channel - there will be no
%imaging before this timepoint.

handles=guidata(hObject);
starttp=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
callingTag=get(hObject,'Tag');
%Get the name of the channel
[channelName tagEnd]=getChannel(hObject,handles);
if isempty(get(hObject,'String'))~=1;
    for n=1:sizeChannels(1)
        if strcmp(char(handles.acquisition.channels(n,1)),channelName)==1
            handles.acquisition.channels(n,5)=num2cell(starttp);
        end
    end
else
    set(handles.starttpCh1,'String','1');
    for n=1:sizeChannels(1)
        if strcmp(char(handles.acquisition.channels(n,1)),channelName)==1
            handles.acquisition.channels(n,5)=num2cell(1);
        end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles)