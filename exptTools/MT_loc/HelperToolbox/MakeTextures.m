function VP = MakeTextures(pa,VP)

    % 1/f noise texture to help anchor vergence
    [x,y] = meshgrid(-VP.Rect(3)/2:VP.Rect(3)/2,-VP.Rect(4):VP.Rect(4));
  
    noysSlope = 1.1;
    noys = oneoverf(noysSlope, size(x,1), size(x,2));
    noys = VP.white.*noys;
    
    % Individual cutouts for each location
    positions   = allcomb(d2r(pa.thetaDirs), pa.rDirs.*VP.pixelsPerDegree );
    [centerX, centerY]     = pol2cart(positions(:,1), positions(:,2));
    centerY = -centerY;
    noys(:,:,2) = ones(size(noys));
    
    cheeseHoleLimit = pa.borderPatch * VP.pixelsPerDegree;

    for ii = 1:length(centerX) % no center patch
        noys(:,:,2) = noys(:,:,2) & ((sqrt((centerX(ii)-x).^2+(centerY(ii)-y).^2) > cheeseHoleLimit));
    end

    noys(:,:,2) = noys(:,:,2) .* VP.white;
    VP.bg=Screen('MakeTexture', VP.window, noys);

end

