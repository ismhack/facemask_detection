function results = cnn_detector(image, model, face_size, number_result)

[rows, cols] = size(image);
[trows, tcols] = face_size;
window = zeros(trows, tcols);
scores = zeros(number_results) + realmax;
row = 0;
col =0;

for i = 1:rows
    for j = 1:cols
        xrow = i + trows -1;
        ycol = j + tcols -1;
        if xrow <= rows && ycol <= cols
            window = image(i: xrow, j: ycol);
            %figure(1); imshow(reshape(window, [trows, tcols]), []);
            temp = net.predict(window);
            %fprintf('Checking window row:%d-%d  col:%d-%d,  result:%f.2 \n',i, xrow,j, ycol, temp);
            if(temp < score)
               score = temp;
               row = floor((i + xrow)/2);
               col = floor((j + ycol)/2);
            end    
        end
    end
end