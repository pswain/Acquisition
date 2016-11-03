function snap_Callback(hObject, eventdata)
%Snaps an image or stack using the settings of the channel associated with the
%calling button. This callback is used for all channels.

handles=guidata(hObject);
channel={};
tag=get(hObject,'Tag');
chNum=tag(end);
useTag=['useCh' num2str(chNum)];
expTag=['expCh' num2str(chNum)];
cammodeTag=['cammodeCh' num2str(chNum)];
startGainTag=['startgainCh' num2str(chNum)];
voltTag=['voltCh' num2str(chNum)];
ZsectTag=['ZsectCh' num2str(chNum)];
%Get all channel settings from the gui controls
channel(1)=cellstr(get(handles.(useTag),'String'));
channel(2)=num2cell(str2double(get(handles.(expTag),'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(get(handles.(ZsectTag),'Value'));
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.(cammodeTag),'Value'));
channel(7)=num2cell(str2double(get(handles.(startGainTag),'String')));
channel(8)=num2cell(str2double(get(handles.(voltTag),'String')));
%Snap a stack or single image, depending on whether z stack is selected
if channel{4}==0
    snap(channel, handles.acquisition.microscope);
else
    [imageStack]=snapStack(channel, handles);
end
set(hObject,'Value',0);

guidata(hObject, handles)