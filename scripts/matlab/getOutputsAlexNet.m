clear
clc
addpath('/home/sphere/gait_cnn/Caffe/caffe/matlab')
%load('/home/sphere/gait_cnn/datasets/scripts/scripts/sequenceLengths.mat');
% caffe.set_mode_gpu();
% caffe.set_device(0);
caffe.set_mode_cpu();

gaitAlexNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjustedProperManifold/finetunedS1/train_valTest.prototxt';
gaitAlexNetWeights = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjustedProperManifold/finetunedS1/a_iter_22500.caffemodel';
gaitAlexNet = caffe.Net(gaitAlexNetModel,gaitAlexNetWeights, 'test');

%SeqLengths:[217;155;67;156;152;171;99;47;174;74;173;57;50;92;65;108;117;91;1;270;169;112;125;211;115;116;34;102;197;167;281;65;1;181;210;77;120;1;199;172;215;233;114;94;101;259;157;207]
%numberOfFramesInSequence =125;%S8 n2
%numberOfFramesInSequence =211;%S8 stopX2
numberOfFramesInSequence = 67 %s2n1


labels=[];
predictions = [];
frameNumbers = [];
for i=1:(67)
    gaitAlexNet.forward_prefilled();
    
    label = gaitAlexNet.blobs('label').get_data()
    labels=[labels;label.'];
    
    alexNetPrediction = gaitAlexNet.blobs('fc8').get_data()
    predictions=[predictions;alexNetPrediction.'];
    
    imgNum =  gaitAlexNet.blobs('imgNum').get_data()
    frameNumbers = [frameNumbers;imgNum];

end

frameNumber=[1:numberOfFramesInSequence];
save('/home/sphere/gait_cnn/Caffe/caffe/gait/matlab/alexNetCoherentManifoldResults/Subject1_Normal3_finetuned22500its', 'frameNumbers','predictions', 'labels');