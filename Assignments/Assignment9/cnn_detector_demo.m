function [result, boxes] = cnn_detector_demo(image, scales, model, face_size, result_number)

result = ones(size(image)) * -10;
max_scales = zeros(size(image));

for scale = scales
    % for efficiency, we either downsize the image, or the template, 
    % depending on the current scale
    if scale >= 1
        scaled_image = imresize(image, 1/scale, 'bilinear');
        temp_result = cnn_detector(scaled_image, model, face_size);
        temp_result = imresize(temp_result, size(image), 'bilinear');
    else
        scaled_face = face_size * scale;
        temp_result = cnn_detector(image, model, scaled_face);
    end
    
    higher_maxes = (temp_result > result);
    max_scales(higher_maxes) = scale;
    result(higher_maxes) = temp_result(higher_maxes);
end

[rows, cols] = size(image);
trows = face_size(1);
tcols = face_size(2);
h2 = floor(trows/2);
w2 = floor(tcols/2);
boxes = zeros(result_number,5);
for i = 1:result_number
    
    [val, index] = max(result(:));
    [r,c] = ind2sub(size(result),index);
    fprintf('Max value = %f at (r,c)=(%d,%d)\n', val, r,c);
    if((r-h2) <0)
        h0 = 0;
    else
        h0 = r-h2;
    end
    if ((r+h2) > rows)
        h1 = rows;
    else
        h1 = (r+h2);
    end
    
    if((c- w2) < 0)
        w0 = 0;
    else
        w0 = (c- w2);
    end
    
    if((c+ w2) > cols)
        w1 = cols;
    else
        w1 = (c +w2);
    end
    
    result(h0:h1,w0:w1) = 0;
    
    image = draw_rectangle2(image, r, c, trows, tcols);
    boxes(i,:) = [h0,h1,w0,w1, val];
    
end

result=image;
