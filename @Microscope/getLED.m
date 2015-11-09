function LED=getLED (obj)
%returns a string defining the currently-selected LED. Used by setLEDVoltage
global mmc;
switch obj.Name
    case 'Batman'
        dac=mmc.getProperty('DTOL-Switch','State');
        switch(str2num(dac))
            case 1
                LED='DAC0';
            case 2%The CFP LED - adjust DAC-1
                LED='DAC1';
            case 4%The GFP/YFP LED - adjust DAC-1
                LED='DAC2';
            case 8%The mCherry/cy5/tdTomato LED - adjust DAC-1
                LED='DAC3';
        end
    case 'Batgirl'
        %Edit the next line if we get digital control to work
        %with the CairnIO device (USB3103)
        digiNames={'Direct Digital Out_P0.0';'Direct Digital Out_P0.1';'Direct Digital Out_P1.0';'Direct Digital Out_P1.1';'Direct Digital Out_P1.2';'Direct Digital Out_P1.3'};
        for n=1:length(digiNames)
            isThisOne=strcmp('1',mmc.getProperty('CairnNI6008',digiNames{n}));
            if isThisOne
                LED=digiNames{n};
            end
        end
    case 'Robin'
        LED=[];
end

end