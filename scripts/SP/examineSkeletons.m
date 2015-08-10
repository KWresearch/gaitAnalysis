clear
clc
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/selected_skeletons.mat');
addpath('/home/sphere/gait_cnn/Caffe/caffe/matlab')

model_dir = '/home/sphere/gait_cnn/Caffe/caffe/gait/models/alexNet_meanBG/28thJuly';
net_model = [model_dir '/train_valTest.prototxt'];
net_weights = [model_dir '/0.001/a_iter_50000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)

caffe.set_mode_cpu();
%net = caffe.Net(net_model, phase);
%net = caffe.Net(net_model, net_weights, phase);

f=6;%s2n3 is the 6th file
fileBeginsLine = 0;
for f2=1:f-1
    fileBeginsLine = fileBeginsLine + length(line_numbers{f2});
end
fileEndsLine = fileBeginsLine + length(line_numbers{f});
imNames = cellstr(strsplit(ls('/home/sphere/gait_cnn/datasets/staircase/video_training/Subject2_Normal3/quickFilled/extractedFGMeanBG')));
[imNames, inds] = sort_nat(imNames);%sorts to correct order

hlfs_x =  high_level_features(:,1);
hlfs_y =  high_level_features(:,2);
hlfs_z =  high_level_features(:,3);
% hlfs_x =  high_level_features(fileBeginsLine:fileEndsLine,1);
% hlfs_y =  high_level_features(fileBeginsLine:fileEndsLine,2);
% hlfs_z =  high_level_features(fileBeginsLine:fileEndsLine,3);

frameLineNumbers=[];
frameNumbers=[];
for j=2:length(imNames)%careful : ls has a / file name, which can be first or last depending on sort
    %net.forward_prefilled();
    start_index = strfind( imNames{j}, '_')+1;
    end_index = strfind( imNames{j}, '.')-1;
    imageNumber = sscanf(imNames{j}(start_index(1):end_index), '%d', 1);
    lineNumberValue=imageNumber-file_offsets(f)+1;
    lineNumber = find(line_numbers{f}==lineNumberValue);
    featuresLineNumber = fileBeginsLine + lineNumber;
    
    if(isempty(frameLineNumbers))
        frameLineNumbers=featuresLineNumber;
    else
        frameLineNumbers=cat(1,frameLineNumbers, featuresLineNumber);
    end
    if(isempty(frameNumbers))
        frameNumbers=imageNumber;
    else
        frameNumbers=cat(1,frameNumbers, imageNumber);
    end
end
        figure;
for j=2:length(imNames)%careful : ls has a / file name, which can be first or last depending on sort
    %net.forward_prefilled();
    if(mod(j,10)==0)
        close all
        start_index = strfind( imNames{j}, '_')+1;
        end_index = strfind( imNames{j}, '.')-1;
        imageNumber = sscanf(imNames{j}(start_index(1):end_index), '%d', 1);
        lineNumberValue=imageNumber-file_offsets(f)+1;
        lineNumber = find(line_numbers{f}==lineNumberValue);
        featuresLineNumber = fileBeginsLine + lineNumber;

        high_level_feature = high_level_features(featuresLineNumber,1:3);
        hlf_x =  high_level_feature(1);
        hlf_y =  high_level_feature(2);
        hlf_z =  high_level_feature(3);
        plot(frameNumbers, hlfs_x(frameLineNumbers),imageNumber,hlf_x, 'c*' );
        low_level_feature = low_level_features(featuresLineNumber, 1:45);
        plot_skeletons(low_level_feature);
        pause;
    end
end

 scatter3(hlf_x,hlf_y,hlf_z);
        view(-30,10)

