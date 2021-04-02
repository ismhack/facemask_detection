[result, boxes] = cnn_detector_demo(image, scales, model, face_size, result_number)

result = ones(size(image)) * -10;
max_scales = zeros(size(image));

for scale = scales
    % for efficiency, we either downsize the image, or the template, 
    % depending on the current scale
    if scale >= 1
        scaled_image = imresize(image, 1/scale, 'bilinear');
        temp_result = normalized_correlation(scaled_image, template);
        temp_result = imresize(temp_result, size(image), 'bilinear');
    else
        scaled_template = imresize(template, scale, 'bilinear');
        temp_result = normalized_correlation(image, scaled_template);
    end
    
    higher_maxes = (temp_result > result);
    max_scales(higher_maxes) = scale;
    result(higher_maxes) = temp_result(higher_maxes);
end

