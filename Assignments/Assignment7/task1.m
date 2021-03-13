%% PATH setup
addpath './training_data/';
addpath './new_test_data/';
load_mnist
%% calc averages
[rows, cols, number] = size(mnist_digits)

total2_count = size(find(mnist_labels ==2),1);
total3_count = size(find(mnist_labels ==3),1);

digits2 = zeros(rows*cols, total2_count);
digits3 = zeros(rows*cols, total3_count);
% set mean of all faces to 0, and std to 1.
count=1;
for index = find(mnist_labels==2)
        digit = mnist_digits(:,:, index);
        digit = digit(:);
        digit = (digit - mean(digit)) / std(digit);
        digits2(:, count) = digit;
        count= count+1;
end

count=1;
for index = find(mnist_labels==3)
        digit = mnist_digits(:,:, index);
        digit = digit(:);
        digit = (digit - mean(digit)) / std(digit);
        digits3(:, count) = digit;
        count= count+1;
end



[averag2, eigenvectors2, eigenvalues2] = compute_pca(digits2); 
figure(1); imshow(reshape(eigenvectors2(:, 1),rows, cols), []);
figure(2); imshow(reshape(eigenvectors2(:, 2),rows, cols), []);
figure(3); imshow(reshape(eigenvectors2(:, 3),rows, cols), []);
figure(4); imshow(reshape(eigenvectors2(:, 4),rows, cols), []);
figure(5); imshow(reshape(eigenvectors2(:, 5),rows, cols), []);


[average3, eigenvectors3, eigenvalues3] = compute_pca(digits3); 

figure(6); imshow(reshape(eigenvectors3(:, 1),rows, cols), []);
figure(7); imshow(reshape(eigenvectors3(:, 2),rows, cols), []);
figure(8); imshow(reshape(eigenvectors3(:, 3),rows, cols), []);
figure(9); imshow(reshape(eigenvectors3(:, 4),rows, cols), []);
figure(10); imshow(reshape(eigenvectors3(:, 5),rows, cols), []);


%% TEST detect digit
image = read_gray('new_three20.bmp');
[row, col, result] = pca_detect_digit(image, reshape(average3, [rows cols]), eigenvectors3, 10);

figure(3); imshow(draw_rectangle2(image, row, col, rows, cols), []);

%% TEST recognize digit all test data
correct =0;
wrong=0;
for i = 1:40
    test = read_gray(['test' num2str(i,'%d') '.bmp']);
    digit = recognize_digit(test, average2, average3);
    if( i < 20)
        if( digit == 2)
            correct = correct +1;
        else
            wrong = wrong + 1;
            fprintf('failed test%d.bmp \n',i);
        end
    else
         if( digit == 3)
            correct = correct +1;
        else
            wrong = wrong + 1;
            fprintf('failed test%d.bmp \n',i);
         end
    end

end

fprintf('recognize_digit: Correct %d - Failed: %d - Accuracy: %.2f ', correct,wrong, (correct/40)* 100);
%%

