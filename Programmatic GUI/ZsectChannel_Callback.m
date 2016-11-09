function ZsectChannel_Callback(hObject, eventdata)
%Callback for the checkbox defining whether a channel does Z sectioning.
%This is used by the controls for all channels

handles=guidata(hObject);
[chName tagEnd]=getChannel(hObject,handles);

if get(hObject,'Value')==1%make sure z sectioning controls are enabled
    %and record that z sectioning is being done for
    %this channel in the handles.acquisition.channels cell array
    %also get the z sectioning values from the gui
    %and copy them to the handles.acquisition.z array to be used
    set(handles.nZsections,'Enable','on');
    set(handles.zspacing,'Enable','on');
    set(handles.zMethod,'Enable','on');
    switch handles.acquisition.microscope.Name
        case 'Batman'
            set(handles.zMethod,'Enable','on');
        case 'Robin'
    end
    handles.acquisition.z(1)=str2double(get(handles.nZsections,'String'));
    handles.acquisition.z(2)=str2double(get(handles.zspacing,'String'));
    handles.acquisition.z(4)=1;
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),chName)==1
                handles.acquisition.channels(n,4)=num2cell(1);
            end
        end
    end
else%if this button has been deselected
    %record that z sectioning is not being done for this channel in the
    %handles.acquisition.channels array
    %Then check if any other channels are doing z sectioning - if not then
    %disable the z sectioning controls and set the handles.acquisition.z numbers for
    %single slice acquisition
    sizeChannels=size(handles.acquisition.channels);
    anyZ=0;
    if sizeChannels(1)~=0
        for n=1:sizeChannels(1)
            if strcmp(char(handles.acquisition.channels(n,1)),chName)==1
                handles.acquisition.channels(n,4)=num2cell(0);
            end
            if cell2mat(handles.acquisition.channels(n,4))==1
                anyZ=1;
            end
        end
    end
    if anyZ==0
        set(handles.nZsections,'Enable','off');
        set(handles.zspacing,'Enable','off');
        set(handles.zMethod,'Enable','off');
        %        set(handles.nZsections,'String','1');
        %        set(handles.zspacing,'String','0');
        handles.acquisition.z(1)=1;
        handles.acquisition.z(2)=0;
        handles.acquisition.z(4)=0;
    end
end
updateDiskSpace(handles);
guidata(hObject, handles)