addpath(genpath(code_directory));
addpath(genpath(data_directory));
addpath(genpath(training_directory));

%% Train CNNs
% takes 5- 10 mins
cnn_training;

%% Train GoogleNet

% requires the googlenet pack from the matlab addons
% WARNING trainig takes more than an hour....cnn.mat contains a pretrained
% version
googleNet_training;

%% Train SqueezNet
% requires the squeezenet pack from the matlab addons
% WARNING trainig takes more than an hour.... cnn.mat contains a pretrained
% version
squeezeNet_training;

%% Train Adaboost
% takes 5 mins or less
adaboost_training;

