%% Load data
clear;
load('faces1000.mat');
load('nonfaces1000.mat');

%% Divide and Scramble Data by 70/30

faceTrainX = face(:,:, 1:700);
faceTestX = face(:, :, 7001:1000);

nonFaceTrainX = nonface(:, :, 1:700);
nonFaceTestX = nonface(:, :, 701:1000);

trainX = [faceTrainX; nonFaceTrainX];

randomTrain = randperm(1400);
trainY = zeros(1400);
for i = 0:1400
    trainX(:,:,i) = trainX(:,:,randomTrain(i));
    
end
