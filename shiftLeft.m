function shiftLeft(distance)
    %Moves the stage left by the input distance in microns
    global mmc
    mmc.setRelativeXYPosition('XYStage',-distance,0);
end