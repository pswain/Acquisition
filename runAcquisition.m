function []=runAcquisition(acqData)
global mmc;

%Run initialize files script - opens directories for saving data and log file
%also saves acquisition settings
[logfile,exptFolder,posDirectories]=initializeFiles(acqData);


    %Microscope initialization script
    initializeScope;

    %Is the PFS on - affects a lot of the z sectioning processes later on - add
    %this info to acqData and record initial (reference) position of the Z
    %drive

    if strcmp('Locked',mmc.getProperty('TIPFSStatus','Status'))==1
        acqData.z(3)=1;
        fprintf(logfile,'%s','PFS is locked');
        fprintf(logfile,'\r\n');
    else
        acqData.z(3)=0;
        status=mmc.getProperty('TIPFSStatus','Status');
        fprintf(logfile,'%s',strcat('PFS status:',char(status),'- will not be used'));
        fprintf(logfile,'\r\n');

    end

    %Do any channels do z sectioning - affects a lot of how things run so
    %recorded now to make it easier to keep track

    zsections=vertcat(acqData.channels{:,4});
    acqData.z(4)=any(zsections);

    % %Create text box to display log information:
    % acqData.logfig = figure('units','pixels',...
    %               'position',[40 40 500 940],...
    %               'menubar','none',...
    %               'resize','off',...
    %               'numbertitle','off',...
    %               'name','Acquisition running');
    % acqData.logtext = uicontrol('style','edit',...
    %                  'units','pix',...
    %                  'position',[10 60 480 830],...
    %                  'backgroundcolor','w',...
    %                  'HorizontalAlign','left',...
    %                  'min',0,'max',10,...
    %                  'enable','inactive');
    %Now to add a line to the text do this:
    %existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{'your string here'};existing]);
    disp('Acquisition in progress: press ctrl+C to abort acquisition');
    %set(acqData.logtext,'String','Acquisition running...');
    % for n=1:size(acqData.channels,1)
    %     chan=acqData.channels(n,:);
    %     chantext=sprintf('%s %d %d %d %d %d %d %d' ,chan{:});
    %     existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{chantext};existing]);   
    % end
    % existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{['Z settings:' num2str(acqData.z)]};existing]);
    % existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{['Time settings:' num2str(acqData.time)]};existing]);
    % for n=1:size(acqData.points,1)
    %     point=acqData.points(n,:);
    %     formatspec='%s %d %d %d %d %d ';
    %     for specs=7:size(acqData.points,2)
    %        formatspec=strcat(formatspec,' %s '); 
    %     end
    %     pointtext=sprintf(formatspec ,point{:});
    %     existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{pointtext};existing]);   
    % end
    % existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[acqData.info{4};existing]);%comments in acqData.info
    % existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{['Saved in:' acqData.info{3}]};existing]);
    % existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{['User:' acqData.info{2}]};existing]);
    % existing=get(acqData.logtext,'String'); set(acqData.logtext,'String',[{['Experiment name:' acqData.info{1}]};existing]);
    %initialise the drift field of acqData.z - this will keep track of any
    %focus drift when the PFS is in use.
    acqData.z(5)=0;



    acqTimelapse(acqData,logfile,exptFolder,posDirectories);
%catch
 %   disp('Error in running of the experiment - may not have been completed');
%end

tempName=char(strcat(exptFolder,'/temp_InProgress.txt'));
if exist(tempName)==2;
    delete(tempName);
end
