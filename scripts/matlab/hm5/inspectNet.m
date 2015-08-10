clear
clc
addpath('/home/sphere/gait_cnn/Caffe/caffe/matlab')
model_dir = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/6';
net_model = [model_dir '/train_valTest.prototxt'];
%net_weights = [model_dir '/reducedLR_iter_85000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)

caffe.set_mode_cpu();
net = caffe.Net(net_model, phase);
%net = caffe.Net(net_model, net_weights, phase);
% c1MaxA=[];
% c1MinA=[];
% c2MaxA=[];
% c2MinA=[];
% p1MaxA=[];
% p1MinA=[];
% fc6MaxA=[];
% fc6MinA=[];
% fc7MaxA=[];
% fc7MinA=[];
% c1MaxUpdateA=[];
% c1MinUpdateA=[];
% c2MaxUpdateA=[];
% c2MinUpdateA=[];
% p1MaxUpdateA=[];
% p1MinUpdateA=[];
% fc6MaxUpdateA=[];
% fc6MinUpdateA=[];
% fc7MaxUpdateA=[];
% fc7MinUpdateA=[];
for i=1:2
    net.forward_prefilled();
    net.backward_prefilled();

    img = uint8(mat2gray(net.blobs('data').get_data()).*255);
    imshow(img ,[0 255]);
    c1weights = net.params('conv1',1).get_data();
    conv1 = net.blobs('conv1').get_data();
    c1Diff = net.blobs('conv1').get_diff();
    conv2 = net.blobs('conv2').get_data();
    c2Diff = net.blobs('conv2').get_diff();
    conv3 = net.blobs('conv3').get_data();
    c3Diff = net.blobs('conv3').get_diff();
    fc4 = net.blobs('fc4').get_data();
    fc4Diff = net.blobs('fc4').get_diff();
    fc5 = net.blobs('fc5').get_data();
    fc5Diff = net.blobs('fc5').get_diff();


    varConv1 = var(var(var(conv1)))
    varConv2 = var(var(var(conv2)))
    varConv3 = var(var(var(conv3)))
    varFc4 = var(fc4)
    varFc5 = var(fc5)

    c1Updates= c1Diff.*conv1;
    maxConv1 = max(max(max(conv1)))
    minConv1 = min(min(min(conv1)))
    c1MaxUpdate = max(max(max(c1Updates)))
    c1MinUpdate = min(min(min(c1Updates)))

    c2Updates= c2Diff.*conv2;
    maxConv2 = max(max(max(conv2)))
    minConv2 = min(min(min(conv2)))
    c1MaxUpdate = max(max(max(c1Updates)))
    c1MinUpdate = min(min(min(c1Updates)))

    c3Updates= c3Diff.*conv3;
    maxConv3 = max(max(max(conv3)))
    minConv3 = min(min(min(conv3)))
    c3MaxUpdate = max(max(max(c3Updates)))
    c3MinUpdate = min(min(min(c3Updates)))

    fc4Updates= fc4Diff.*fc4;
    maxfc4 = max(fc4)
    minfc4 = min(fc4)
    fc4MaxUpdate = max(max(max(fc4Updates)))
    fc4MinUpdate = min(min(min(fc4Updates)))

    fc5Updates= fc5Diff.*fc5;
    maxfc5 = max(fc5)
    minfc5 = min(fc5)
    fc5MaxUpdate = max(max(max(fc5Updates)))
    fc5MinUpdate = min(min(min(fc5Updates)))
    
end

%fc7Diff = net.blobs(