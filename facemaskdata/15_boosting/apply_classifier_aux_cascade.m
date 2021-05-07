function result = apply_classifier_aux_cascade(image, boosted_classifiers, ...
    weak_classifiers, face_size, positives, negatives)

% function result = apply_classifier_aux(image, boosted_classifiers, ...
%                                        weak_classifiers, face_size)

layers = size(boosted_classifiers,2);

%adding skin detection
if(size(positives,1)> 0 )
    skin_detection = detect_skin(image, positives, negatives);
    skin_detection = skin_detection>mean(skin_detection(:));
    skin_detection_integral = integral_image(skin_detection);
    image = rgb2gray(image);
end

vertical_size = size(image, 1);
horizontal_size = size(image, 2);
result = zeros(vertical_size, horizontal_size);
face_vertical = face_size(1);
face_horizontal = face_size(2);
integral = integral_image(image);
for vertical = 1:(vertical_size-face_vertical)
    for horizontal = 1:3:(horizontal_size-face_horizontal)
        class_size =1;
        
        if(size(positives,1)> 0 )
            percentage_skin_pixels =calcPixels(skin_detection_integral, vertical, horizontal, face_vertical, face_horizontal);
            %disp(percentage_skin_pixels);
            if percentage_skin_pixels < 0.39
                continue;
            end
        end
        
        for i = 1:layers
            boosted = boosted_classifiers(i);
            output = cascade(boosted.classifiers, weak_classifiers, vertical, horizontal,integral, class_size);
            class_size = size(boosted,1) +1;
            row = vertical + round(face_vertical/2);
            col = horizontal + round(face_horizontal/2);
            result(row, col) = result(row, col) + output;
            %fprintf('layer: %d  evaluated window [%d %d] val:%.2f \n',i, vertical, horizontal, result(row, col));
            if(result(row, col) < boosted.threshold)
                break;
            end
        end
    end
end
    

end


function result = calcPixels(integral_image, vertical, horizontal, face_vertical, face_horizontal)

        if vertical > 1 && horizontal >1
            A = integral_image(vertical-1, horizontal -1);
            B = integral_image(vertical-1, horizontal + face_horizontal);
            C = integral_image(vertical +face_vertical, horizontal -1);
        else
            if vertical > 1 
                A = 0;
                B = integral_image(vertical-1, horizontal + face_horizontal);
                C = 0;
            elseif horizontal >1
               A = 0;
               B = 0;
               C = integral_image(vertical + face_vertical, horizontal -1);
            else
                A =0;
                B =0;
                C =0;
            end
           
        end
         %fprintf(' row: %d, col: %d', vertical + face_vertical,  horizontal +face_horizontal);
         D = integral_image(vertical + face_vertical, horizontal +face_horizontal);
        total_pixels = face_vertical * face_horizontal;
        result = (A+D - C -B)/total_pixels;
        
        %fprintf(' A:%d, B:%d, C:%d, D:%d, total: %d,  perc: %f \n', A, B, C, D, (A+D - C -B), result);
end

function result= cascade(boosted, weak_classifiers, vertical, horizontal, integral, class_size)

classifier_number = size(boosted, 1);
result =0;
for weak_classifier = class_size:classifier_number
    classifier_index = boosted(weak_classifier, 1);
    classifier_alpha = boosted(weak_classifier, 2);
    classifier_threshold = boosted(weak_classifier, 3);
    classifier = weak_classifiers{classifier_index};
    
    response1 = eval_weak_classifier(classifier, integral, vertical, horizontal);
    if (response1 > classifier_threshold)
        response2 = 1;
    else
        response2 = -1;
    end
    response = classifier_alpha * response2;
    result = result + response;
end


end