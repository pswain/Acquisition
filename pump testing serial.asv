
pump2=serial('COM6','BaudRate',19200,'terminator','CR');

fopen(pump2)
%%
fclose(pump2)
%%
pump1=serial('COM5','BaudRate',9600,'terminator','CR');

fopen(pump1)
%%
fclose(pump1)

%%

fprintf(pump2,'STP')
%%

fprintf(pump2,'RUN')
%%
tic
fprintf(pump1,'STP');fprintf(pump2,'STP');pause(.05)
fprintf(pump1,'RAT3');fprintf(pump2,'RAT3');pause(.05)
fprintf(pump1,'VOL10');fprintf(pump2,'VOL10');pause(.05)
fprintf(pump1,'RUN');fprintf(pump2,'RUN');pause(.05)
toc
%%
fprintf(pump2,'STP');pause(.05);

fprintf(pump2,'PHN2');pause(.05);
fprintf(pump2,'FUNRAT');pause(.05);
fprintf(pump2,'RAT50');pause(.05);
fprintf(pump2,'VOL10');pause(.05);
fprintf(pump2,'DIRWDR');pause(.05);
fprintf(pump2,'PHN3');pause(.05);
fprintf(pump2,'FUNRAT');pause(.05);

fprintf(pump2,'RAT5');pause(.05);
fprintf(pump2,'VOL0');pause(.05);
fprintf(pump2,'DIRINF');pause(.05);

%%
fprintf(pump2,'DIA8.585');pause(.05);
%%
fprintf(pump2,'RAT10');pause(.05);

%%
fprintf(pump2,'RUN3');pause(.05);

pause(30);
fprintf(pump2,'RUN2');pause(.05);


%%
fprintf(pump2,'STP');pause(.05)
