function live
n=0;
while n==0 
img2=zeros(100,100);
imshow(img2,[]);
h=gcf;
set(h,'KeyPressFcn',@stopFunction);
% mmc.snapImage(); 
% img=mmc.getImage();
% width=mmc.getImageWidth(); 
% height=mmc.getImageHeight(); 
% img2=typecast(img,'uint8'); 
% img2=reshape(img2,[height,width]); ffff
if n==1
    break
end
end
end


function stopFunction(src, evnt)
fprintf('Stopped\n');
keyboard;
end
