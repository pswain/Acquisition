%Decides root folder to save files in based on name of user
function [root name]=makeRoot(name,microscope)
today=date;
if isempty(name)
    name='Ivan';
end

switch name
    case 'v1iclar2'
        name='Ivan';
    case 'mcrane2'
        name='Matt';
    case 's0880566'
        name='Bruno';
    case {'s1135844','ElcoAcquisition'}
        name='Elco';
    case 's1259407'
        name='Luis';
    case 'v1agrana'
        name='Alejandro';
    case 's1476779'
        name='Andy';
    case 'v1jtraet'
        name='Joleen';
    case 'v1slamai'
        name='Sebastien';
    case 's1403943'
        name='Naimah';
    case 'jpietsch'
        name='Julian';
    case 'v1lregan'
        name='Lynne';
    case 's1636227'
        name='Manuel';
    case 'lbandier'
        name='Lucia';
    case 'ifarquha'
        name='Ish';
    case 's1578730'
        name='Nahuel';
                
end
[swain tyers millar]=getUsers;
testSwain=strcmp(name,swain);
testTyers=strcmp(name,tyers);
testMillar=strcmp(name,millar);
isSwain=any(testSwain);
isTyers=any(testTyers);
isMillar=any(testMillar);
if isSwain==1
    lab=[microscope.DataPath filesep 'Swain Lab/'];
stringtoadd='/RAW DATA/';
end

if isMillar==1
    lab=[microscope.DataPath filesep 'Millar/'];
    stringtoadd='/RAW DATA/';
end

if isTyers==1
    lab=[microscope.DataPath filesep 'Tyers Lab/'];
    stringtoadd='/RAW DATA/';
end

% if name == 'Sebastien'
%     lab = 'E:/';
% end
root=strcat(lab,name,stringtoadd,today(8:11),'/',today(4:6),'/', date);