function [boxes, detections] = evaluate_facemask_detector(test, scales, boosted_classifiers,...
    weak_classifiers, net, image_size, positives, negatives, result_number)
[result, boxes] = boosted_detector_skin_demo(test, scales, boosted_classifiers,...
    weak_classifiers, image_size, positives, negatives, result_number); 
detections = zeros(1,2);
[boxes ,scores] = facemask_classifier(test, net, boxes);
for i = 1:length(boxes)
    if boxes(i).nonMax == 1
        if boxes(i).cnnFaceMaskProb >= 0.5
            detections(2) = detections(2) +1;

        else
            detections(1) = detections(1) +1;
        end
    end
end

end