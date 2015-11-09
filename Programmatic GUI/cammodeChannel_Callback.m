function cammodeChannel_Callback(hObject, eventdata)
%Chooses camera mode for microscopes with Evolve EMCCD cameras. This
%callback is used by the popup menu camera mode controls for all channels

handles=guidata(hObject);
[chName tagEnd]=getChannel(hObject,handles);



value=get(hObject,'Value');
switch value
    case 1%EM_Smart mode selected
        set(handles.(['startgain' tagEnd]),'Enable','on');
        set(handles.(['volt' tagEnd]),'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
                if strcmp(handles.acquisition.channels(n,1),chName)==1
                    handles.acquisition.channels{n,6}=value;%1=EM camera mode with correction
                end
            end
        end
    case 2%CCD mode selected
        set(handles.(['startgain' tagEnd]),'Enable','off');
        set(handles.(['volt' tagEnd]),'Enable','off');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
                if strcmp(handles.acquisition.channels(n,1),chName)==1
                    handles.acquisition.channels{n,6}=2;%2=CCD camera mode
                end
            end
        end
    case 3%EM_Constant mode selected
        set(handles.(['startgain' tagEnd]),'Enable','on');
        set(handles.(['volt' tagEnd]),'Enable','on');
        nChannels=size(handles.acquisition.channels,1);
        %loop to find this channel in the channels array
        if nChannels~=0
            for n=1:nChannels
                if strcmp(handles.acquisition.channels(n,1),chName)==1
                    handles.acquisition.channels{n,6}=value;%3=EM constant
                end
            end
        end
        
end

guidata(hObject, handles)