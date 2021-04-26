function [result, boxes, temp_result] = cnn_detector_demo(image, scales, model, face_size, result_number)

result = [];
    if scales(1) >= 1
        if(scales(1)  == 1)
            scaled_image = image;
        else
            scaled_image = imresize(image, 1/scales(1) , 'bilinear');
        end
        temp_result = cnn_detector(scaled_image, model, face_size);
        %result = imresize(result, size(temp_result));
        result = temp_result;
        %temp_result = imresize(temp_result, size(image));
    else
        scaled_face = face_size * scale(1);
        temp_result = cnn_detector(image, model, scaled_face);
        result =temp_result;
    end

[rows, cols] = size(image);
trows = face_size(1);
tcols = face_size(2);
h2 = floor(trows/2);
w2 = floor(tcols/2);
boxes = zeros(result_number,5);
i=1;
predval =1;
while result_number >= i && predval >= 0.5
    
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
        h1 = (r+h2);
    end
    
    if((c- w2) <= 0)
        w0 = 1;
    else
        w0 = (c- w2);
    end
    
    if((c+ w2) > cols)
        w1 = cols;
    else
        w1 = (c +w2);
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

result=image;
