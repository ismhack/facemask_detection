function [result, boxes, scores] =  ...
    boosted_detector_skin_demo(image, scales,  classifiers, ...
                          weak_classifiers, face_size, positives, negatives, result_number, printBb)

% function [result, boxes] =  ...
%     boosted_detector_demo(image, scales,  classifiers, ...
%                           weak_classifiers, face_size, result_number)

[boxes, scores] = boosted_detector_skin(image, scales, classifiers, ...
                         weak_classifiers, face_size, positives, negatives, result_number);
result = image;

%for number = 1:result_number
%    result = draw_rectangle1(result, boxes(number, 1), boxes(number, 2),
%     boxes(number, 3), boxes(number, 4));
%end

if nargin> 8 && printBb
    for i = 1:length(boxes)
        if boxes(i).nonMax == 1
           result = drawRectangle(result, boxes(i).coords, [255 255 255]);
        end
    end
end

end