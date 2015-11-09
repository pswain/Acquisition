function snap_Callback(hObject, eventdata)
%Snaps an image using the settings of the channel associated with the
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

channel(1)=cellstr(get(handles.(useTag),'String'));
channel(2)=num2cell(str2double(get(handles.(expTag),'String')));
channel(3)=num2cell(1);
channel(4)=num2cell(0);
channel(5)=num2cell(0);
channel(6)=num2cell(get(handles.(cammodeTag),'Value'));
channel(7)=num2cell(str2double(get(handles.(startGainTag),'String')));
channel(8)=num2cell(str2double(get(handles.(voltTag),'String')));

snap(channel, handles.acquisition.microscope);
set(hObject,'Value',0);

guidata(hObject, handles)