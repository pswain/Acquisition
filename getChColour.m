function colour=getChColour(chName)
%Returns an appropriate colour array for the input channel name. White if
%channel name is unkown

colour=[1 1 1];

switch chName
    case {'DIC', 'BrightField'}
        colour=[1 1 1];
    case 'GFP'
        colour=[0.6078    0.8863    0.6745];
    case 'GFP2'
        colour=[0.5078    0.7863    0.5745];
    case 'YFP'
        colour=[1.0000    1.0000    0.8000];
    case 'CFP'
        colour=[0.6784 0.9216 1.0000];
    case 'mCherry'
        colour=[1.0000    0.6000    0.6000];
    case 'tdTomato'
        colour=[1.0000    0.6000    0.7843];
    case 'cy5'
        colour= [0.8471    0.1608         0];
    case 'GFPAutoFL'
        colour=[0.7490    0.7490         0];
    case 'dylight405'
        colour=[.5 0 .5];
    case 'pHluorin405'
        colour=[.7 0 .7];
    case 'pHluorin488'
        colour=[0.3078    0.8863    0.3745];
    case {'mKo2', 'mKO2'}
        colour=[1 .5 .2];
        
        
end