function scores = cnn_detector(image, model, face_size)

[rows, cols, c] = size(image);
trows = face_size(1);
tcols = face_size(2);
c = face_size(3);
window = uint8(zeros(trows, tcols));
scores = zeros(rows, cols, 3);
row = 0;
col =0;

for i = 1:2:rows
    for j = 1:2:cols
        xrow = i + trows -1;
        ycol = j + tcols -1;
        if xrow <= rows && ycol <= cols
            window = image(i: xrow, j: ycol, :);
            %figure(1); imshow(window, []);
            score = model.predict(window);
            %fprintf('Checking window row:%d-%d  col:%d-%d,  result:[%.3f %.3f, %.3f]\n',i, xrow,j, ycol, score(1),score(2),score(3));
           row = floor((i + xrow)/2);
           col = floor((j + ycol)/2);
           
           scores(row, col, 1) = score(1);
           scores(row, col, 2) = score(2);
           scores(row, col, 3) = score(3);
           %scores(i * j, 2) = row;
           %scores(i * j, 3) = col;
  
        end
    end
end

%figure(1); imshow(scores, []);



