addpath './mnist_data/';
load_mnist
%% calc total
[rows, cols, number] = size(mnist_digits);
bl_threshold = 0;
shape = mnist_digits(:,:,434) > bl_threshold;

mu00 = central_moment(shape, 0, 0);

n11 = central_moment(shape, 1, 1)/mu00;


result = central_moment(shape, 0, 0)
result = central_moment(shape, 0, 1)
result = central_moment(shape, 1, 0)
result = central_moment(shape, 1, 1)
result = central_moment(shape, 2, 2)
result = central_moment(shape, 3, 3)

%normalized
result = normalized_moment(shape, 0, 0)
result = normalized_moment(shape, 0, 1)
result = normalized_moment(shape, 1, 0)
result = normalized_moment(shape, 1, 1)
result = normalized_moment(shape, 2, 2)
result = normalized_moment(shape, 3, 3)

%hu 
result = hu_moment(shape, 1)
result = hu_moment(shape, 2)
result = hu_moment(shape, 3)
result = hu_moment(shape, 4)
result = hu_moment(shape, 5)
result = hu_moment(shape, 6)
result = hu_moment(shape, 7)

%% Training

for i = 1:10
    label = mnist_labels(i);
    shape = mnist_digits(:,:,i) > bl_threshold;

    M11 = central_moment(shape, 1,1);
    fprintf('CM: %d, label: %d \n',M11, label);
end

 