function [  ] = createHdf5SetSP(setNum, trainImgData, trainLabel ,testImgData,testLabel, valImgData, valLabel)
trainSet = strcat(' ', setNum, '.h5');
valSet = strcat('valMeanBG', setNum, '.h5');
testSet = strcat('testMeanBG', setNum, '.h5');

addpath('/home/sphere/gait_cnn/datasets/scripts/scripts');
cd('/home/sphere/gait_cnn/Caffe/caffe/gait/datasets/227_adjusted_NOmeanSub/legBinary');
created_flag=false;
totalct=0;
numLabels = size(trainLabel,2)
numImgs = size(trainImgData,4)
num_total_samples=size(trainLabel,2);
chunksz=floor(num_total_samples);
if(num_total_samples~=0)
    for batchno=1:num_total_samples/chunksz
      fprintf('batch no. %d\n', batchno);
      last_read=(batchno-1)*chunksz;

      % to simulate maximum data to be held in memory before dumping to hdf5 file 
      batchdata=trainImgData(:,:,:,last_read+1:last_read+chunksz); 
      batchlabs=trainLabel(:,last_read+1:last_read+chunksz);

      % store to hdf5
      startloc=struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
      curr_dat_sz=store2hdf5(trainSet, batchdata, batchlabs, ~created_flag, startloc, chunksz); 
      created_flag=true;% flag set so that file is created only once
      totalct=curr_dat_sz(end);% updated dataset size (#samples)
    end
h5disp(trainSet);
end



created_flag=false;
totalct=0;
numLabels = size(testLabel,2)
numImgs = size(testImgData,4)
num_total_samples=size(testLabel,2);
chunksz=floor(num_total_samples);
if(num_total_samples~=0)
    for batchno=1:num_total_samples/chunksz
      fprintf('batch no. %d\n', batchno);
      last_read=(batchno-1)*chunksz;

      % to simulate maximum data to be held in memory before dumping to hdf5 file 
      batchdata=testImgData(:,:,:,last_read+1:last_read+chunksz); 
      batchlabs=testLabel(:,last_read+1:last_read+chunksz);

      % store to hdf5
      startloc=struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
      curr_dat_sz=store2hdf5(testSet, batchdata, batchlabs, ~created_flag, startloc, chunksz); 
      created_flag=true;% flag set so that file is created only once
      totalct=curr_dat_sz(end);% updated dataset size (#samples)
    end
    h5disp(testSet);
end



created_flag=false;
totalct=0;
numLabels = size(valLabel,2)
numImgs = size(valImgData,4)
num_total_samples=size(valLabel,2);
chunksz=floor(num_total_samples/3);
if(num_total_samples~=0)
    for batchno=1:num_total_samples/chunksz
      fprintf('batch no. %d\n', batchno);
      last_read=(batchno-1)*chunksz;

      % to simulate maximum data to be held in memory before dumping to hdf5 file 
      batchdata=valImgData(:,:,:,last_read+1:last_read+chunksz); 
      batchlabs=valLabel(:,last_read+1:last_read+chunksz);

      % store to hdf5
      startloc=struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
      curr_dat_sz=store2hdf5(valSet, batchdata, batchlabs, ~created_flag, startloc, chunksz); 
      created_flag=true;% flag set so that file is created only once
      totalct=curr_dat_sz(end);% updated dataset size (#samples)
    end
    h5disp(valSet);
end