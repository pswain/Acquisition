%Switches the bright field (white) LED on - for supporting ostreococcus
%growth between timepoints

global mmc;

mmc.setProperty('DTOL-Switch','State','1');%binary 10000000 - ie switch digital 1 to 1
mmc.setProperty('DTOL-Shutter','OnOff','1');%Open shutter sends the signal
