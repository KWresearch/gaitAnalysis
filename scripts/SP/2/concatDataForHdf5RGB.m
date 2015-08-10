clear 
clc
addpath('/space/data_to_backup/Ben/data');
load('selected_skeletons.mat');

cd('/space/data_to_backup/Ben/data');
files = cellstr(strsplit(ls('/space/data_to_backup/Ben/data/video_training'))); %careful if command window is wider than 1 file name, order will be wrong
fileOffsets = [102,111,174,171,88,81,141,106,185,321,113,230,134,120,212,140,133];
fileID = fopen('staircaseData.txt','w');

addpath('/space/data_to_backup/Ben/caffe/matlab/caffe/hdf5creation');

n=0;
trainImgData=[];
trainLabel=[];
valImgData=[];
valLabel=[];

for f=1:length(sequence_names)
    sequenceName = files{f}
    sequencePath=strcat('/space/data_to_backup/Ben/data/video_training/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath, '/', sequenceName, '_quickFill/','extractedFG3channelDepth/');
    imsDir = [imsPath];
   
    imNames = cellstr(strsplit(ls(imsPath))); %careful if command window is wider than 1 file name, order will be wrong
    [imNames, inds]= sort_nat(imNames);
    fileBeginsLine = 0;
        for f2=1:f-1
            fileBeginsLine = fileBeginsLine + length(line_numbers{f2});
        end
    for i=1:length(imNames)
        n=n+1;
        disp(imNames{i})
        imagePath=strcat(imsPath, '/', imNames{i});
        
        start_index = strfind( imNames{i}, '_')+1;
        end_index = strfind( imNames{i}, '.')-1;
        imageNumber = sscanf(imNames{i}(start_index(1):end_index), '%d', 1);
        lineNumber=imageNumber-fileOffsets(f)+1;
        highLevelFeaturesLineNumber = fileBeginsLine + lineNumber;
        featureData = high_level_features(highLevelFeaturesLineNumber,1:3);
        imgSubPath = strcat(sequenceName,'/quickFilled/','extractedFGMeanBG/',imNames{i});
       % str = sprintf('%s %f %f %f \n',imgSubPath ,featureData(1), featureData(2), featureData(3))
        
        
        d1chan = imread(imagePath);
        d3chan = repmat(d1chan,[1 1 3]);
        img = imresize(d3chan, [227 227]);
        if(mod(n, 13)==0) 
            if(isempty(valImgData) )
               valImgData = img;
            else 
               valImgData = cat(4,valImgData, img);
            end
            if(isempty(valLabel))
                valLabel= featureData.';
            else
                valLabel = cat(2, valLabel, featureData.');
            end
        else
            if(isempty(trainImgData)) 
                trainImgData = img;
            else 
                trainImgData = cat(4,trainImgData, img);
            end 
            if(isempty(trainLabel))
                trainLabel = featureData.';
            else
                trainLabel = cat(2, trainLabel, featureData.');
            end
        end

    end
end

fclose(fileID);
save('concatDatasets.mat');