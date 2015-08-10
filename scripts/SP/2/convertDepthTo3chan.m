clear 
clc
addpath('/space/data_to_backup/Ben/data');
load('selected_skeletons.mat');

cd('/space/data_to_backup/Ben/data');
files = cellstr(strsplit(ls('/space/data_to_backup/Ben/data/video_training'))); %careful if command window is wider than 1 file name, order will be wrong
for f=1:length(files)-1
    sequenceName = files{f}
    sequencePath=strcat('/space/data_to_backup/Ben/data/video_training/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath, '/', sequenceName, '_quickFill/','extractedFG');
    imsDir = [imsPath]
    resPath = strcat(sequencePath, '/', sequenceName, '_quickFill/extractedFG3channelDepth');
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