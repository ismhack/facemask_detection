

class1 = "without_mask";
class2 = "with_mask";
class3 = "mask_weared_incorrect";
h = 100;
w = 100;
im_dataset = zeros(h, w, 3, 1);
im_labels = zeros(852,1);
count = 1;
for i = 0:852
    S = readstruct(['annotations/maksssksksss' num2str(i, '%d') '.xml']);
    [I, map] = imread(['images/maksssksksss' num2str(i, '%d') '.png']);
    frames_size = size(S.object, 2);
    for j = 1: frames_size
        %I = draw_rectangle1(I,S.object(i).bndbox.ymax, S.object(i).bndbox.ymin, S.object(i).bndbox.xmin, S.object(i).bndbox.xmax);
        top = S.object(j).bndbox.ymax;
        bottom = S.object(j).bndbox.ymin;
        left = S.object(j).bndbox.xmin;
        right = S.object(j).bndbox.xmax;
        face = I(bottom:top-1, left:right-1, 1:3);

        if S.object(j).name == class1
            class = 0;
        elseif S.object(j).name == class2
            class = 1;
        else
            class = 3;
            continue;
        end
        fprintf('[%d %d %d] %d i:%d \n', size(face), count, i);
        im_dataset(:,:,:,count) = imresize(face,[100 100]);
        im_labels(count) = class;
        count = count +1;
    end
end

count = count-1;
random_numbers = randperm(count);

im_labels_r = zeros(size(im_labels));
im_dataset_r = zeros(size(im_dataset));
for i = 1:count
       im_labels_r(i) = im_labels(random_numbers(i));
       im_dataset_r(:,:,:,i) = im_dataset(:,:,:,random_numbers(i));
end

im_labels = im_labels_r;
im_dataset = im_dataset_r;


%% training

Xtrain = im_dataset(:,:,:,1:3000);
Xtest = im_dataset(:,:,:,3001:3949);

Ytrain = im_labels(1:3000);
Ytest = im_labels(3001:3949);

N_train = size(Xtrain, 4); 
N_test = size(Xtest, 4); 

%% Train

c = 3; % Grayscale images have one channel. RGB color images have three channels

%Xtrain = reshape(Xtrain, [h, w, c, N_train]);

%Xtest = reshape(Xtest, [h, w, c, N_test]);

Ytest = categorical(Ytest);
Ytrain = categorical(Ytrain);

layers = [
    imageInputLayer([h w c]) % Dimensions of a single input image.
    convolution2dLayer(3, 8,'Padding', 'same') % 1st convolutional layer.
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride', 2)          % Max pooling.
    
    convolution2dLayer(3 , 16, 'Padding', 'same')% 2nd convolutional layer.
    batchNormalizationLayer
    reluLayer
     
    maxPooling2dLayer(2, 'Stride', 2)  
    
    convolution2dLayer(2, 32, 'Padding', 'same')% 3rd convolutional layer.
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(32)
    reluLayer
    
    fullyConnectedLayer(16)
    reluLayer
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ... % Stochastic gradient descent with momentum.
    'InitialLearnRate', 0.01, ...     % Learning rate.
    'MaxEpochs', 5, ...               % How many epochs to train.
    'Shuffle', 'every-epoch', ...     % Shuffle the training data every epoch.
    'Verbose', true);              % Show the progress of the training process.
       % Plot diagrams of the training process.

net = trainNetwork(Xtrain, Ytrain, layers, options);


%% TEST

Ypred = classify(net, Xtest); % Predict labels of test data.

accuracy = sum(Ypred == Ytest)/numel(Ytest);

% Compute confusion matrix
C = confusionmat(Ytest, Ypred);

% Plot a basic confusion matrix chart
%figure; confusionchart(C); % or confusionchart(Ytest, Ypred);

% Plot a more detailed confusion matrix chart
figure; plotconfusion(Ytest, Ypred);

%% Plot miss classifications
idxs = find(Ypred ~= Ytest);
comaprison = [Ypred(idxs), Ytest(idxs)];

if isempty(idxs) ~= 1
    figure;
    grid_cols = 10;
    grid_rows = ceil(size(idxs,1)/10);

    for i = 1:size(idxs,1)
        subplot(grid_rows,grid_cols,i);
        imshow(uint16(Xtest(:,:,:,idxs(i))),[]);
        title(strcat(string(idxs(i)),' pred:', string(Ypred(idxs(i))), ' true:', string(Ytest(idxs(i)))));
    end
end

%% Test Demo

test = imread('photos/test5.jpg');

%tic; result = cnn_detector_demo(test, 1.25, net, [100 100 3], 6); toc;
window = test(50:149, 120:219, :);

net.predict(window)
figure(4); imshow((window),[]);

figure(3); imshow(result, []);

