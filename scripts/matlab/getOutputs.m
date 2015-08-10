clear
clc
addpath('/home/sphere/gait_cnn/Caffe/caffe/matlab')
% caffe.set_mode_gpu();
% caffe.set_device(0);
caffe.set_mode_cpu();

gaitAlexNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/train_valTest.prototxt';
gaitAlexNetWeights = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/a_iter_80000.caffemodel';
gaitAlexNet = caffe.Net(gaitAlexNetModel,gaitAlexNetWeights, 'test');



withClassificationNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/combined/2/train_valTest.prototxt';
withClassificationNetWeights = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/combined/2/withLowLayerTuning_iter_140000.caffemodel';
classificationNet = caffe.Net(withClassificationNetModel,withClassificationNetWeights, 'test');

%numberOfFramesInSequence =125;%S8 n2
numberOfFramesInSequence =211;%S8 stopX2

labels=[];
alexNetPredictions = [];
classificationNetPredictions = [];
lrClass = [];
for i=1:numberOfFramesInSequence 
    classificationNet.forward_prefilled();
    gaitAlexNet.forward_prefilled();
    
    label = gaitAlexNet.blobs('label').get_data()
    labels=[labels;label.'];
    
    alexNetPrediction = gaitAlexNet.blobs('fc8').get_data()
    alexNetPredictions=[alexNetPredictions;alexNetPrediction.'];
    
    classificationNetPrediction = classificationNet.blobs('final-fc3').get_data()
    classificationNetPredictions=[classificationNetPredictions;classificationNetPrediction.'];
    
    lr = classificationNet.blobs('detector-fc2').get_data()
    lrClass=[lrClass;lr.'];

end

frameNumber=[1:numberOfFramesInSequence];
save('subject8_StopX2', 'frameNumber','alexNetPredictions', 'labels','lrClass', 'classificationNetPredictions');