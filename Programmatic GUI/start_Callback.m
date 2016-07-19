function start_Callback(hObject, eventdata)
%

handles=guidata(hObject);
%Before running acquisisition - simple checks - eg are there any channels,
%approx time for capturing stack will fit into time interval.
%have experiment details been entered?
if ~isempty(handles.acquisition.channels)
    sizeChannels=size(handles.acquisition.channels(:,1));
    nChannels=(sizeChannels(1));
    if nChannels==0
        warndlg('No channels are selected - try again','No channels','modal');
        return;
    end
else
    warndlg('No channels are selected - try again','No channels','modal');
    return;
end

if ~handles.descriptionWritten
   disp('Please write a description of your experiment for the log file');
   enterDetails_Callback(handles.gui);
   handles.descriptionWritten=true;
end
% 
% if ~handles.tagsChanged
%     disp('Please annotate your experiment with Omero tags');
%     OmeroTags_Callback(handles.gui);
% end

%Then - display a modal dialog box showing the experimental settings with a
%click to continue or return

handles.stop=0;
set(handles.start,'Enable','off');
set(handles.stopacq,'Enable','on');
guidata(hObject,handles);
handles.acquisition.guihandle=gco;%alllows gui to be queried during the acquisition - eg acqData.stop - has the stop button been clicked
runAcquisition(handles.acquisition);
set(handles.start,'Enable','on');
set(handles.stopacq,'Enable','off');
guidata(hObject, handles)