function [row, col, result] = pca_detect_digit(image, mean_digit, eigenvectors, N)

[rows, cols] = size(image);
[trows, tcols] = size(mean_digit);
window = zeros(trows, tcols);
result = realmax;
row = 0;
col =0;
disp(rows);
for i = 1:rows
    for j = 1:cols
        xrow = i + trows -1;
        ycol = j + tcols -1;
        if xrow <= rows && ycol <= cols
            window = image(i: xrow, j: ycol);
            temp = pca_score(window, mean_digit, eigenvectors, N);
            fprintf('Checking window row:%d-%d  col:%d-%d,  result:%f.2 \n',i, xrow,j, ycol, temp);
            if(temp < result)
               result = temp;
               col = ceil((i + xrow)/2);
               row = ceil((j + ycol)/2);
            end    
        end
    end
end

