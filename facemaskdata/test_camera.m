
%% open web cam
addpath 15_boosting
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');
detect_facemask_cam(boosted_classifiers, weak_classifiers, [100 100], positives, negatives, net, 2:1:3, 2);


%% one time shot
c= webcam;
img = snapshot(c);

[result, boxes] = boosted_detector_skin_demo(img, 2:1:3, boosted_classifiers, weak_classifiers, [100 100], positives, negatives, 2);
boxes = facemask_classifier(img, net, boxes);
imshow(result, []);
rectanlges = [];
for i = 1:length(boxes)
    if boxes(i).nonMax == 1
        if boxes(i).cnnFaceMaskProb > 0.9
            rectanlges(i) = rectangle('Position',[boxes(i).coords(2),boxes(i).coords(1),boxes(i).coords(3),boxes(i).coords(4)],'EdgeColor','g','LineWidth',2 );
            annotation('textbox',[0 0.3 .1 .1],'String','FaceMask','Color','green');
        elseif boxes(i).cnnFaceProb > 0.5
            rectanlges(i) = rectangle('Position',[boxes(i).coords(2),boxes(i).coords(1),boxes(i).coords(3),boxes(i).coords(4)],'EdgeColor','r','LineWidth',2 );
        end
    end
    drawnow;
end


%%
figure(2); imshow( img(355:355 + 199, 488: 488 + 199));