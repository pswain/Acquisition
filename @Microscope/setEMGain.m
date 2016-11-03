function setEMGain(obj,gain, CHsets, logfile)
%Sets the EM gain on the camera if it needs changed.
%The 3rd input (CHsets) may be used to define different gains during an
%experiment - if and when EM smart mode is revived.
if strcmp(obj.Name,'Batman') || strcmp(obj.Name,'Batgirl')
    global mmc;
    currentGain=obj.getEMGain;
    if currentGain~=gain;
        mmc.setProperty ('Evolve','MultiplierGain',num2str(gain));
        if nargin>3
            if ~isempty(logfile)
                if logfile ~= -1
                    logstring=['EM gain set to ',num2str(gain) ' at ' datestr(clock)];[~]=writelog(logfile,'',logstring);
                end
            end
        end
    end    
end