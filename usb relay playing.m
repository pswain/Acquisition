

s = serial('COM7','baudrate',128000,'Terminator','CR');


fopen(s);

%%


fclose(s)
%%
delay=.9
for i=1:5
% command='relay off 0 ';
% fprintf(s,command);pause(delay/10);
% command='relay off 1';
% fprintf(s,command)

command='reset';
fprintf(s,command);
pause(delay)


command='relay on 0';
fprintf(s,command)
command='relay on 1';%pause(delay/3);
fprintf(s,command)

pause(delay)

command='reset';
fprintf(s,command);
% command='relay off 0';
% fprintf(s,command)
% command='relay off 1';%pause(delay/10);
% fprintf(s,command)


pause(delay)


command='relay on 0';
fprintf(s,command)
command='relay on 1';%pause(delay/3);
fprintf(s,command)
pause(delay)

end

%%

command='relay off 0';

fprintf(s,command)
pause(.05)
command='relay on 0';

fprintf(s,command)

