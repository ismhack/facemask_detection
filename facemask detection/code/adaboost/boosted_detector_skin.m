function [result, max_responses] = boosted_detector_skin(image, scales, classifiers, ...
    weak_classifiers, face_size, ...
    positives, negatives, result_number)

% function result = boosted_detector(image, scales, classifiers, ...
%                                    weak_classifiers, face_size, ...
%                                    result_number)
%
% first, find_faces identifies, for every position in the image, the
% scale that maximizes the normalized correlation with the
% average face. Then, the top results are re-ranked based on how well they
% match the top eigenfaces.

[max_responses, max_scales] = ...
    boosted_multiscale_search(image, scales, classifiers, ...
    weak_classifiers, face_size, positives, negatives);

result = detection_boxes(image, zeros(face_size), max_responses, ...
    max_scales, result_number);

result = nms(result);

end

%%calculate non maximum supression on bounding box
function boxes = nms(result)

iouThresh = 0.5;
box_number= size(result,1);
boxes = struct('coords',[],'cellIndex',[],'classIndex',{},'cellProb', {},'nonMax', {}, 'cnnFaceProb',{}, 'cnnFaceMaskProb',{});
for i=1:box_number
    if result(i,5) && result(i,1) > 0
        boxes(i).coords = [result(i, 1), result(i, 3), abs(result(i, 1) - result(i, 2)), abs(result(i, 4) -result(i, 3))];
        
        %save cell indices in the structure
        boxes(i).cellIndex = [i,1];
        
        %save classIndex to structure
        boxes(i).classIndex = 1;
        
        % save cell proability to structure
        boxes(i).cellProb = result(i,5);
        
        % put in a switch for non max which we will use later
        boxes(i).nonMax = 1;
    end
end
iou = zeros(box_number,box_number);
value=zeros(box_number,1);
dropIndex = zeros(box_number,1);
for i = 1:length(boxes)
    for j = i+1:length(boxes)
        %calculate intersection over union (can also use bboxOverlapRatio
        %with proper toolbox
        intersect = rectint(boxes(i).coords,boxes(j).coords);
        union = boxes(i).coords(3)*boxes(i).coords(4)+boxes(j).coords(3)*boxes(j).coords(4)-intersect;
        iou(i,j) = intersect/union;
        if boxes(i).classIndex == boxes(j).classIndex && iou(i,j) > iouThresh
            [value(i), dropIndex(i)] = min([boxes(i).cellProb boxes(j).cellProb]);
            if dropIndex(i) == 1
                boxes(i).nonMax=0;
            elseif dropIndex(i) == 2
                boxes(j).nonMax=0;
            end
        end
    end
end

end