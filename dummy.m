%Runs a dummy exposure - no image saved

global mmc
state=mmc.getProperty('TIFilterBlock1','State');
mmc.setProperty('TIFilterBlock1','State',0);
pause(0.3);
mmc.snapImage();img=mmc.getImage;
pause(0.6);
mmc.setProperty('TIFilterBlock1','State',state);
pause(0.3);
