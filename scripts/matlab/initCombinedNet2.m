clear
clc
addpath('/home/sphere/gait_cnn/Caffe/caffe/matlab')
caffe.set_mode_gpu();
caffe.set_device(0);

solver = caffe.Solver('/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/combined/2/solver.prototxt');

%First, get weights from the (regression) finetuned alexNet, to sub into
%the regression branch.
gaitAlexNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/train_val.prototxt';
gaitAlexNetWeights = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/adjusted_IMG/withoutMeanSub/a_iter_80000.caffemodel';
gaitAlexNet = caffe.Net(gaitAlexNetModel,gaitAlexNetWeights, 'train');

%params , 1 is weights 2 is biases


%Now, get weights from the finetuned legClassifier, to sub into
%the detector branch.
classificationNetModel = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/train_valTest.prototxt';
classificationNetWeights = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/legDetectingSubNet/1/a_iter_60000.caffemodel';
classificationNet = caffe.Net(classificationNetModel,classificationNetWeights, 'train');



solver.net.params('regressor-conv1',1).set_data(gaitAlexNet.params('conv1',1).get_data());
solver.net.params('regressor-conv1',2).set_data(gaitAlexNet.params('conv1',2).get_data());

solver.net.params('regressor-conv2',1).set_data(gaitAlexNet.params('conv2',1).get_data());
solver.net.params('regressor-conv2',2).set_data(gaitAlexNet.params('conv2',2).get_data());

solver.net.params('regressor-conv3',1).set_data(gaitAlexNet.params('conv3',1).get_data());
solver.net.params('regressor-conv3',2).set_data(gaitAlexNet.params('conv3',2).get_data());

solver.net.params('regressor-conv4',1).set_data(gaitAlexNet.params('conv4',1).get_data());
solver.net.params('regressor-conv4',2).set_data(gaitAlexNet.params('conv4',2).get_data());

solver.net.params('regressor-conv5',1).set_data(gaitAlexNet.params('conv5',1).get_data());
solver.net.params('regressor-conv5',2).set_data(gaitAlexNet.params('conv5',2).get_data());


solver.net.params('detector-conv1',1).set_data(classificationNet.params('conv1',1).get_data());
solver.net.params('detector-conv1',2).set_data(classificationNet.params('conv1',2).get_data());

solver.net.params('detector-fc1',1).set_data(classificationNet.params('fc1',1).get_data());
solver.net.params('detector-fc1',2).set_data(classificationNet.params('fc1',2).get_data());

solver.net.params('detector-fc2',1).set_data(classificationNet.params('fc2',1).get_data());
solver.net.params('detector-fc2',2).set_data(classificationNet.params('fc2',2).get_data());





solver.solve();
disp('1');







