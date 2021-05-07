function [result, boxes] =  ...
    boosted_detector_demo(image, scales,  classifiers, ...
                          weak_classifiers, face_size, result_number)

% function [result, boxes] =  ...
%     boosted_detector_demo(image, scales,  classifiers, ...
%                           weak_classifiers, face_size, result_number)

boxes = boosted_detector(image, scales, classifiers, ...
                         weak_classifiers, face_size, result_number);
result = image;

%for number = 1:result_number
%    result = draw_rectangle1(result, boxes(number, 1), boxes(number, 2),
%     boxes(number, 3), boxes(number, 4));
%end

for i = 1:length(boxes)
    if boxes(i).nonMax == 1
       result = drawRectangle(result, boxes(i).coords);
    end
end


end


function imageReturn = drawRectangle(image, coords)
    imageReturn = image;
    intensity = 255;
    Xmin = coords(1);
    Ymin = coords(2);
    width = coords(3);
    height =  coords(4);
    
    imageReturn(Xmin, Ymin:(Ymin + width - 2), :) = intensity;
    imageReturn(Xmin+height, Ymin:(Ymin + width - 2), :) = intensity;
    
    imageReturn(Xmin:(Xmin+height -2), Ymin, :) = intensity;
    imageReturn(Xmin:(Xmin+height -2), (Ymin + width - 2) , :) = intensity;
    
    
    
end