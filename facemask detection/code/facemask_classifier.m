function [boxes, scores] = facemask_classifier(image, model, boxes)
boxes_count = size(boxes,2);
scores = zeros(boxes_count,2);
for i = 1:boxes_count
    
    Xmin =  boxes(i).coords(1);
    Ymin =  boxes(i).coords(2);
    w =  boxes(i).coords(3);
    h =   boxes(i).coords(4);
    window = image(Xmin:Xmin+h-1, Ymin:Ymin+w-1, :);
    if size(window,1) ~= model.Layers(1).InputSize(1) || ...
            size(window,2) ~= model.Layers(1).InputSize(2) || ...
            size(window,3) ~= model.Layers(1).InputSize(3)
        window = imresize(window, model.Layers(1).InputSize(1:2));
    end
    scores(i,:) = model.predict(window);
    boxes(i).cnnFaceProb = scores(i,1);
    boxes(i).cnnFaceMaskProb = scores(i,2);
    fprintf('Predict: Score[%.3f %.3f] - inputSize [%d %d] \n', scores(i,1), scores(i,2), model.Layers(1).InputSize(1),model.Layers(1).InputSize(2));
    
end

%t = struct2table(boxes);
%s = sortrows(t, 'cnnFaceMaskProb', {'descend'});
%boxes = table2struct(s);



