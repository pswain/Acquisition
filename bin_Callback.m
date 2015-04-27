function bin_Callback (hObject, eventdata, handles)
%Callback for user setting the camera bin

% Hints: get(hObject,'String') returns contents of voltCh1 as text
%        str2double(get(hObject,'String')) returns contents of voltCh1 as a double
menu=get(hObject,'String');
bin=menu{get(hObject,'Value')};
handles.acquisition.imagesize=handles.acquisition.microscope.getImageSize(bin);
imSizeString=[num2str(handles.acquisition.imagesize(1)) 'x' num2str(handles.acquisition.imagesize(2))];
set(handles.imagesize,'String', imSizeString);

handles.acquisition.microscope.setBin(bin);


guidata(hObject,handles);