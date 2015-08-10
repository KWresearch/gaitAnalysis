clear
clc
addpath('/home/sphere/gait_cnn/Caffe/caffe/matlab')
model_dir = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/homemade/5';
net_model = [model_dir '/train_valTest.prototxt'];
%net_weights = [model_dir '/reducedLR_iter_85000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)

caffe.set_mode_cpu();
net = caffe.Net(net_model, phase);
%net = caffe.Net(net_model, net_weights, phase);
c1MaxA=[];
c1MinA=[];
c2MaxA=[];
c2MinA=[];
p1MaxA=[];
p1MinA=[];
fc6MaxA=[];
fc6MinA=[];
fc7MaxA=[];
fc7MinA=[];
c1MaxUpdateA=[];
c1MinUpdateA=[];
c2MaxUpdateA=[];
c2MinUpdateA=[];
p1MaxUpdateA=[];
p1MinUpdateA=[];
fc6MaxUpdateA=[];
fc6MinUpdateA=[];
fc7MaxUpdateA=[];
fc7MinUpdateA=[];
for i=1:200
    net.forward_prefilled();
    net.backward_prefilled();

    img = uint8(mat2gray(net.blobs('data').get_data()).*255);
    imshow(img ,[0 255]);

    conv1 = net.blobs('conv1').get_data();
    c1Diff = net.blobs('conv1').get_diff();
    conv2 = net.blobs('conv2').get_data();
    c2Diff = net.blobs('conv2').get_diff();
    pool1 = net.blobs('pool1').get_data();
    p1Diff = net.blobs('pool1').get_diff();
    fc6 = net.blobs('fc6').get_data();
    fc6Diff = net.blobs('fc6').get_diff();
    fc7 = net.blobs('fc7').get_data();
    fc7Diff = net.blobs('fc7').get_diff();


    varConv1 = var(var(var(conv1)))
    varConv2 = var(var(var(conv2)))
    varPool1 = var(pool1)
    varFc6 = var(fc6)
    varFc7 = var(fc7)

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

    p1Updates= p1Diff.*pool1;
    maxPool1 = max(pool1)
    minPool1 = min(pool1)
    p1MaxUpdate = max(max(max(p1Updates)))
    p1MinUpdate = min(min(min(p1Updates)))

    fc6Updates= fc6Diff.*fc6;
    maxfc6 = max(fc6)
    minfc6 = min(fc6)
    fc6MaxUpdate = max(max(max(fc6Updates)))
    fc6MinUpdate = min(min(min(fc6Updates)))

    fc7Updates= fc7Diff.*fc7;
    maxfc7 = max(fc7)
    minfc7 = min(fc7)
    fc7MaxUpdate = max(max(max(fc7Updates)))
    fc7MinUpdate = min(min(min(fc7Updates)))
    
end

%fc7Diff = net.blobs(