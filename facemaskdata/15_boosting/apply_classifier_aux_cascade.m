function result = apply_classifier_aux_cascade(image, boosted_classifiers, ...
    weak_classifiers, face_size)

% function result = apply_classifier_aux(image, boosted_classifiers, ...
%                                        weak_classifiers, face_size)

layers = size(boosted_classifiers,2);

vertical_size = size(image, 1);
horizontal_size = size(image, 2);
result = zeros(vertical_size, horizontal_size);
face_vertical = face_size(1);
face_horizontal = face_size(2);
integral = integral_image(image);
for vertical = 1:(vertical_size-face_vertical+1)
    for horizontal = 1:3:(horizontal_size-face_horizontal+1)
        class_size =1;
        for i = 1:layers
            boosted = boosted_classifiers{i};
            output = cascade(boosted, weak_classifiers, vertical, horizontal,integral, class_size);
            class_size = size(boosted,1) +1;
            row = vertical + round(face_vertical/2);
            col = horizontal + round(face_horizontal/2);
            result(row, col) = result(row, col) + output;
            %fprintf('layer: %d  evaluated window [%d %d] val:%.2f \n',i, vertical, horizontal, result(row, col));
            if(result(row, col) < 0)
                break;
            end
        end
    end
end
    

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