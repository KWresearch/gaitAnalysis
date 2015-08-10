clear
clc
load('/home/sphere/gait_cnn/Caffe/caffe/gait/matlab/alexNetCoherentManifoldResults/Subject1_Normal3_finetuned22500its');

figure
subplot(3,1,1);
plot(frameNumbers,labels(:,1),'r--',frameNumbers,predictions(:,1),'b--');
% Create ylabel
ylabel({'Y[0]'});

subplot(3,1,2);
plot(frameNumbers,labels(:,2),'r--',frameNumbers,predictions(:,2),'b--');

ylabel({'Y[1]'});

subplot(3,1,3);
plot3 =plot(frameNumbers,labels(:,3),'r--',frameNumbers,predictions(:,3),'b--');
% Create ylabel
ylabel({'Y[2]'});

% Create xlabel
xlabel({'Frame Number'});

set(plot3(1),'Color',[1 0 0],'DisplayName','Label');
set(plot3(2),'Color',[0 0 1],'DisplayName','Network Prediction');

% Create legend
legend1 = legend(plot3,'show');
set(legend1,...
    'Position',[0.783855716765866 0.0156312670099353 0.124674479166667 0.0530217717717718]);