function [device voltProp]=getLEDVoltProp(obj,LED)
%Returns the micromanager device name and property defining the voltage for
%the input LED. The LED name is the property controlling it
%digitally (ie switching it on and off)
switch obj.Name
    case 'Batman'
        voltProp='Volts';
        switch LED
            case 'DAC0'
                device='';%The DTOL-DAC-0 property is used for the PIFOC. Bright field LED voltage can't be adjusted
            case 'DAC1'
                device='DTOL-DAC-1';
            case 'DAC2'
                device='DTOL-DAC-2';
            case 'DAC3'
                device='DTOL-DAC-3';
        end
        
    case 'Robin'
        %LED voltages cannot be set programatically on Robin.
        device='';
        voltProp='';
    case 'Batgirl'
        device='CairnIO';
        switch LED
            case 'Direct Digital Out_P1.0'
                voltProp='Direct Analog Out 0';
            case 'Direct Digital Out_P1.1'
                voltProp='Direct Analog Out 1';
            case 'Direct Digital Out_P1.2'
                voltProp='Direct Analog Out 2';
            case 'Direct Digital Out_P1.3'
                voltProp='Direct Analog Out 3';
        end
        
end
end