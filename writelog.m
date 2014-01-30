function [texthandle]=writelog(logfile,texthandle,logstring)

 fprintf(logfile,'%s',logstring);
 fprintf(logfile,'\r\n');
 %THE FOLLOWING LINES SLOW DOWN THE SOFTWARE PROGRESSIVELY - NEED TO REMOVE
% existing=get(texthandle,'String');
% set(texthandle,'String',[{logstring};existing]);

disp(logstring);