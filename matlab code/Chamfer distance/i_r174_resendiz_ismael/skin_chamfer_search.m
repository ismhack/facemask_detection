function [scores, result_image] = skin_chamfer_search(color_image, edge_image, template, scale, number_of_results)
%template = read_gray('template.gif');
%color_image = double(imread('clutter1.bmp'));
%[thetas, edge_image]= canny4(read_gray('clutter1.bmp'),1.4,1.35, 7, 14);

negative_histogram = read_double_image('negatives.bin');
positive_histogram = read_double_image('positives.bin');

skin_detection = detect_skin(color_image, positive_histogram,  negative_histogram);

% Determining hand position based on edge image and skin_detection
hand_search = edge_image & (skin_detection > 0.9);
% start cropping image
[rows, columns] = find(hand_search);
topRow = min(rows);
bottomRow = max(rows);
leftColumn = min(columns);
rightColumn = max(columns);
cropped_image = hand_search(topRow:bottomRow, leftColumn:rightColumn);
% calculate chamfer scrores and resulting image 
[scores, result_image] = chamfer_search(cropped_image, template, scale, number_of_results);

% resize iamge to original size
top_rows = zeros(topRow-1, size(result_image,2) );
bottom_rows = zeros(size(hand_search,1) - bottomRow, size(result_image,2) );

result_image = [top_rows; result_image; bottom_rows];

left_columns = zeros(size(result_image,1),leftColumn -1);
right_columns = zeros(size(result_image,1), size(hand_search,2) - rightColumn);

result_image = [ left_columns result_image right_columns];

% combine result image with edge image
result_image = result_image | edge_image;
%figure(1); imshow(result_image);