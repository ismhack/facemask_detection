function [row, col, result] = pca_detect_digit(image, mean_digit, eigenvectors, N)

[rows, cols] = size(image);
[trows, tcols] = size(mean_digit);
window = zeros(trows, tcols);
result = zeros([(trows*tcols), 1]);

disp(rows);
for i = 0:rows
    for j = 0:cols
        xrow = i + trows;
        ycol = j + tcols;
        if xrow <= rows && ycol <= cols
            fprintf('Checking window %d X %d \n', xrow, ycol);
            window = image(i: xrow, j: jcol);
            result = pca_score(window, mean_digit, eigenvectors, N);
        end
    end
end

row = 0;
col =0;

figure(1); imshow(reshape(window, [28,28]), []);

