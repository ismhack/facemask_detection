
%% extract face and nonface patches from kaggle data

class1 = "without_mask"; % applicable for the kaggle data
class2 = "with_mask";
class3 = "mask_weared_incorrect";
h = 100;
w = 100;
c = 3; % Grayscale images have one channel. RGB color images have three channels
im_dataset = zeros(h, w, 3, 1);
im_labels = [];
im_dataset = uint8(im_dataset);
count = 1;
for i = 0:852
    S = readstruct(['annotations/maksssksksss' num2str(i, '%d') '.xml']);
    [I, map] = imread(['images/maksssksksss' num2str(i, '%d') '.png']);
    I = uint8(255 * mat2gray(I));
    frames_size = size(S.object, 2);
    for j = 1: frames_size
        %I = draw_rectangle1(I,S.object(i).bndbox.ymax, S.object(i).bndbox.ymin, S.object(i).bndbox.xmin, S.object(i).bndbox.xmax);
        top = S.object(j).bndbox.ymax;
        bottom = S.object(j).bndbox.ymin;
        left = S.object(j).bndbox.xmin;
        right = S.object(j).bndbox.xmax;
        face = I(bottom:top-1, left:right-1, 1:3);
        
        if size(face,1) < 35 || size(face,2) < 35
            continue;
        end

        if S.object(j).name == class1
            class =class1;
            className= "1";
        elseif S.object(j).name == class2
            class = class2;
            className= "2";
        else
            class = "0";
            continue;
        end
        fprintf('[%d %d %d] %d i:%d \n', size(face), count, i);
        im_dataset(:,:,:,count) = uint8(imresize(face,[h w]));
        imwrite( im_dataset(:,:,:,count),strcat('data/', className ,'/', string(count),'.png'),'png');
        im_labels(count) = className;
        count = count +1;
    end
end

% scramble
%count = count-1;
%random_numbers = randperm(count);

%im_labels_r = zeros(size(im_labels));
%im_dataset_r = zeros(size(im_dataset));
%for i = 1:count
%       im_labels_r(i) = im_labels(random_numbers(i));
%       im_dataset_r(:,:,:,i) = im_dataset(:,:,:,random_numbers(i));
%end

%im_labels = uint8(im_labels_r);
%im_dataset = uint8(im_dataset_r);


%% data split
h = 100;
w = 100;
c = 3; 
imds = imageDatastore('data', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
tbl = countEachLabel(imds)
[trainingSet, testSet] = splitEachLabel(imds, 0.8, 'randomized');

augmentedTrainingSet = augmentedImageDatastore([h w c], trainingSet);%,'ColorPreprocessing', 'rgb2gray');%'DataAugmentation',imageAugmenter); %'
augmentedTestSet = augmentedImageDatastore([h w c], testSet);%, 'ColorPreprocessing', 'rgb2gray');

%Xtrain = im_dataset(:,:,:,1:655);
%Xtest = im_dataset(:,:,:,656:939);

%Ytrain = im_labels(1:655);
%Ytest = im_labels(656:939);

%N_train = size(Xtrain, 4);
%N_test = size(Xtest, 4);

%Ytest = categorical(Ytest);
%Ytrain = categorical(Ytrain);

minibatch = read(augmentedTrainingSet);
figure (2);imshow(imtile(minibatch.input));


minibatch = read(augmentedTestSet);
figure(3);imshow(imtile(minibatch.input));
%% Train

%Xtrain = reshape(Xtrain, [h, w, c, N_train]);

%Xtest = reshape(Xtest, [h, w, c, N_test]);
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
    
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ... % Stochastic gradient descent with momentum.
    'InitialLearnRate', 0.01, ...     % Learning rate.
    'MaxEpochs', 6, ...               % How many epochs to train.
    'MiniBatchSize',64, ...
    'Shuffle', 'every-epoch', ...     % Shuffle the training data every epoch.
    'Verbose', true);              % Show the progress of the training process.
       % Plot diagrams of the training process.

%net = trainNetwork(Xtrain, Ytrain, layers, options);
net = trainNetwork(augmentedTrainingSet, layers, options);


%% TEST

Ypred = classify(net, augmentedTestSet); % Predict labels of test data.

%accuracy = sum(Ypred == Ytest)/numel(Ytest);

% Compute confusion matrix
C = confusionmat(testSet.Labels, Ypred);

% Plot a basic confusion matrix chart
%figure; confusionchart(C); % or confusionchart(Ytest, Ypred);

% Plot a more detailed confusion matrix chart
figure; plotconfusion(testSet.Labels, Ypred);

%% Plot miss classifications
idxs = find(Ypred ~= testSet.Labels);
comaprison = [Ypred(idxs), testSet.Labels(idxs)];

if isempty(idxs) ~= 1
    figure;
    grid_cols = 10;
    grid_rows = ceil(size(idxs,1)/10);

    for i = 1:size(idxs,1)
        subplot(grid_rows,grid_cols,i);
        im_er = imread(string(augmentedTestSet.Files(idxs(i))));
        imshow(im_er,[]);
        title(strcat(' pred:', string(Ypred(idxs(i))), ' true:', string(testSet.Labels(idxs(i)))));
    end
end

%% test 1

test = (imread('photos/test1.jpg'));
%test = imresize(test, .4, 'bilinear');
%test = imresize(test, 2, 'bilinear');
tic; [result boxes scores] = cnn_detector_demo(test, [0.4], net, 3); toc;

figure(1); imshow(result, []);

%% test 2


test = imread('photos/test2.jpg');

%tic; [result boxes scores] = cnn_detector_demo(test, 1, net, 1); toc;

tic; result1 = cnn_skin_demo(test,[0.6 .8 1 1.5],net, positives, negatives, 1); toc;

figure(5); imshow(result1, []);
window1 = (test(113:212, 100:199, :));
window2 = (test(80: 179, 50:149, :));
window3 = (test(30:129, 180:279, :));

tic; y =net.predict(window1); toc;
y = classify(net, window1)
figure(2); 
subplot(1,3,1);
imshow((window1),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window2)
y = classify(net, window2);
subplot(1,3,2);
imshow((window2),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window3)
y = classify(net, window3);
subplot(1,3,3);
imshow((window3),[]);
title(strcat(' pred:', string(y), ' true:1' ));

%% test 3 -  skin vs only cnn

test = (imread('photos/test3.jpg'));
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; result1 = cnn_skin_demo(test,[.45 0.5 .8],net, positives, negatives, 5); toc;
figure(5); imshow(result1, []);
%tic; [result2 boxes scores] = cnn_detector_demo(test, [0.5 .8 1], net, 3); toc;


%skin_detection = detect_skin2(test, positives);

%maxVal = max(skin_detection(:));
%minVal = min(skin_detection(:));

%mid = (50 * (maxVal - minVal) / 100) + minVal;

%figure(4); imshow(skin_detection>mid, []);
%figure(6); imshow(result2, []);

%% test 4 - skin

test = (imread('photos/test4.jpg'));
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');
%test = imresize(test, .8, 'bilinear');
%tic; [result boxes scores] = cnn_detector_demo(test, 1, net, [h w c], 3); toc;
tic; [result1, boxes, temp_result, max_scales] = cnn_skin_demo(test,[0.7 0.8 0.9 1 1.2],net, positives, negatives, 5); toc;
figure(5); imshow(result1, []);

%% test 6

test = imread('photos/test6.jpg');
%test = imresize(test, 1.4, 'bilinear');
%tic; [result boxes scores] = cnn_detector_demo(test, 1, net, [h w c], 5); toc;

tic; [result1, boxes, temp_result, max_scales] = cnn_skin_demo(test,[.7 .8 .9 .95 1 1.1],net, positives, negatives, 3); toc;
figure(5); imshow(result1, []);

%figure(5); imshow(result, []);
window1 = (test(100:199, 211:310, :));
window2 = (test(80: 179, 130:229, :));
window3 = (test(100:199, 330:429, :));

y =net.predict(window1)
y = classify(net, window1)

figure(6); 
subplot(1,3,1);
imshow((window1),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window2)
y = classify(net, window2);
subplot(1,3,2);
imshow((window2),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window3)
y = classify(net, window3);
subplot(1,3,3);
imshow((window3),[]);
title(strcat(' pred:', string(y), ' true:1' ));

%% Test Demo test5

test = imread('photos/test5.jpg');

tic; [result boxes scores] = cnn_detector_demo(test, 1, net, [h w c], 5); toc;
figure(5); imshow(result, []);
window1 = test(50:149, 100:199, :);
window2 = test(50:149, 320:419, :);
window3 = test(50:149, 490:589, :);

window4 = test(240:339, 100:199, :);
window5 = test(240:339, 320:419, :);
window6 = test(240:339, 490:589, :);

y =net.predict(window1)
y = classify(net, window1)

figure(4); 
subplot(6,6,1);
imshow(window1,[]);
title(strcat(' pred:', string(y), ' true:0' ));
y =net.predict(window2)
y = classify(net, window2)
subplot(6,6,2);
imshow(window2,[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window3)
y = classify(net, window3)
subplot(6,6,3);
imshow(window3,[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window4)
y = classify(net, window4)
subplot(6,6,4);
imshow(window4,[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window5)
y = classify(net, window5)
subplot(6,6,5);
imshow(window5,[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =net.predict(window6)
y = classify(net, window6)
subplot(6,6,6);
imshow(window6,[]);
title(strcat(' pred:', string(y), ' true:1' ));


