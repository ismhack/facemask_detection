function imageReturn = drawRectangle(image, coords, arg3)
    imageReturn = image;
    rgb=1;
    if nargin<=2 
        intensity = 255;
    else
        intensity = arg3;
        rgb=length(arg3);
    end
    Xmin = coords(1);
    Ymin = coords(2);
    width = coords(3);
    height =  coords(4);
    
    for i = 1:rgb
        imageReturn(Xmin, Ymin:(Ymin + width - 2), i) = intensity(i);
        imageReturn(Xmin+height, Ymin:(Ymin + width - 2), i) = intensity(i);

        imageReturn(Xmin:(Xmin+height -2), Ymin, i) = intensity(i);
        imageReturn(Xmin:(Xmin+height -2), (Ymin + width - 2) , i) = intensity(i);
    end
    
    
    
end