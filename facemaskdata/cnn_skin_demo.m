function [image, boxes, temp_result, max_scales] = cnn_skin_demo(image, scales, model, positives, negatives, result_number)

% skin detection
%skin_detection = detect_skin(image, positives, negatives);
skin_detection = detect_skin2(image, positives);

%figure (1); imshow(skin_detection, []);

maxVal = max(max(skin_detection));
minVal = min(min(skin_detection));

%[labels, number] = bwlabel(skin_detection, 8);
%mid = min(labels(:));
mid = (49 * (maxVal - minVal) / 100) + minVal;

figure (2); imshow(skin_detection > mid, []);
positions = find(skin_detection > mid);
%positions = find(labels == mid);
%figure (2); imshow(labels, []);

% predict on each window position
%positions_refined = positions;

prev = positions(1);
count=0;
total= 0;
positions_refined= zeros(size(positions)); 
for i = 2:size(positions,1)
    if prev +1 == positions(i)
        count = count+1;
        total = total +positions(i);
    else
        if total > 0
            positions_refined(i) =  floor(total/count);
        else
            positions_refined(i) = prev;
        end
        total = 0;
        count = 0;
    end
    prev = positions(i);
end
positions_refined = positions_refined(positions_refined >0);


image_size = size(image);
result = zeros(image_size(1), image_size(2));
face_size = model.Layers(1).InputSize;
max_scales = zeros(image_size(1), image_size(2));
for scale = scales
    if scales >= 1
        if(scale  == 1)
            scaled_image = image;
            temp_result = cnn_skin_detector(scaled_image, model, face_size, positions_refined);
            score_nonface = temp_result(:,:,1);
            score_face = temp_result(:,:,2);
            score_facemask = temp_result(:,:,3);
            temp_result = score_facemask;
        else
            scaled_image = imresize(image, 1/scale , 'bilinear');
            temp_result = cnn_skin_detector(scaled_image, model, face_size, positions_refined);
            score_nonface = temp_result(:,:,1);
            score_face = temp_result(:,:,2);
            score_facemask = temp_result(:,:,3);
            temp_result = imresize(score_facemask,size(image,1:2));
        end

    else
         %scaled_image = imresize(image, scale , 'bilinear');
         %temp_result = cnn_skin_detector(scaled_image, model, face_size, positions_refined);
         %score_nonface = temp_result(:,:,1);
         %score_face = temp_result(:,:,2);
         %score_facemask = temp_result(:,:,3);
         %temp_result = imresize(score_facemask,size(image,1:2));
        scaled_face = face_size * scale;
        temp_result = cnn_skin_detector(image, model, scaled_face, positions_refined);
        score_nonface = temp_result(:,:,1);
        score_face = temp_result(:,:,2);
        score_facemask = temp_result(:,:,3);
        temp_result = score_facemask;
    end
    
    higher_maxes = (temp_result > result);
    max_scales(higher_maxes) = scale;
    result(higher_maxes) = temp_result(higher_maxes);
end


boxes = zeros(result_number,5);
i=1;
predval=1;
face_size = model.Layers(1).InputSize;
while result_number >= i && predval >= 0.5
    % mav val
    [val, index] = max(result(:));
    [r,c] = ind2sub(size(result),index);
    predval = val;
    
    % max scale
    scale = max_scales(r,c);
    trows = face_size(1)* scale;
    tcols = face_size(2)* scale;
    h2 = floor(trows/2);
    w2 = floor(tcols/2);

    if((r-h2) <= 0)
        h0 = 1;
    else
        h0 = r-h2;
    end
    if ((r+h2) > image_size(1))
        h1 = image_size(1);
    else
        h1 = (r+h2 -1);
    end
    
    if((c- w2) <= 0)
        w0 = 1;
    else
        w0 = (c- w2);
    end
    
    if((c+ w2) > image_size(2))
        w1 = image_size(2);
    else
        w1 = (c +w2 -1);
    end
    window = result(h0:h1,w0:w1);
    fprintf('window %d %d %d \n',size(window));
    fprintf('Max value = %f at (r,c)=(%d,%d) bottom:top,left:right[%d %d %d %d] scale %f \n', val, r,c,h0,h1,w0,w1, scale); 
    if( min(window(:)) == -1)
        result(h0:h1,w0:w1) = -1;
        continue;
    end
      
    result(h0:h1,w0:w1) = -1;
    
    image = draw_rectangle1(image,h0, h1, w0, w1);
    boxes(i,:) = [h0,h1,w0,w1, val];
    i =  i+1;

end