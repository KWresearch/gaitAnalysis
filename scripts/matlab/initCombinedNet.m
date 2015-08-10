clear
clc
addpath('/home/sphere/gait_cnn/Caffe/caffe/matlab')
caffe.set_mode_cpu();

compoundNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/combined/train_val.prototxt';
compoundNet = caffe.Net(compoundNetModel, 'train');



%First, get weights from the (regression) finetuned alexNet, to sub into
%the regression branch.
gaitAlexNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/train_val.prototxt';
gaitAlexNetWeights = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/a_iter_80000.caffemodel';
gaitAlexNet = caffe.Net(gaitAlexNetModel,gaitAlexNetWeights, 'train');

%params , 1 is weights 2 is biases
compoundNet.params('regressor-conv1',1).set_data(gaitAlexNet.params('conv1',1).get_data());
compoundNet.params('regressor-conv1',2).set_data(gaitAlexNet.params('conv1',2).get_data());

compoundNet.params('regressor-conv2',1).set_data(gaitAlexNet.params('conv2',1).get_data());
compoundNet.params('regressor-conv2',2).set_data(gaitAlexNet.params('conv2',2).get_data());

compoundNet.params('regressor-conv3',1).set_data(gaitAlexNet.params('conv3',1).get_data());
compoundNet.params('regressor-conv3',2).set_data(gaitAlexNet.params('conv3',2).get_data());

compoundNet.params('regressor-conv4',1).set_data(gaitAlexNet.params('conv4',1).get_data());
compoundNet.params('regressor-conv4',2).set_data(gaitAlexNet.params('conv4',2).get_data());

compoundNet.params('regressor-conv5',1).set_data(gaitAlexNet.params('conv5',1).get_data());
compoundNet.params('regressor-conv5',2).set_data(gaitAlexNet.params('conv5',2).get_data());



%Now, get weights from the finetuned legClassifier, to sub into
%the detector branch.
classificationNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/train_valTest.prototxt';
classificationNetWeights = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/a_iter_60000.caffemodel';
classificationNet = caffe.Net(classificationNetModel,classificationNetWeights, 'train');

compoundNet.params('detector-conv1',1).set_data(classificationNet.params('conv1',1).get_data());
compoundNet.params('detector-conv1',2).set_data(classificationNet.params('conv1',2).get_data());

compoundNet.params('detector-fc1',1).set_data(classificationNet.params('fc1',1).get_data());
compoundNet.params('detector-fc1',2).set_data(classificationNet.params('fc1',2).get_data());

compoundNet.params('detector-fc2',1).set_data(classificationNet.params('fc2',1).get_data());
compoundNet.params('detector-fc2',2).set_data(classificationNet.params('fc2',2).get_data());






solver = caffe.Solver('/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/combined/solver.prototxt');
solver.net = classificationNet;
solver.solve();
disp('1');







