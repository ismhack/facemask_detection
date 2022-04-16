
%% data split
h = 100;
w = 100;
c = 3; 
trainingSet = imageDatastore('data/cnn/training', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
testSet = imageDatastore('data/cnn/testing', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);

tbl = countEachLabel(trainingSet)

augmentedTrainingSet = augmentedImageDatastore([h w c], trainingSet);%,'ColorPreprocessing', 'rgb2gray');%'DataAugmentation',imageAugmenter); %'
augmentedTestSet = augmentedImageDatastore([h w c], testSet);%, 'ColorPreprocessing', 'rgb2gray');

minibatch = read(augmentedTrainingSet);
figure (2);imshow(imtile(minibatch.input));


minibatch = read(augmentedTestSet);
figure(3);imshow(imtile(minibatch.input));
%% Train

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
    'InitialLearnRate', 0.0001, ...     % Learning rate.
    'MaxEpochs', 30, ...               % How many epochs to train.
    'MiniBatchSize',128, ...
    'Shuffle', 'once', ...     % Shuffle the training data every epoch.
    'Verbose', true);              % Show the progress of the training process.
       % Plot diagrams of the training process.

%net = trainNetwork(Xtrain, Ytrain, layers, options);
net = trainNetwork(augmentedTrainingSet, layers, options);

disp('CNN training complete');
