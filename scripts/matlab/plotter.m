clear 
clc
load('/home/sphere/gait_cnn/Caffe/caffe/gait/matlab/alexNetCoherentManifoldResults/Subject1_Normal3_finetuned.mat');

figure
subplot(3,1,1);
plot(frameNumbers,labels(:,1));
subplot(3,1,2);
plot(frameNumbers,labels(:,2));
subplot(3,1,3);
plot(frameNumbers,labels(:,3));

figure
subplot(3,1,1);
plot(frameNumbers,alexNetPredictions(:,1));
subplot(3,1,2);
plot(frameNumbers,alexNetPredictions(:,2));
subplot(3,1,3);
plot(frameNumbers,alexNetPredictions(:,3));

figure

subplot(4,1,1);
plot(frameNumbers,classificationNetPredictions(:,1));
subplot(4,1,2);
plot(frameNumbers,classificationNetPredictions(:,2));
subplot(4,1,3);
plot(frameNumbers,classificationNetPredictions(:,3));
subplot(4,1,4);
plot(frameNumbers,lrClass(:,1),frameNumber,lrClass(:,2));
