function scores = cnn_skin_detector(image, model, face_size, positions)

image_size = size(image);
h = face_size(1);%model.Layers(1).InputSize(1);
w = face_size(2);%model.Layers(1).InputSize(2);
h2 = floor(h/2);
w2 = floor(w/2);
h1 =0; 
w1=0;
scores = zeros(image_size(1), image_size(2),2);
for i = 1:size(positions,1)
    
    [r,c] = ind2sub(image_size(1:2),positions(i));
    
    if((r-h2) <= 0)
        h0 = 1;
        h1 = h2 *2 -1;
    else
        h0 = r-h2;
    end
    if ((r+h2) > image_size(1)) && h1 ==0 || h1 > image_size(1)
        h1 = image_size(1);
    elseif h1 ==0
        h1 = (r+h2 -1);
    end
    
    if((c- w2) <= 0)
        w0 = c;
        w1 = c + w2 *2 -1;
    else
        w0 = (c- w2);
    end
    
    if((c+ w2) > image_size(2)) && w1 ==0 || w1 > image_size(2)
        w1 = image_size(2);
    elseif w1 ==0
        w1 = (c +w2 -1);
    end
    
    window = image(h0:h1,w0:w1, :);
    %fprintf('window %d %d %d \n',size(window));
    if size(window,1) <=0 || size(window,2) <=0
        continue;
    end
    if size(window,1) ~= model.Layers(1).InputSize(1) || ...
                    size(window,2) ~= model.Layers(1).InputSize(2) || ...
                    size(window,3) ~= model.Layers(1).InputSize(3)
                window = imresize(window, model.Layers(1).InputSize(1:2));
    end
    score = model.predict(window);
    scores(r, c,1) = score(1);
    scores(r, c,2) = score(2);
    %fprintf('predicting = [%f %f %f] at (r,c)=(%d,%d) bottom:top,left:right[%d %d %d %d] \n', score(1), score(2),score(3), r,c,h0,h1,w0,w1);
    w1=0;
    h1=0;
end



