%% Load data
clear;
load('faces1000.mat');
load('nonfaces1000.mat');

%% Divide and Scramble Data by 70/30

facesNonFaces = [faces(:); nonfaces(:);];
facesNonFaces = reshape(facesNonFaces,[31,25,2000]);

randomNumbers = randperm(2000);
labels = zeros(2000,1);
for i = 1:2000
    facesNonFaces(:,:,i) = facesNonFaces(:,:,randomNumbers(i));
    if(randomNumbers(i) >1000)
        labels(i) = 0;
    else
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
    
    convolution2dLayer(3, 24,'Stride',2, 'Padding', 'same') % 1st convolutional layer.
    reluLayer
    crossChannelNormalizationLayer(5,'K',1)
    
    maxPooling2dLayer(2, 'Stride', 1,'Padding', 'same')          % Max pooling.
    
    convolution2dLayer(2, 48, 'Stride', 1, 'Padding', 0)% 2nd convolutional layer.
    reluLayer
    crossChannelNormalizationLayer(5,'K',1)
    
    maxPooling2dLayer(1, 'Stride', 1)
    
    convolution2dLayer(3, 126, 'Stride', 1, 'Padding', 1)% 3rd convolutional layer.
    reluLayer
    
    convolution2dLayer(3, 192, 'Stride',1, 'Padding', 1)% 4rd convolutional layer.
    reluLayer
    
    convolution2dLayer(3, 192,'Stride',1, 'Padding', 1)% 5rd convolutional layer.
    reluLayer
     
    maxPooling2dLayer(1, 'Stride', 1)    
    
    fullyConnectedLayer(192)
    reluLayer
    dropoutLayer(0.5)
    
    fullyConnectedLayer(32)
    reluLayer
    dropoutLayer(0.5)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ... % Stochastic gradient descent with momentum.
    'InitialLearnRate', 0.001, ...     % Learning rate.
    'MaxEpochs', 10, ...               % How many epochs to train.
    'Shuffle', 'every-epoch', ...     % Shuffle the training data every epoch.
    'Verbose', true, ...              % Show the progress of the training process.
    'Plots', 'training-progress');    % Plot diagrams of the training process.

net = trainNetwork(Xtrain, Ytrain, layers, options);

%% Test

Ypred = classify(net, Xtest); % Predict labels of test data.

accuracy = sum(Ypred == Ytest)/numel(Ytest)

% Compute confusion matrix
C = confusionmat(Ytest, Ypred);
C % show confusion matrix as text

% Plot a basic confusion matrix chart
figure; confusionchart(C); % or confusionchart(Ytest, Ypred);

% Plot a more detailed confusion matrix chart
figure; plotconfusion(Ytest, Ypred);