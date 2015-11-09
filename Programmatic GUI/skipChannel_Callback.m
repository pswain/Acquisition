function skipChannel_Callback(hObject, eventdata)
%Defines skipping of timepoints for the current channel. This callback is
%used by the skip buttons for all channels.

handles=guidata(hObject);
[chName tagEnd]=getChannel(hObject,handles);

skip=str2double(get(hObject,'String'));
sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),chName)==1
            handles.acquisition.channels{n,3}=skip;
        end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles);

