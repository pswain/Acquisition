function figTitle=setCamMode(obj, mode,figTitle,EMgain)
global mmc
switch (obj.Name)
    case 'Batman'
        switch mode
            case 1
                mmc.setProperty ('Evolve','Port','Multiplication Gain');
                mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
            case 3
                mmc.setProperty ('Evolve','Port','Multiplication Gain');
                mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
            case 2
                mmc.setProperty ('Evolve','Port','Normal');
                figTitle=strcat(figTitle,'. CCD');
        end
        mmc.waitForDevice('Evolve');
    case 'Batgirl'
        switch mode
            case 1
                mmc.setProperty ('Evolve','Port','Multiplication Gain');
                mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
            case 3
                mmc.setProperty ('Evolve','Port','Multiplication Gain');
                mmc.setProperty ('Evolve','MultiplierGain',num2str(EMgain));
                figTitle=strcat(figTitle,'. EMCCD, gain:',num2str(EMgain));
            case 2
                mmc.setProperty ('Evolve','Port','Normal');
                figTitle=strcat(figTitle,'. CCD');
        end
        mmc.waitForDevice('Evolve');
end
end