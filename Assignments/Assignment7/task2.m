%% PATH setup
addpath './training_data/';
addpath './new_test_data/';
load_mnist
%% calc averages
[rows, cols, number] = size(mnist_digits)

total3_count = size(find(mnist_labels ==3),1);

digits3 = zeros(rows*cols, total3_count);
digits3_14x14 = zeros((rows/2)*(cols/2), total3_count);
% set mean of all faces to 0, and std to 1.

count=1;
for index = find(mnist_labels==3)'
        digit = mnist_digits(:,:, index);
        digit = digit(:);
        digit = (digit - mean(digit)) / std(digit);
        digits3(:, count) = digit;
        
        % 14x14
        digit = mnist_digits(:,:, index);
        digit = imresize(digit, [(rows/2), (cols/2)], 'bilinear');
        digit = digit(:);
        digit = (digit - mean(digit)) / std(digit);
        digits3_14x14(:, count) = digit;
        
        count= count+1;
end

[average3, eigenvectors3, eigenvalues3] = compute_pca(digits3);
[average3_14x14, eigenvectors3_14x14, eigenvalues3_14x14] = compute_pca(digits3_14x14);

figure(6); imshow(reshape(eigenvectors3(:, 1),rows, cols), []);
figure(7); imshow(reshape(eigenvectors3(:, 2),rows, cols), []);
figure(8); imshow(reshape(eigenvectors3(:, 3),rows, cols), []);
figure(9); imshow(reshape(eigenvectors3(:, 4),rows, cols), []);
figure(10); imshow(reshape(eigenvectors3(:, 5),rows, cols), []);

%% TEST

    image = read_gray('new_three2.bmp');
    %image = read_gray('new_three1.bmp');
    tic; [row, col, result] = fast_pca_detect_digit(image, reshape(average3, [rows cols]), eigenvectors3, eigenvectors3_14x14, 10);toc;
    
    figure(1); imshow(draw_rectangle2(image, row, col, rows, cols), []);

    %image = read_gray('new_three1.bmp');
    tic; [row, col, result] = pca_detect_digit(image, reshape(average3, [rows cols]), eigenvectors3, 10);toc;
    
    figure(2); imshow(draw_rectangle2(image, row, col, rows, cols), []);
%% TEST 3 detect digit
for i = 1:20
    image = read_gray(['new_three' num2str(i,'%d') '.bmp']);
    %image = read_gray('new_three1.bmp');
    [row, col, result] = pca_detect_digit(image, reshape(average3, [rows cols]), eigenvectors3, 10);

    figure(i); imshow(draw_rectangle2(image, row, col, rows, cols), []);

end

%% TEST 2 detect digit 
for i = 1:20
    image = read_gray(['new_two' num2str(i,'%d') '.bmp']);
    %image = read_gray('new_three1.bmp');
    [row, col, result] = pca_detect_digit(image, reshape(average2, [rows cols]), eigenvectors2, 10);

    figure(i); imshow(draw_rectangle2(image, row, col, rows, cols), []);

end

%fprintf('recognize_digit: Correct %d - Failed: %d - Accuracy: %.2f ', correct,wrong, (correct/40)* 100);
%%

