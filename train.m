% Parameters
dataDir = 'dataset';

% Load dataset
imds = imageDatastore(dataDir, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Check label counts
countEachLabel(imds)

% Split dataset
[imdsTrain, imdsVal] = splitEachLabel(imds, 0.8, 'randomized');

% Define CNN architecture
layers = [
    imageInputLayer([32 32 1], 'Name', 'input')
    convolution2dLayer(3,32,'Padding','same','Name','conv_1')
    batchNormalizationLayer('Name','bn_1')
    reluLayer('Name','relu_1')
    maxPooling2dLayer(2,'Stride',2,'Name','maxpool_1')

    convolution2dLayer(3,64,'Padding','same','Name','conv_2')
    batchNormalizationLayer('Name','bn_2')
    reluLayer('Name','relu_2')
    maxPooling2dLayer(2,'Stride',2,'Name','maxpool_2')

    convolution2dLayer(3,128,'Padding','same','Name','conv_3')
    batchNormalizationLayer('Name','bn_3')
    reluLayer('Name','relu_3')
    maxPooling2dLayer(2,'Stride',2,'Name','maxpool_3')

    fullyConnectedLayer(4,'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classOutput')
];

% Analyze network
analyzeNetwork(layers)

% Training options
options = trainingOptions('adam', ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 16, ...
    'ValidationData', imdsVal, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Train network
net = trainNetwork(imdsTrain, layers, options);
save('trainedModel2.mat', 'net');

% Evaluate network
YPred = classify(net, imdsVal);
YVal = imdsVal.Labels;

% Confusion matrix
figure;
confusionchart(YVal, YPred);
title('Confusion Matrix');
