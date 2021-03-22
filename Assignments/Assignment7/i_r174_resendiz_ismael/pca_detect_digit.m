function [row, col, score] = pca_detect_digit(image, mean_digit, eigenvectors, N)

[rows, cols] = size(image);
[trows, tcols] = size(mean_digit);
window = zeros(trows, tcols);
score = realmax;
row = 0;
col =0;
for i = 1:rows
    for j = 1:cols
        xrow = i + trows -1;
        ycol = j + tcols -1;
        if xrow <= rows && ycol <= cols
            window = image(i: xrow, j: ycol);
            %figure(1); imshow(reshape(window, [trows, tcols]), []);
            temp = pca_score(window, mean_digit, eigenvectors, N);
            %fprintf('Checking window row:%d-%d  col:%d-%d,  result:%f.2 \n',i, xrow,j, ycol, temp);
            if(temp < score)
               score = temp;
               row = floor((i + xrow)/2);
               col = floor((j + ycol)/2);
            end    
        end
    end
end

