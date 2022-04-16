%% dataset 

googleNet;

h = ginputSize(1);
w = ginputSize(2);
c = ginputSize(3);

trainingSet = imageDatastore('data/cnn/training', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
testSet = imageDatastore('data/cnn/testing', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);

tbl = countEachLabel(trainingSet)

augmentedTrainingSet = augmentedImageDatastore([h w c], trainingSet);%,'ColorPreprocessing', 'rgb2gray');%'DataAugmentation',imageAugmenter); %'
augmentedTestSet = augmentedImageDatastore([h w c], testSet);%, 

%% use transfer learning googleNet

googleNet;

miniBatchSize = 128;
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',30, ...
    'InitialLearnRate',0.0001, ...
    'Shuffle','once', ...
    'Verbose',true);

gnet = trainNetwork(augmentedTrainingSet,gnetGraph,options);
