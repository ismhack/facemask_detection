function scores = cnn_detector(image, model, face_size)

[rows, cols] = size(image);
trows = face_size(1);
tcols = face_size(2);
window = zeros(trows, tcols);
scores = zeros(rows, cols);
row = 0;
col =0;

for i = 1:2:rows
    for j = 1:2:cols
        xrow = i + trows -1;
        ycol = j + tcols -1;
        if xrow <= rows && ycol <= cols
            window = image(i: xrow, j: ycol);
            %figure(1); imshow(reshape(window, [trows, tcols]), []);
            score = model.predict(window);
            %fprintf('Checking window row:%d-%d  col:%d-%d,  result:%f.2 \n',i, xrow,j, ycol, score(2));
           row = floor((i + xrow)/2);
           col = floor((j + ycol)/2);
           
           scores(row, col) = score(2);
           %scores(i * j, 2) = row;
           %scores(i * j, 3) = col;
  
        end
    end
end

%figure(1); imshow(image, []);



