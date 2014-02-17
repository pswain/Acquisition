global mmc;
startState=mmc.getProperty('DTOL-Switch','State');
mmc.setProperty('DTOL-Switch','State','16');%binary 00010000 - ie switch digital 4 to 1
mmc.setProperty('DTOL-Shutter','OnOff','1');%Open shutter sends the signal
pause (0.110);%to detect a falling edge the signal has to be in the on state for more than 100ms
mmc.setProperty('DTOL-Switch','State','0');%Back to 0 - generates the falling edge
mmc.setProperty('DTOL-Shutter','OnOff','0');
mmc.setProperty('DTOL-Switch','State',startState);%return to previous state - will allow snapping of images