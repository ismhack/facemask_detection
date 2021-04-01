% Note: This code requires the Matlab Deep Learning Toolbox
%
% Before you run this code, make sure that you are in the right directory.
%
% First, download the zip files containing code and data for this unit, from 
% the lectures web page (accessible from the course website).
% 
% Second, unzip the zip files.
%
% Third, modify the addpath and cd commands in the beginning of the code,
% to reflect the locations of code and data on your computer
%
% Now you can copy lines from this script file and paste them to Matlab's
% command window.

%%

% The addpath and cd lines are the only lines in the code that you may have
% to change, in order to make the rest of the code work. Adjust
% the paths to reflect the locations where you have stored the code 
% and data in your computer.

restoredefaultpath;
clear all;
close all;

addpath C:\Users\vangelis\Files\Academia\Teaching\TxState\CS7323-Spr2021\Lectures\Code\13_cnns
addpath C:\Users\vangelis\Files\Academia\Teaching\TxState\CS7323-Spr2021\Lectures\Data\13_cnns
cd C:\Users\vangelis\Files\Academia\Teaching\TxState\CS7323-Spr2021\Lectures\Data\13_cnns

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%         Beginning of CNNs code
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all;

load_mnist;

% Display some of the images in the dataset.
figure;
for i = 1:20
    subplot(4, 5, i);
    imshow(mnist_digits(:, :, i));
end

%% We will split our data into a training and test set (70/30 percent split)

Xtrain = mnist_digits(:, :, 1:7000);
Ytrain = mnist_labels(1:7000);

Xtest = mnist_digits(:, :, 7001:end);
Ytest = categorical(mnist_labels(7001:end));


%% Prepare data for input to the convolutional neural network

% Expected input for 2-D images: A h-by-w-by-c-by-N numeric array, 
% where h, w, and c are the height, width, and number of channels of the 
% images, respectively, and N is the number of images.
% See https://www.mathworks.com/help/deeplearning/ref/nnet.cnn.layer.imageinputlayer.html

% To comply with the expected input requirements, our data will need to be
% reshaped from [h, w, N] dimensions to [h, w, c, N] dimensions.

h = size(Xtrain, 1);
w = size(Xtrain, 2);
c = 1; % Grayscale images have one channel. RGB color images have three channels

N_train = size(Xtrain, 3); % number of training samples

Xtrain = reshape(Xtrain, [h, w, c, N_train]);
Ytrain = categorical(Ytrain); % Labels need to be converted
                              % to categorical values
                              
N_test = size(Xtest, 3);  % number of test samples

Xtest = reshape(Xtest, [h, w, c, N_test]);
Ytest = categorical(Ytest); % Labels need to be converted
                              % to categorical values

%% Define the convolutional neural network architecture

% Hyperparameters:
%
% For Convolutional Neural Networks neural network there are numerous 
% hyperparameters to specify. The most important are the following:
%
% Number of convolution filters - Obviously too few filters cannot extract 
% enough features to achieve classification. However, more filters are 
% helpless when the filters are already enough to represent the relevant 
% features, and make the training more computationally expensive.
% 
% Convolution filter size and initial values - Smaller filters collect as 
% much local information as possible, bigger filters represent more global, 
% high level and representative information. The filters are usually 
% initialized with random values.
%
% Batch normalization is a technique for training very deep neural networks 
% that standardizes the inputs to a layer for each mini-batch. This has the 
% effect of stabilizing the learning process and dramatically reducing the 
% number of training epochs required to train deep networks.
%
% Pooling method and size - As already mentioned, there are two types of 
% pooling: Max Pooling and Average Pooling, and Max Pooling usually performs 
% better since it works also as noise suppressant. Also the pooling size is 
% an important parameter to be optimized, since if the the pooling size 
% increases, the dimension reduction is greater, but more informations are lost.
%
% Activation function - Activation function introduces non-linearity to the 
% model. Rectifier, sigmoid or hyperbolic tangent are usually chosen.
%
% Number of epochs - Number of epochs is the the number of times the entire
% training set pass through the model. This number should be increased 
% until we no further improvements in accuracy.

layers = [
    imageInputLayer([h w c]) % Dimensions of a single input image.
    
    convolution2dLayer(3, 8, 'Padding','same') % 1st convolutional layer.
    batchNormalizationLayer                    % Batch normalization.
    reluLayer                                  % ReLU activation. 
    
    maxPooling2dLayer(2, 'Stride', 2)          % Max pooling.
    
    convolution2dLayer(3, 16, 'Padding', 'same')% 2nd convolutional layer.
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2, 'Stride', 2)
    
    convolution2dLayer(3, 32, 'Padding', 'same')% 3rd convolutional layer.
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer];

% Show a summary of the layers
layers

%% Specify Training Options

options = trainingOptions('sgdm', ... % Stochastic gradient descent with momentum.
    'InitialLearnRate', 0.01, ...     % Learning rate.
    'MaxEpochs', 4, ...               % How many epochs to train.
    'Shuffle', 'every-epoch', ...     % Shuffle the training data every epoch.
    'Verbose', true, ...              % Show the progress of the training process.
    'Plots', 'training-progress');    % Plot diagrams of the training process.

%% Train Network Using Training Data

net = trainNetwork(Xtrain, Ytrain, layers, options);


%% Classify Test Images and Compute Accuracy

% Predict the labels of the test data using the trained network, and 
% calculate the final test accuracy. 

Ypred = classify(net, Xtest); % Predict labels of test data.

probY = predict(net, Xtest); % this wil return prediction probabilities for
                             % each class instead of a class label.
                             % This can be useful when we want to know how
                             % confident the classifier is about each class.
                             
                             

% Accuracy is the fraction of labels that the network predicts correctly. 
% In this case, about 97% of the predicted labels match the 
% true labels of the test set.
accuracy = sum(Ypred == Ytest)/numel(Ytest)

% Compute confusion matrix
C = confusionmat(Ytest, Ypred);
C % show confusion matrix as text

% Plot a basic confusion matrix chart
figure; confusionchart(C); % or confusionchart(Ytest, Ypred);

% Plot a more detailed confusion matrix chart
figure; plotconfusion(Ytest, Ypred);


%% 

% Just for fun: find which samples were missclassified

idxs = find(Ypred ~= Ytest);
comaprison = [Ypred(idxs), Ytest(idxs)];

% Display the misclassified images
figure;
grid_cols = 10;
grid_rows = ceil(size(idxs,1)/10);

for i = 1:size(idxs)
    subplot(grid_rows,grid_cols,i);
    imshow(Xtest(:,:,idxs(i)));
    title(strcat('pred:', string(Ypred(idxs(i))), ' true:', string(Ytest(idxs(i)))));
end