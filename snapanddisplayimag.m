mmc.snapImage(); 
img=mmc.getImage(); 
width=mmc.getImageWidth(); 
height=mmc.getImageHeight(); 
img2=typecast(img,'uint8'); 
img2=reshape(img2,[height,width]); 
imshow(img2); 
