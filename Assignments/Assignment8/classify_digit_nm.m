function [result, index] = classify_digit_nm(digit)
normalized_moments = zeros(5000, 9);
bl_threshold=0;
if isfile('normalized_moments.txt')
   normalized_moments = readmatrix('normalized_moments.txt');
else
    addpath './mnist_data/';
    load_mnist;
    for i = 1:5000
        label = mnist_labels(i);
        shape = mnist_digits(:,:,i) > bl_threshold;
        q_cm = [normalized_moment(shape, 0,0) normalized_moment(shape, 1,1) normalized_moment(shape, 2,0) normalized_moment(shape, 0,2) normalized_moment(shape, 2,1) normalized_moment(shape, 1,2) normalized_moment(shape, 3,0) normalized_moment(shape, 0,3) label];
        normalized_moments(i, :) = q_cm;
    end
    writematrix(normalized_moments);
end

test = digit > bl_threshold;
  test_cm = [normalized_moment(test, 0,0); normalized_moment(test, 1,1); normalized_moment(test, 2,0); normalized_moment(test, 0,2); normalized_moment(test, 2,1); normalized_moment(test, 1,2); normalized_moment(test, 3,0); normalized_moment(test, 0,3);];
  %fprintf(' -N[%d, %d, %d, %d, %d, %d,  %d, %d]\n', test_cm.');
substract = realmax;
result = -1;

for i = 1:5000

    q_cm = normalized_moments(i, 1:8)';
    label =  normalized_moments(i, 9);
    temp = sqrt(sum((q_cm - test_cm).^2));
    if(temp < substract)
        %fprintf('%d - N[%d, %d, %d, %d, %d, %d,  %d, %d] label: %d,  difference: %f \n',i,q_cm.', label, temp);
        substract = (temp);
        result = label;
        index = i;
    end
    
end

fprintf('Classified as: %d \n',result); 