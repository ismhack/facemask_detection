function [result, index] = classify_digit_cm(digit)
central_moments = zeros(5000, 9);
bl_threshold=0;
if isfile('central_moments.txt')
   central_moments = readmatrix('central_moments.txt');
else
    addpath './mnist_data/';
    load_mnist;
    for i = 1:5000
        label = mnist_labels(i);
        shape = mnist_digits(:,:,i) > bl_threshold;
        q_cm = [central_moment(shape, 0,0) central_moment(shape, 1,1) central_moment(shape, 2,0) central_moment(shape, 1,2) central_moment(shape, 0,2) central_moment(shape, 2,1) central_moment(shape, 3,0) central_moment(shape, 0,3) label];
        central_moments(i, :) = q_cm;
    end
    writematrix(central_moments);
end

test = digit > bl_threshold;
  test_cm = [central_moment(test,0,0); central_moment(test, 1,1); central_moment(test, 2,0); central_moment(test, 1,2); central_moment(test, 0,2); central_moment(test, 2,1); central_moment(test, 3,0); central_moment(test, 0,3);];
  fprintf(' -M[%d, %d, %d, %d, %d, %d, %d, %d]\n', test_cm.');
substract = realmax;
result = -1;

for i = 1:5000

    q_cm = central_moments(i, 1:8)';
    label =  central_moments(i, 9);
    temp = sqrt(sum((q_cm - test_cm).^2));
    if(temp < substract)
        fprintf('%d - M[%d, %d, %d, %d, %d, %d, %d, %d] label: %d,  difference: %f \n',i,q_cm.', label, temp);
        substract = (temp);
        result = label;
        index = i;
    end
    
end