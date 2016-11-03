function refreshPumpInfo_Callback(hObject, eventdata)

handles=guidata(gcf);
%Updates the gui controls with real information from each syringe pump.
for p=1:length(handles.acquisition.flow{4})
   [handles.acquisition.flow{4}(p) warnings]=handles.acquisition.flow{4}(p).refreshPumpDetails;
   volString=handles.acquisition.flow{4}(p).getVolString(handles.acquisition.flow{4}(p).diameter);
   set(handles.(['diameterP' num2str(p)]),'Value',find(strcmp(get(handles.(['diameterP' num2str(p)]),'String'),volString)));
   set(handles.(['flowRateP' num2str(p)]),'String',num2str(handles.acquisition.flow{4}(p).currentRate));
   set(handles.(['runP' num2str(p)]),'Value',handles.acquisition.flow{4}(p).running);
   for n=1:length(warnings)
        warndlg(warnings{n});
   end
end
disp('Completed retrieval of pump information');

end