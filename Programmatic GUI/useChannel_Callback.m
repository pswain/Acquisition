function useChannel_Callback(hObject, eventdata)
%Selects or deselects a channel for use in the experiment. This callback is
%used by all of the use channel buttons.

handles=guidata(hObject);

%First determine which button has been clicked

[chName tagEnd]=getChannel(hObject,handles);

sizeChannels=size(handles.acquisition.channels);
nChannels=sizeChannels(1);
if get(hObject,'Value')==1
    if get(handles.(['Zsect' tagEnd]),'Value')==1
        set(handles.nZsections,'Enable','on');
        set(handles.zspacing,'Enable','on');
    end
    set(handles.(['skip' tagEnd]),'Enable','on');
    set(handles.(['Zsect' tagEnd]),'Enable','on');
    set(handles.(['starttp' tagEnd]),'Enable','on');
    set(handles.(['snap' tagEnd]),'Enable','on');
    set(handles.(['skip' tagEnd]),'Enable','on');
    
    switch handles.acquisition.microscope.Name

        case {'Batman' , 'Batgirl'}
            set(handles.(['cammode' tagEnd]),'Enable','on');
            set(handles.(['volt' tagEnd]),'Enable','on');
        case 'Robin'
    end
    %camera settings - enable controls
    set(handles.(['cammode' tagEnd]),'Enable','on');%%%%%
    if get(handles.(['cammode' tagEnd]),'Value')==1%channel set to camera EM mode
        set (handles.(['startgain' tagEnd]),'Enable','on');%%%%%
        set (handles.(['volt' tagEnd]),'Enable','on');%%%%%
    end   %%%%%
    set(handles.(['exp' tagEnd]),'Enable','on');
    %initialise channels entry
    handles.acquisition.channels{nChannels+1,1}=chName;
    handles.acquisition.channels{nChannels+1,2}=str2double(get(handles.(['exp' tagEnd]),'String'));
    handles.acquisition.channels{nChannels+1,3}=str2double(get(handles.(['skip' tagEnd]),'String'));
    handles.acquisition.channels{nChannels+1,4}=get(handles.(['Zsect' tagEnd]),'Value');
    handles.acquisition.channels{nChannels+1,5}=str2double(get(handles.(['starttp' tagEnd]),'String'));
    %camera settings
    handles.acquisition.channels{nChannels+1,6}=get(handles.(['cammode' tagEnd]),'Value');
    handles.acquisition.channels{nChannels+1,7}=str2double(get(handles.(['startgain' tagEnd]),'String'));%%%%%
    if isempty(handles.acquisition.channels(nChannels+1,7))%%%%%
        handles.acquisition.channels(nChannels+1,7)=270;%default value if there is no valid number in there
    end%
    handles.acquisition.channels(nChannels+1,8)=num2cell(str2double(get(handles.(['volt' tagEnd]),'String')));
    %update the points list (if there is one) - add a column for exposure times for this channel
    if size(handles.acquisition.points,1)>0
        handles=updatePoints(handles);
    end
else%this channel has been deselected
    set(handles.(['exp' tagEnd]),'Enable','off');
    set(handles.(['skip' tagEnd]),'Enable','off');
    set(handles.(['Zsect' tagEnd]),'Enable','off');
    set(handles.(['starttp' tagEnd]),'Enable','off');
    set(handles.(['snap' tagEnd]),'Enable','off');
    set(handles.(['cammode' tagEnd]),'Enable','off');
    set(handles.(['startgain' tagEnd]),'Enable','off')
    set(handles.(['volt' tagEnd]),'Enable','off');
    sizeChannels=size(handles.acquisition.channels);
    if sizeChannels(1)~=0
        anyZ=0;
        for n=1:sizeChannels(1)%loop to find this channel and delete it
            if strcmp(char(handles.acquisition.channels(n,1)),chName)==1
                delnumber=n;%mark this channel for deletion
            else%only check if the channel does z sectioning if it's not about to be removed.
                zChoice=cell2mat(handles.acquisition.channels(n,4));
                if zChoice==1;
                    anyZ=1;
                end
            end
        end
        if size(handles.acquisition.points,1)>0
            handles=updatePoints(handles,delnumber);%update the points list - remove the relevant column of exposure times
        end
        handles.acquisition.channels(delnumber,:)=[];
        if anyZ==0
            set(handles.nZsections,'Enable','off');
            set(handles.zspacing,'Enable','off');
        end
    end
end
updateDiskSpace(handles);
guidata(hObject, handles)