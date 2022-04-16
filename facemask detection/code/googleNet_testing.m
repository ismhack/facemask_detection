%% GoogleNet test

trainingSet = imageDatastore('data/cnn/training', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
testSet = imageDatastore('data/cnn/testing', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);

tbl = countEachLabel(trainingSet)

augmentedTrainingSet = augmentedImageDatastore([224 224 3], trainingSet);%,'ColorPreprocessing', 'rgb2gray');%'DataAugmentation',imageAugmenter); %'
augmentedTestSet = augmentedImageDatastore([224 224 3], testSet);%, 'ColorPreprocessing', 'rgb2gray');

minibatch = read(augmentedTrainingSet);
figure (2);imshow(imtile(minibatch.input));


minibatch = read(augmentedTestSet);
figure(3);imshow(imtile(minibatch.input));

Ypred = classify(gnet, augmentedTestSet); % Predict labels of test data.


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
disp('Google cnn performance on single patch');
test = imread('data/eval_cnn_photos/photos/test2.jpg');

window1 = (test(113:212, 100:199, :));
window2 = (test(80: 179, 50:149, :));
window3 = (test(30:129, 180:279, :));

window1 = imresize(window1, [224 224]);
window2 = imresize(window2, [224 224]);
window3 = imresize(window3, [224 224]);

tic; y =gnet.predict(window1); toc;
y = classify(gnet, window1);
figure(2); 
subplot(1,3,1);
imshow((window1),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =gnet.predict(window2);
y = classify(gnet, window2);
subplot(1,3,2);
imshow((window2),[]);
title(strcat(' pred:', string(y), ' true:1' ));

y =gnet.predict(window3);
y = classify(gnet, window3);
subplot(1,3,3);
imshow((window3),[]);
title(strcat(' pred:', string(y), ' true:2' ));

%% performance test 2 -  full picture
disp('gcnn full picture');
test = imread('data/eval_cnn_photos/photos/test2.jpg');

tic; [result boxes scores] = cnn_detector_demo(test, .6, gnet, 1); toc;
figure(5); imshow(result, []);

%% performance test 3 -  full picture and skin detection
disp('gcnn and skin full picture');
test = (imread('data/eval_cnn_photos/photos/test2.jpg'));
positives = read_double_image('data/positives.bin');
negatives = read_double_image('data/negatives.bin');
tic; [result1, boxes, temp_result, max_scales] = cnn_skin_demo(test,[.6],gnet, positives, negatives, 1); toc;
figure(5); imshow(result1, []);

