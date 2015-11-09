function startgainChannel_Callback(hObject, eventdata)
%Sets the gain to be used at the start of acquisition for a channel using
%the EM camera mode. This callback used by the startgain controls for all
%channels

handles=guidata(hObject);
[chName tagEnd]=getChannel(hObject,handles);

startgain=str2double(get(hObject,'String'));
nChannels=size(handles.acquisition.channels,1);
%loop to find this channel in the channels array
if nChannels~=0
    for n=1:nChannels
        if strcmp(handles.acquisition.channels(n,1),chName)==1
            handles.acquisition.channels{n,7}=startgain;
        end
    end
end

guidata(hObject, handles)