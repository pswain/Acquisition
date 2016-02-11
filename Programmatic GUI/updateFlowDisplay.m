function []=updateFlowDisplay(handles)
%Updates the gui display to show the flow and pump information contained in
%handles.acquisition
for n=1:length(handles.acquisition.flow{4})
    volString=pump.getVolString(handles.acquisition.flow{4}(n).diameter);
    set (handles.(['diameterP' num2str(n)]),'Value',find(strcmp(get(handles.(['diameterP' num2str(n)]),'String'),volString)));
    set (handles.(['contentsP' num2str(n)]),'String',num2str(handles.acquisition.flow{4}(n).contents));
    set (handles.(['directionP' num2str(n)]),'Value',find(strcmp(num2str(handles.acquisition.flow{4}(n).direction),get(handles.(['directionP' num2str(n)]),'String'))));
    set (handles.(['flowRateP' num2str(n)]),'String',num2str(handles.acquisition.flow{4}(n).currentRate));
    set (handles.(['runP' num2str(n)]),'Value',handles.acquisition.flow{4}(n).running);
end
