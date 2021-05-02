%% dataset 
h= 224;
w = 224;
c = 3;

imds = imageDatastore('data', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
tbl = countEachLabel(imds)
[trainingSet, testSet] = splitEachLabel(imds, 0.8, 'randomized');

augmentedTrainingSet = augmentedImageDatastore([h w c], trainingSet);%,'ColorPreprocessing', 'rgb2gray');%'DataAugmentation',imageAugmenter); %'
augmentedTestSet = augmentedImageDatastore([h w c], testSet);%, 'ColorPreprocessing', 'rgb2gray');

minibatch = read(augmentedTrainingSet);
figure (2);imshow(imtile(minibatch.input));


minibatch = read(augmentedTestSet);
figure(3);imshow(imtile(minibatch.input));

%% use MobileNet

mobileNet;

miniBatchSize = 64;
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',6, ...
    'InitialLearnRate',0.01, ...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress');

mnet = trainNetwork(augmentedTrainingSet,lgraph_MobileNet,options);


%% test

Ypred = classify(trainedNetwork_1, augmentedTestSet); % Predict labels of test data.

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

%% validate

%% test cnn

test = imread('photos/test2.jpg');

tic; [result boxes scores] = cnn_detector_demo(test,[.5], trainedNetwork_1, 1); toc;

figure(5); imshow(result, []);
window1 = (test(113:212, 100:199, :));
window2 = (test(80: 179, 50:149, :));
window3 = (test(30:129, 180:279, :));

window1 = imresize(window1, [h w]);
window2 = imresize(window2, [h w]);
window3 = imresize(window3, [h w]);

tic; y =trainedNetwork_1.predict(window1); toc;
y = classify(trainedNetwork_1, window1);
figure(2); 
subplot(1,3,1);
imshow((window1),[]);
title(strcat(' pred:', string(y), ' true:1' ));

tic; y =trainedNetwork_1.predict(window2); toc;
y = classify(trainedNetwork_1, window2);
subplot(1,3,2);
imshow((window2),[]);
title(strcat(' pred:', string(y), ' true:1' ));

tic; y =trainedNetwork_1.predict(window3); toc;
y = classify(trainedNetwork_1, window3);
subplot(1,3,3);
imshow((window3),[]);
title(strcat(' pred:', string(y), ' true:1' ));

%% test cnn and skin detection
test = (imread('photos/test3.jpg'));
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');

tic; result1 = cnn_skin_demo(test,[1 2 3],trainedNetwork_1, positives, negatives, 5); toc;
figure(5); imshow(result1, []);

%% test 2
test = imread('photos/test2.jpg');

%tic; [result boxes scores] = cnn_detector_demo(test, 1, gnet, 1); toc;

tic; result1 = cnn_skin_demo(test,[0.5 0.6],trainedNetwork_1, positives, negatives, 5); toc;
figure(5); imshow(result1, []);

%figure(5); imshow(result, []);
window1 = (test(113:212, 100:199, :));
window2 = (test(80: 179, 50:149, :));
window3 = (test(30:129, 180:279, :));

window1 = imresize(window1, [h w]);
window2 = imresize(window2, [h w]);
window3 = imresize(window3, [h w]);

tic; y =trainedNetwork_1.predict(window1); toc;
y = classify(trainedNetwork_1, window1)
figure(2); 
subplot(1,3,1);
imshow((window1),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =trainedNetwork_1.predict(window2)
y = classify(trainedNetwork_1, window2);
subplot(1,3,2);
imshow((window2),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =trainedNetwork_1.predict(window3)
y = classify(trainedNetwork_1, window3);
subplot(1,3,3);
imshow((window3),[]);
title(strcat(' pred:', string(y), ' true:1' ));

