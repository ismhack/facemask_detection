function scores = cnn_skin_detector(image, model, face_size, positives, negatives)

skin_detection = detect_skin(image, positives, negatives);

%figure (1); imshow(skin_detection, []);



maxVal = max(max(skin_detection));
minVal = min(min(skin_detection));

mid = (95 * (maxVal - minVal) / 100) + minVal;

%figure (2); imshow(skin_detection > mid, []);
positions = find(skin_detection > mid);
image_size = size(image);
h = face_size(1);%model.Layers(1).InputSize(1);
w = face_size(2);%model.Layers(1).InputSize(2);
h2 = floor(h/2);
w2 = floor(w/2);
scores = zeros(image_size);
for i = 1:size(positions,1)
    [r,c] = ind2sub(image_size(1:2),positions(i));
    
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
    window = image(h0:h1,w0:w1, :);
    if size(window,1) ~= model.Layers(1).InputSize(1) || ...
                    size(window,2) ~= model.Layers(1).InputSize(2) || ...
                    size(window,3) ~= model.Layers(1).InputSize(3)
                window = imresize(window, model.Layers(1).InputSize(1:2));
    end
    score = model.predict(window);
    scores(r, c,1) = score(1);
    scores(r, c,2) = score(2);
    scores(r, c,3) = score(3);
    %fprintf('predicting = %f at (r,c)=(%d,%d) bottom:top, left:right[%d %d %d %d] \n', score(3), r,c,h0,h1,w0,w1); 
    
end



