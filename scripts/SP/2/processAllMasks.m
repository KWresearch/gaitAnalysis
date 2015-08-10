

clear 
clc
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet/selected_skeletons.mat');
cd('/home/sphere/gait_cnn/datasets/staircase/video_training');

for f=1:length(sequence_names)
    disp(sequence_names{f});
    dataPath=strcat(img_dir,'/', sequence_names{f},'/masks/');
    dataDir=[dataPath];
    currentDirectory=cd(dataDir);
    addpath(currentDirectory);

    resDir=strcat(img_dir,'/', sequence_names{f}, '/quickFilled/processedMasks');
    mkdir(resDir)
    for i=1:length(line_numbers{f})
        image_number=line_numbers{f}(i)+file_offsets(f)-1;
        imagePath=strcat('mask_qFilled_', sprintf('%03d',image_number) );
        imagePath=strcat(imagePath, '.png');
        if exist(imagePath, 'file')==2 && ~isempty(strfind( imagePath, '.png'))
            img = imread(imagePath);
            processedMask = processMask(img);
            savePath = strcat(resDir, '/mask_', sprintf('%03d',image_number), '.png');
    
            imwrite(processedMask, savePath);
        elseif f<=17 
            copyFrom = strcat('/home/sphere/gait_cnn/datasets/staircase/video_training/',sequence_names{f},'/',sequence_names{f},'_quickFill/processedMasks/mask_',sprintf('%03d',image_number), '.png'); 
            filledImage = imread(copyFrom);
            savePath = strcat(resDir, '/mask_',  sprintf('%03d',image_number), '.png');
            imwrite(filledImage, savePath);
        else
            disp('missing file');
            disp(imagePath);
        end
    end
end