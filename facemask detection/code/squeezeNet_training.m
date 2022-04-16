%% dataset 
h = 227;
w = 227;
c = 3;

trainingSet = imageDatastore('data/cnn/training', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
testSet = imageDatastore('data/cnn/testing', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);

tbl = countEachLabel(trainingSet)

augmentedTrainingSet = augmentedImageDatastore([h w c], trainingSet);%,'ColorPreprocessing', 'rgb2gray');%'DataAugmentation',imageAugmenter); %'
augmentedTestSet = augmentedImageDatastore([h w c], testSet);%, 

%% use transfer learning squeezenet

squeezenet;

miniBatchSize = 128;
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',30, ...
    'InitialLearnRate',0.0001, ...
    'Shuffle','once', ...
    'Verbose',true);

sqnet = trainNetwork(augmentedTrainingSet,sqNetGraph,options);


disp('Training SqueezeNet Complete');