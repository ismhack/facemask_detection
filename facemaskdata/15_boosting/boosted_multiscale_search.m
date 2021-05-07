function [max_responses, max_scales] = ...
    boosted_multiscale_search(image, scales, ...
                              classifiers, weak_classifiers, face_size, arg6, arg7)

% function [max_responses, max_scales] = ...
%     boosted_multiscale_search(image, scales, ...
%                               classifiers, weak_classifiers, ...
%                               face_size, result_number)
%
% for each pixel, search over the specified scales and rotations,
% and record:
% - in result, the max response score for that pixel over all scales
% - in max_scales, the scale that gave the max score
image_size =size(image,1:2);
max_responses = ones(image_size) * -10;
max_scales = zeros(image_size);

if nargin < 6
    positives=[];
     negatives=[];
else
    positives = arg6;
    negatives =arg7;
end

for scale = scales

    scaled_image = imresize(image, 1/scale, 'bilinear');
    if(size(classifiers,1) >1)
        temp_result = apply_classifier_aux(scaled_image, classifiers, ...
                                       weak_classifiers, face_size);
    else
        temp_result = apply_classifier_aux_cascade(scaled_image, classifiers, ...
                                       weak_classifiers, face_size, positives, negatives);
    end
    temp_result = imresize(temp_result, image_size, 'bilinear');
    
    higher_maxes = (temp_result > max_responses);
    max_scales(higher_maxes) = scale;
    max_responses(higher_maxes) = temp_result(higher_maxes);
    
end
