addpath(genpath(code_directory));
addpath(genpath(data_directory));
addpath(genpath(training_directory));

%% Test facemask detector (adaboost face detector + facemask classifier)
% Evaluates 100 photos - takes around 2 mins
facemask_detector_test;

%% Test CNN classifier only
% takes few minues
cnn_testing;

%% Test Google Net classifier only
% takes few minues
googleNet_testing;

%% Test Squeeze Net classifier only
% takes few minues
squeezeNet_testing;

%% Test Adaboost face detector only
adaboost_testing;

%% Test camera uncomment below line
% requires the matlab camera addon
% test_camera;