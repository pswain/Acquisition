mmc.setExposure(2000);
mmc.setConfig('Dye Set','DIC');
mmc.snapImage;
mmc.setConfig('Dye Set','CFP');
mmc.snapImage;
mmc.setConfig('Dye Set','GFP');
mmc.snapImage;
mmc.setConfig('Dye Set','YFP');
mmc.snapImage;
mmc.setConfig('Dye Set','mCherry 3 colour');
mmc.snapImage;
mmc.setConfig('Dye Set','mCherry');
mmc.snapImage;
mmc.setConfig('Dye Set','tdTomato');
mmc.snapImage;
mmc.setState('EmissionFilterWheel',6);