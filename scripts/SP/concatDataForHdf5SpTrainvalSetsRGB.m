clear 
clc
load('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet/selected_skeletons.mat');

addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet');
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/sphereComp');

setSizer=13;%take every setSizer+1 image for the validation set 
 n=0;
sequencesForTesting = [35:42]
trainImgData=[];
trainLabel=[];
valImgData=[];
valLabel=[];
testImgData=[];
testLabel=[];
%change this to recompute mean if setSizer changes
meanTrainingImage = computeMeanImageSpRGB(setSizer,sequencesForTesting);
%meanTrainingImage =imread('/home/sphere/gait_cnn/datasets/staircase/meanTrainImageUint8.png');
%meanTrainingImage =imread('/home/sphere/gait_cnn/datasets/staircase/meanTrainImageDouble.png');
imshow(meanTrainingImage);
setNum = 1;
disp('Concatenating data...');
for f=1:18%length(sequence_names)
    if(any(sequencesForTesting == f))
        continue;
    end

    sequenceName = sequence_names{f}
    
    sequencePath=strcat(img_dir,'/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath, '/extractedFgRGB');
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
        imgDouble = im2double(img)-meanTrainingImage;
        imgDoubleCentred = imgDouble+0.5;
        img = uint8(imgDoubleCentred.*255);
   
        %savepath = strcat(sequencePath,'/meanBG2273chan');
       % mkdir(savepath);
        %savepath = strcat(savepath,'/',imNames{i});
       % imwrite(img,savepath);
        if(any(sequencesForTesting == f))
            if(isempty(testImgData) )
               testImgData = img;
            else 
               testImgData = cat(4,testImgData, img);
            end
            if(isempty(testLabel))
                testLabel= featureData.';
            else
                testLabel = cat(2, testLabel, featureData.');
            end
        elseif(mod(n, setSizer)==0) 
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
    [shuffledTrainImgData, shuffledTrainLabel ]=shuffleData(trainImgData, trainLabel );
    createHdf5SetSP(sequenceName, shuffledTrainImgData, shuffledTrainLabel ,testImgData,testLabel, valImgData, valLabel)
    setNum=setNum+1;
    trainImgData=[];
    trainLabel=[];
    valImgData=[];
    valLabel=[];
    testImgData=[];
    testLabel=[];
%[shuffledTrainImgData, shuffledTrainLabel ]=shuffleData(trainImgData, trainLabel );
%save('/home/sphere/gait_cnn/datasets/staircase/concatDatasetsSetSizer12.mat');
%createHdf5SetSP( num2str(setNum), shuffledTrainImgData, shuffledTrainLabel ,testImgData,testLabel, valImgData, valLabel)

%createHdf5SetSP(trainImgData,trainLabel,valImgData,valLabel);
