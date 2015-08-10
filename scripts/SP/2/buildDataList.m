clear 
clc
addpath('/space/data_to_backup/Ben/data');
load('selected_skeletons.mat');

cd('/space/data_to_backup/Ben/data');
files = cellstr(strsplit(ls('/space/data_to_backup/Ben/data/video_training'))); %careful if command window is wider than 1 file name, order will be wrong
fileOffsets = [102,111,174,171,88,81,141,106,185,321,113,230,134,120,212,140,133];
fileID = fopen('staircaseData.txt','w');


for f=1:length(files)-1
    sequenceName = files{f}
    sequencePath=strcat('/space/data_to_backup/Ben/data/video_training/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath, '/', sequenceName, '_quickFill/','extractedFG');
    imsDir = [imsPath]
   
    imNames = cellstr(strsplit(ls(imsPath))); %careful if command window is wider than 1 file name, order will be wrong
    fileBeginsLine = 0;
        for f2=1:f-1
            fileBeginsLine = fileBeginsLine + length(line_numbers{f2});
        end
    for i=1:length(imNames)-1
        disp(imNames{i})
        imagePath=strcat(imsPath, '/', imNames{i});
        
        start_index = strfind( imNames{i}, '_')+1;
        end_index = strfind( imNames{i}, '.')-1;
        imageNumber = sscanf(imNames{i}(start_index(1):end_index), '%d', 1);
        lineNumber=imageNumber-fileOffsets(f)+1;
        highLevelFeaturesLineNumber = fileBeginsLine + lineNumber
        featureData = high_level_features(highLevelFeaturesLineNumber,1:3);
        imgSubPath = strcat(sequenceName,'/', sequenceName, '_quickFill/','extractedFG3channelDepth/',imNames{i});
        str = sprintf('%s %f %f %f \n',imgSubPath ,featureData(1), featureData(2), featureData(3))
        fprintf(fileID,'%s',str);
        
        % imagePath=strcat(imsPath,'/qFilled_', sprintf('%03d',image_number), '.png' );

    end
end

fclose(fileID);
