clear 
clc

%load('/home/sphere/gait_cnn/datasets/scripts/scripts/Manifold_scritps/getSelectedSkeletons/selected_skeletons_WithFlipped_Final.mat');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/Manifold_scritps/getSelectedSkeletons/labelData_trainingOnlyManifold');
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet');
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/sphereComp');

 n=0;
 
file_names2 = cellstr(strsplit(ls('/home/sphere/gait_cnn/datasets/staircase/video_training')));
[file_names2, inds] = sort_nat(file_names2);%sorts to correct order
file_offsets = [102,111,174,171,88,81,141,106,185,321,113,230,134,120,212,140,133,218,66,71,309,139,113,176,137,193,217,179,177,248,165,188,133,119,127,179,207,295,172,111,160,127,156,148,137,125,159,123];

sequence_names = file_names2(2:end);
img_dir = '/home/sphere/gait_cnn/datasets/staircase/video_training';
sequencesForTesting = [];%[22,23,24];

sequncesExcluded =[25:34];%[18:24];%[7:11];%[1:6];%[35:48];%[35:48];%s34[7,8,9,10,11];%[25,26,27,28,29,30,31,32,33,34];%s7s8[18,19,20,21,22,23,24]  %s3s4[7,8,9,10,11];%s1s2[1,2,3,4,5,6];

resDir = '/media/EA8EC36A8EC32DBF/ben/trainingOnlyManifold/s9s10Test';

trainImgData=[];
trainLabel=[];
trainImgNum = [];

trainImgDataFlipped=[];
trainLabelFlipped=[];
trainImgNumFlipped = [];

meanTrainingImage = [];%computeMeanImageSP(sequncesExcluded);
%imshow(meanTrainingImage);
%pause;
%meanTrainingImage =imread('/home/sphere/gait_cnn/datasets/staircase/meanTrainImageUint8.png');
%meanTrainingImage =imread('/home/sphere/gait_cnn/datasets/staircase/meanTrainImageDouble.png');
setNum = 1;
disp('Concatenating data...');
sequenceLengths=[];
for f=1:length(sequence_names)%sequncesExcluded%1:length(sequence_names)%=sequncesExcluded
     if(any(sequncesExcluded == f) || any(sequencesForTesting==f))
         continue;
     end

    sequenceName = sequence_names{f}applyMask.
    
    sequencePath=strcat(img_dir,'/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath,'/quickFilled/extractedFGadjusted'); %'/quickFilled/extractedFG'); %
    imsDir = [imsPath];
   
    imNames = cellstr(strsplit(ls(imsPath))); %careful if command window is wider than 1 file name, order will be wrong
    [imNames, indexs] = sort_nat(imNames);%sorts to correct order
    fileBeginsLine = 0;
 
    
    for f2=1:f-1
        fileBeginsLine = fileBeginsLine + length(line_numbers{f2});
    end
    for j=2:length(imNames)%careful : ls has a / file name, which can be first or last depending on sort
        
        n=n+1;
        imagePath=strcat(imsPath, '/', imNames{j});
        
        start_index = strfind( imNames{j}, '_')+1;
        end_index = strfind( imNames{j}, '.')-1;
        imageNumber = sscanf(imNames{j}(start_index(1):end_index), '%d', 1);
        lineNumberValue=imageNumber-file_offsets(f)+1;
        lineNumber = find(line_numbers{f}==lineNumberValue);
	    highLevelFeaturesLineNumber = fileBeginsLine + lineNumber;
        featureData = high_level_features(highLevelFeaturesLineNumber,1:3);
       % str = sprintf('%s %f %f %f \n',imgSubPath ,featureData(1), featureData(2), featureData(3))
        
        
        img = imread(imagePath);
        img = imresize(img, [227 227]);     

        imgDouble = im2double(img);%-meanTrainingImage;
       
        imgDoubleCentred = imgDouble;%+0.5;
        img = uint8(imgDoubleCentred.*255);

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
        trainImgNum = [trainImgNum,imageNumber];
        
        %and the flipped:

        img = flipdim(img ,2);
        featureData = high_level_features_flipped(highLevelFeaturesLineNumber,1:3);

        if(isempty(trainImgDataFlipped)) 
            trainImgDataFlipped = img;
        else 
            trainImgDataFlipped = cat(4,trainImgDataFlipped, img);
        end 
        if(isempty(trainLabelFlipped))
            trainLabelFlipped = featureData.';
        else
            trainLabelFlipped = cat(2, trainLabelFlipped, featureData.');
        end
        trainImgNumFlipped = [trainImgNumFlipped,imageNumber];

    end     
% 
%     createHdf5SetFINALWithNums(resDir,sequenceName, trainImgData, trainLabel, trainImgNum );
%      trainImgData=[];
%      trainLabel=[];
%        trainImgNum=[];
%        
%        
%     flipsFilename = strcat(sequenceName, '_flipped');
%     
%     createHdf5SetFINALWithNums(resDir,flipsFilename, trainImgDataFlipped, trainLabelFlipped, trainImgNumFlipped );
%      trainImgDataFlipped=[];
%      trainLabelFlipped=[];
%         trainImgNumFlipped=[];

   
end
    trainImgData = cat(4,trainImgData,trainImgDataFlipped);
    trainLabel = cat(2, trainLabel, trainLabelFlipped);
    
    [shuffledTrainImgData, shuffledTrainLabel]=shuffleData(trainImgData, trainLabel );
    createHdf5SetFINAL(resDir,'allDataExceptS9S10', shuffledTrainImgData, shuffledTrainLabel );

% % 
% % 
%     
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    