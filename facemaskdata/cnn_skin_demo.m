function [image, boxes, temp_result] = cnn_skin_demo(image, scales, model, positives, negatives, result_number)

image_size = size(image);
result = zeros(image_size(1), image_size(2));
face_size = model.Layers(1).InputSize;
max_scales = [];
for scale = scales
    if scales >= 1
        if(scale  == 1)
            scaled_image = image;
            temp_result = cnn_skin_detector(scaled_image, model, face_size,  positives, negatives);
            score_nonface = temp_result(:,:,1);
            score_face = temp_result(:,:,2);
            score_facemask = temp_result(:,:,3);
            temp_result = score_facemask;
        else
            scaled_image = imresize(image, 1/scale , 'bilinear');
            temp_result = cnn_skin_detector(scaled_image, model, face_size, positives, negatives);
            score_nonface = temp_result(:,:,1);
            score_face = temp_result(:,:,2);
            score_facemask = temp_result(:,:,3);
            temp_result = imresize(score_facemask,size(image,1:2));
            disp(size(temp_result));
        end

    else
        scaled_face = face_size * scale;
        temp_result = cnn_skin_detector(image, model, scaled_face, positives, negatives);
        score_nonface = temp_result(:,:,1);
        score_face = temp_result(:,:,2);
        score_facemask = temp_result(:,:,3);
        temp_result = score_facemask;
        face_size = scaled_face;
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
i=1;
predval=1;
while result_number >= i && predval > 0.0
    [val, index] = max(result(:));
    [r,c] = ind2sub(size(result),index);
    predval = val;

    if((r-h2) <= 0)
        h0 = 1;
    else
        h0 = r-h2;
    end
    if ((r+h2) > rows)
        h1 = rows;
    else
        h1 = (r+h2 -1);
    end
    
    if((c- w2) <= 0)
        w0 = 1;
    else
        w0 = (c- w2);
    end
    
    if((c+ w2) > cols)
        w1 = cols;
    else
        w1 = (c +w2 -1);
    end
    fprintf('Max value = %f at (r,c)=(%d,%d) bottom:top, left:right[%d %d %d %d] \n', val, r,c,h0,h1,w0,w1); 
    window = result(h0:h1,w0:w1, :);
    if( min(window(:)) == -1)
        result(h0:h1,w0:w1, :) = -1;
        continue;
    end
      
    result(h0:h1,w0:w1, :) = -1;
    
    image = draw_rectangle1(image,h0, h1, w0, w1);
    boxes(i,:) = [h0,h1,w0,w1, val];
    i =  i+1;

end