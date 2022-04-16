%% PATH setup
addpath './training_data/';
addpath './new_test_data/';
load_mnist
%% calc averages
[rows, cols, number] = size(mnist_digits);
total2_count = size(find(mnist_labels ==2),1);

digits2 = zeros(rows*cols, total2_count);
digits2_14x14 = zeros((rows/2)*(cols/2), total2_count);
% set mean of all faces to 0, and std to 1.
i=1;
for index = find(mnist_labels==2)'
        digit = mnist_digits(:,:, index);
        digit = digit(:);
        digit = (digit - mean(digit)) / std(digit);
        digits2(:, i) = digit;
        i= i+1;
end

% compute eigenvecotr 28x28
[average2, eigenvectors2, eigenvalues2] = compute_pca(digits2);
% compute eigenvecotr 14x14
[average2_14x14, eigenvectors2_14x14, eigenvalues2_14x14] = compute_pca(digits2_14x14);
 
figure(1); 
subplot(3,2,1);
imshow(reshape(eigenvectors2(:, 1),rows, cols), []);
title('eigenvectors2(1)');  
subplot(3,2,2);
imshow(reshape(eigenvectors2(:, 2),rows, cols), []);
title('eigenvectors2(2)');
subplot(3,2,3);
imshow(reshape(eigenvectors2(:, 3),rows, cols), []);
title('eigenvectors2(3)');
subplot(3,2,4);
imshow(reshape(eigenvectors2(:, 4),rows, cols), []);
title('eigenvectors2(4)');
subplot(3,2,5)
imshow(reshape(eigenvectors2(:, 5),rows, cols), []);
title('eigenvectors2(5)');

%% TEST 2 detect digit 
%for i = 1:20
%    image = read_gray(['new_two' num2str(i,'%d') '.bmp']);
    %image = read_gray('new_three1.bmp');
%    [row, col] = pca_detect_digit(image, reshape(average2, [rows cols]), eigenvectors2, 10);

%    figure(i); imshow(draw_rectangle2(image, row, col, rows, cols), []);

%end

%% TEST 2 fast_pca_detect_digit
%    image = read_gray('new_two3.bmp');
    %image = read_gray('new_three1.bmp');
%    tic; [row2, col2] = fast_pca_detect_digit(image, reshape(average2, [rows cols]), eigenvectors2, eigenvectors2_14x14, 10);toc;
    
%    figure(1); imshow(draw_rectangle2(image, row2, col2, rows, cols), []);

    %image = read_gray('new_three1.bmp');
%    tic; [row1, col1] = pca_detect_digit(image, reshape(average2, [rows cols]), eigenvectors2, 10);toc;
    
%   figure(2); imshow(draw_rectangle2(image, row1, col1, rows, cols), []);

