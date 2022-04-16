I = sample2
nBins = 32;
rHist = imhist(I(:,:,1)/255, nBins);
gHist = imhist(I(:,:,2)/255, nBins);
bHist = imhist(I(:,:,3)/255, nBins);
%RGBHIST Histogram Plot
hFig = figure;
subplot(2,1,1); 
imshow(I/255); 
title('Input image');
subplot(2,1,2);
h(1) = area(1:nBins, rHist, 'FaceColor', 'r'); hold on; 
h(2) = area(1:nBins, gHist,  'FaceColor', 'g'); hold on; 
h(3) = area(1:nBins, bHist,  'FaceColor', 'b'); hold on; 
title('RGB image histogram');