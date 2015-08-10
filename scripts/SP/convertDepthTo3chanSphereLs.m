clear 
clc
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/selected_skeletons.mat');
video_trainingPath = '/home/sphere/gait_cnn/datasets/staircase/video_training';
cd(video_trainingPath);
%files = cellstr(strsplit(ls('/space/data_to_backup/Ben/data/video_training'))); %careful if command window is wider than 1 file name, order will be wrong
files = {'Subject1_Normal1','Subject1_Normal2','Subject1_Normal3','Subject2_Normal1','Subject2_Normal2','Subject2_Normal3','Subject3_Normal1','Subject3_Normal2','Subject4_Normal1','Subject4_Normal2','Subject4_Normal3','Subject5_Normal1','Subject5_Normal2','Subject5_Normal3','Subject6_Normal1','Subject6_Normal2','Subject6_Normal3'};

for f=1:length(files)
    sequenceName = files{f}
    sequencePath=strcat(video_trainingPath,'/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath, '/', sequenceName, '_quickFill/','extractedFGMeanBG');
    imsDir = [imsPath]
    resPath = strcat(sequencePath, '/', sequenceName, '_quickFill/meanBG3channelDepth');
    resDir =[resPath];
    mkdir(resDir);
    imNames = cellstr(strsplit(ls(imsPath))); %careful if command window is wider than 1 file name, order will be wrong
  
    for i=1:length(imNames)-1
        disp(imNames{i})
        imagePath=strcat(imsPath, '/', imNames{i});
        d1chan = imread(imagePath);
        d3chan = repmat(d1chan,[1 1 3]);
        savePath = strcat(resPath,'/',imNames{i});
        imwrite(d3chan, savePath);

    end
end
