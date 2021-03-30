addpath './mnist_data/';
load_mnist
%% calc total
[rows, cols, number] = size(mnist_digits);
bl_threshold = 0;
shape = mnist_digits(:,:,434) > bl_threshold;

disp('central moments');
result = central_moment(shape, 0, 0)
result = central_moment(shape, 0, 1)
result = central_moment(shape, 1, 0)
result = central_moment(shape, 1, 1)
result = central_moment(shape, 2, 2)
result = central_moment(shape, 3, 3)
result = central_moment(shape, 1, 2)
result = central_moment(shape, 2, 1)
result = central_moment(shape, 3, 2)
%%
%normalized
disp('normalized moments');
result = normalized_moment(shape, 0, 0)
result = normalized_moment(shape, 0, 1)
result = normalized_moment(shape, 1, 0)
result = normalized_moment(shape, 1, 1)
result = normalized_moment(shape, 2, 2)
result = normalized_moment(shape, 3, 3)

%% hu 
disp('hu moments');
result = hu_moment(shape, 1)
result = hu_moment(shape, 2)
result = hu_moment(shape, 3)
result = hu_moment(shape, 4)
result = hu_moment(shape, 5)
result = hu_moment(shape, 6)
result = hu_moment(shape, 7)

%% testing central moment

class = zeros(5000,1) + realmax;
indexes = zeros(5000,1);
detected = 0;
not_detected = 0; 

for i = 5001:10000
    shape = mnist_digits(:,:,i);
    fprintf('%d - Checking: %d ', i, mnist_labels(i));
    [result,index] = classify_digit_cm(shape);
    if(mnist_labels(i) == result)
        detected = detected +1;
    else
        not_detected = not_detected +1;
    end
    class(i - 5000) = result;
    indexes(i - 5000) = index;
end
figure(1);
cm = confusionmat(categorical(mnist_labels(5001:10000)),categorical(class) );
plotconfusion(categorical(mnist_labels(5001:10000)),categorical(class));

%% testing normalized moment

class = zeros(5000,1) + realmax;
indexes = zeros(5000,1);

detected = 0;
not_detected = 0; 

for i = 5001:10000
    shape = mnist_digits(:,:,i);
    fprintf('%d - Checking: %d ', i, mnist_labels(i));
    [result,index] = classify_digit_nm(shape);
    if(mnist_labels(i) == result)
        detected = detected +1;
    else
        not_detected = not_detected +1;
    end
    class(i - 5000) = result;
    indexes(i - 5000) = index;
end

figure(1);
cm = confusionmat(categorical(mnist_labels(5001:10000)),categorical(class) );
plotconfusion(categorical(mnist_labels(5001:10000)),categorical(class));

%% testing hue moments


class = zeros(5000,1) + realmax;
indexes = zeros(5000,1);

detected = 0;
not_detected = 0; 

for i = 5001:10000
    shape = mnist_digits(:,:,i);
    fprintf('%d - Checking: %d ', i, mnist_labels(i));
    [result,index] = classify_digit_hu(shape);
    if(mnist_labels(i) == result)
        detected = detected +1;
    else
        not_detected = not_detected +1;
    end
    class(i - 5000) = result;
    indexes(i - 5000) = index;
end

figure(1);
cm = confusionmat(categorical(mnist_labels(5001:10000)),categorical(class) );
plotconfusion(categorical(mnist_labels(5001:10000)),categorical(class));


%% plot single detection
query =6077;

    shape = mnist_digits(:,:,query);
    fprintf('Checking: %d',  mnist_labels(query));
    [result,index] = classify_digit_hu(shape);



figure(3); 
subplot(1,2,1);
imshow(mnist_digits(:,:,query), []);
title('test');  
subplot(1,2,2);
imshow(mnist_digits(:,:,index), []);
title('found',index);  

 