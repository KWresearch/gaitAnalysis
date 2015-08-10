load('/home/sphere/gait_cnn/datasets/staircase/concatDatasetsSetSizer12.mat');
numTrainLabels=size(trainLabel,2)
numTrainImgs=size(trainImgData,4)

numTrainLabelsShuffled=size(shuffledTrainLabel,2)
numTrainImgsShuffd=size(shuffledTrainImgData,4)

for i=1:1913
    disp(shuffledTrainLabel(:,i));
    img1=shuffledTrainImgData(:, :, :, i);
    imshow(shuffledTrainImgData(:, :, :, i));
    disp(trainLabel(:,i));
    imgNonShuff=trainImgData(:, :, :, i);
    pause
end
img1=shuffledTrainImgData(:, :, :, 1);
imshow(img1);
pause

img500=shuffledTrainImgData(:, :, :, 500);
imshow(img500);
pause;

img1913=shuffledTrainImgData(:, :, :, 1913);
imshow(img1913);
pause;