function [row, col] =  detect_digit(image, template)
[h, w] = size(template);
result = normalized_correlation(image, template);

maxVal = max(result(:));
[row, col] = find(result == maxVal);

figure(1); imshow(draw_rectangle2(image, row, col, h, w), []);
