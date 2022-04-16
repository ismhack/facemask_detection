%% Load data
clear;
load('faces1000.mat');
load('nonfaces1000.mat');

%% Scramble and Divide Data by 70/30

facesNonFaces = zeros(31,25,2000);
randomNumbers = randperm(2000);
labels = zeros(2000,1);

for i = 1:2000
    if(randomNumbers(i) >1000)
       facesNonFaces(:,:,i) = nonfaces(:,:,randomNumbers(i) - 1000);
       labels(i) = 0; 
    else
       facesNonFaces(:,:,i) = faces(:,:,randomNumbers(i));
       labels(i) = 1;
    end
    
end

Xtrain = facesNonFaces(:,:,1:1400);
Xtest = facesNonFaces(:,:,1401:2000);

Ytrain = labels(1:1400);
Ytest = labels(1401:2000);

N_train = size(Xtrain, 3); 
N_test = size(Xtest, 3); 

%% Train
h = face_size(1);
w = face_size(2);
c = 1; % Grayscale images have one channel. RGB color images have three channels

Xtrain = reshape(Xtrain, [h, w, c, N_train]);

Xtest = reshape(Xtest, [h, w, c, N_test]);

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
    'MaxEpochs', 6, ...               % How many epochs to train.
    'Shuffle', 'every-epoch', ...     % Shuffle the training data every epoch.
    'Verbose', true);              % Show the progress of the training process.
       % Plot diagrams of the training process.

net = trainNetwork(Xtrain, Ytrain, layers, options);

%% Test

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

% Display the misclassified images
if isempty(idxs) ~= 1
    figure;
    grid_cols = 10;
    grid_rows = ceil(size(idxs,1)/10);

    for i = 1:size(idxs,1)
        subplot(grid_rows,grid_cols,i);
        imshow(Xtest(:,:,:,idxs(i)),[]);
        title(strcat('pred:', string(Ypred(idxs(i))), ' true:', string(Ytest(idxs(i)))));
    end
end