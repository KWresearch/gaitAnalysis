function[shuffledTrainImgData, shuffledTrainLabel ]= shuffleData(trainImgData, trainLabel)
disp('Shuffling data..')
numTrainLabels=size(trainLabel,2)
numTrainImgs=size(trainImgData,4)
n=size(trainLabel,2);



inds = randperm(n);

shuffledTrainImgData=[];
shuffledTrainLabel=[];


for i=1:n
  
	ind = inds(i);
	img = trainImgData(:, :, :,ind);
    %imshow(img);
   % pause
	label = trainLabel(:, ind);
	 if(isempty(shuffledTrainImgData)) 
         shuffledTrainImgData = img;
     else 
         shuffledTrainImgData = cat(4,shuffledTrainImgData, img);
     end 
     if(isempty(shuffledTrainLabel))
         shuffledTrainLabel = label;
     else
         shuffledTrainLabel = cat(2, shuffledTrainLabel, label);
     end
end
end