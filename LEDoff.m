%Closes the shutter - used to switches the bright field (white) LED off

global mmc;

mmc.setProperty('DTOL-Shutter','OnOff','0');
