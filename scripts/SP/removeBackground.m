%clear 
clc
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/selected_skeletons.mat');
video_trainingPath = '/home/sphere/gait_cnn/datasets/staircase/video_training';
cd(video_trainingPath);
files = {'Subject1_Normal1','Subject1_Normal2','Subject1_Normal3','Subject2_Normal1','Subject2_Normal2','Subject2_Normal3','Subject3_Normal1','Subject3_Normal2','Subject4_Normal1','Subject4_Normal2','Subject4_Normal3','Subject5_Normal1','Subject5_Normal2','Subject5_Normal3','Subject6_Normal1','Subject6_Normal2','Subject6_Normal3'};


%files = ['Subject1_Normal1':'Subject1_Normal2':'Subject1_Normal3':\
%'Subject2_Normal1':'Subject2_Normal2':'Subject2_Normal3':\
%'Subject3_Normal1':'Subject3_Normal2':'Subject3_Normal3':\
%'Subject4_Normal1':'Subject4_Normal2':'Subject4_Normal3':\
%'Subject5_Normal1':'Subject5_Normal2':'Subject5_Normal3':\
%'Subject6_Normal1':'Subject6_Normal2':'Subject6_Normal3']

%cellstr(strsplit(ls())); %careful if command window is wider than 1 file name, order will be wrong
fileOffsets = [102,111,174,171,88,81,141,106,185,321,113,230,134,120,212,140,133];

for f=1:length(files)
    sequenceName = files{f}
    sequencePath=strcat(video_trainingPath,'/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath, '/', sequenceName, '_quickFill');
    imsDir= [imsPath]
    masksPath=strcat(imsPath, '/processedMasks');
    masksDir=[masksPath]
    
    resPath=strcat(imsPath,'/extractedFGMeanBG');
    mkdir(resPath)
    for i=1:length(line_numbers{f})
        image_number=line_numbers{f}(i)+fileOffsets(f)-1
        imagePath=strcat(imsPath,'/qFilled_', sprintf('%03d',image_number), '.png' );
        img = imread(imagePath);
        maskPath = strcat(masksPath, '/mask_', sprintf('%03d',image_number), '.png' );
        mask = imread(maskPath);
        savePath = strcat(resPath, '/depth_',  sprintf('%03d',image_number), '.png');
        foreground = applyMask(img, mask);
        if(foreground~=-1)
         %   imshow(foreground);
           % pause(0.005);
            imwrite(foreground,savePath);
        end
        
        %imshow(foreground);
       % pause(0.004);
    end
end