clear 
clc
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet/selected_skeletons.mat');

for f=18:length(sequence_names)
    disp(sequence_names{f});
    dataPath=strcat(img_dir,'/', sequence_names{f});
    currentDirectory=cd(dataPath);

    resDir=strcat(dataPath,'/', sequence_names{f}, '_quickFillAllFrames/');
    mkdir(resDir)
    images =cellstr(strsplit(ls()));
    [images,inds] = sort_nat(images);
    for i=1:length(images)
        imagePath=strcat(dataPath,'/',images{i});
        disp(images{i});
        exists = exist(imagePath, 'file')
        %contPng = strfind( imagePath, '.png')
        if exist(imagePath, 'file')==2 && ~isempty(strfind( imagePath, '.png'))
            img = imread(imagePath);
            filledImage = quickFill(img);
            start_index = strfind( images{i}, '_')+1;
            end_index = strfind( images{i}, '.')-1;
            imageNumber = sscanf(images{i}(start_index(1):end_index), '%d', 1);
            savePath = strcat(resDir, '/qFilled_', sprintf('%03d',imageNumber),'.png');
            imwrite(filledImage, savePath);
        end
    end
end

