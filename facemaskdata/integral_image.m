function outimg = integral_image (image)
    outimg = cumsum(cumsum(double(image),2));
end