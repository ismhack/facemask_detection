function [result, index] = classify_digit_hu(digit)
hu_moments = zeros(5000, 8);
bl_threshold=0;
if isfile('hu_moments.txt')
   hu_moments = readmatrix('hu_moments.txt');
else
    addpath './mnist_data/';
    load_mnist;
    for i = 1:5000
        label = mnist_labels(i);
        shape = mnist_digits(:,:,i) > bl_threshold;
        q_cm = [hu_moment(shape, 1) hu_moment(shape, 2) hu_moment(shape, 3) hu_moment(shape, 4) hu_moment(shape, 5) hu_moment(shape, 6) hu_moment(shape, 7) label];
        hu_moments(i, :) = q_cm;
    end
    writematrix(hu_moments);
end

test = digit > bl_threshold;
  test_cm = [hu_moment(test,1); hu_moment(test, 2); hu_moment(test, 3); hu_moment(test, 4); hu_moment(test, 5); hu_moment(test, 6); hu_moment(test,7);];
  fprintf(' -HU[%d, %d, %d, %d, %d, %d, %d]\n', test_cm.');
substract = realmax;
result = -1;

for i = 1:5000

    q_cm = hu_moments(i, 1:7)';
    label =  hu_moments(i, 8);
    temp = sqrt(sum((q_cm - test_cm).^2));
    if(temp < substract)
        fprintf('%d - HU[%d, %d, %d, %d, %d, %d, %d] label: %d,  difference: %f \n',i,q_cm.', label, temp);
        substract = (temp);
        result = label;
        index = i;
    end
    
end