function [channel tagEnd]=getChannel(hObject,handles)
%Used by any channel control to return the name of the channel and the
%string 'tagEnd', which is 'Ch' plus the number of the channel - eg
%'Ch1', 'Ch2' etc. This is part of the tags for all controls affecting
%channels, eg 'useCh1', 'zSectCh4' etc.

tag=get(hObject,'Tag');
tagEnd=['Ch' tag(end)];
useTag=['useCh' tag(end)];

channel=get(handles.(useTag),'String');
