sqnet = squeezenet;

sqinputSize = sqnet.Layers(1).InputSize

if isa(sqnet,'SeriesNetwork') 
  sqnetGraph = layerGraph(sqnet.Layers); 
else
  sqnetGraph = layerGraph(sqnet);
end 

numClasses = 2;

learnableLayer = sqnetGraph.Layers(64,1);
outputLayer = sqnetGraph.Layers(68,1);

if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
end
newOutputLayer = classificationLayer
newOutputLayer.Name='output';
sqnetGraph = replaceLayer(sqnetGraph,learnableLayer.Name,newLearnableLayer);
sqnetGraph = replaceLayer(sqnetGraph,outputLayer.Name,newOutputLayer);
