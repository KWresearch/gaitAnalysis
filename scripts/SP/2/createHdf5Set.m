clear 
clc
addpath('/space/data_to_backup/Ben/data');
cd('/space/data_to_backup/Ben/data');
load('concatDatasets.mat');


chunksz=100;
created_flag=false;
totalct=0;
num_total_samples=size(trainLabel,2)
size(trainImgData,4)
for batchno=1:num_total_samples/chunksz
  fprintf('batch no. %d\n', batchno);
  last_read=(batchno-1)*chunksz;

  % to simulate maximum data to be held in memory before dumping to hdf5 file 
  batchdata=trainImgData(:,:,:,last_read+1:last_read+chunksz); 
  batchlabs=trainLabel(:,last_read+1:last_read+chunksz);

  % store to hdf5
  startloc=struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
  curr_dat_sz=store2hdf5('train.h5', batchdata, batchlabs, ~created_flag, startloc, chunksz); 
  created_flag=true;% flag set so that file is created only once
  totalct=curr_dat_sz(end);% updated dataset size (#samples)
end

h5disp('train.h5');



created_flag=false;
totalct=0;
num_total_samples=size(valLabel,2)
size(valImgData,4)
chunksz=num_total_samples;

for batchno=1:num_total_samples/chunksz
  fprintf('batch no. %d\n', batchno);
  last_read=(batchno-1)*chunksz;

  % to simulate maximum data to be held in memory before dumping to hdf5 file 
  batchdata=valImgData(:,:,:,last_read+1:last_read+chunksz); 
  batchlabs=valLabel(:,last_read+1:last_read+chunksz);

  % store to hdf5
  startloc=struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
  curr_dat_sz=store2hdf5('val.h5', batchdata, batchlabs, ~created_flag, startloc, chunksz); 
  created_flag=true;% flag set so that file is created only once
  totalct=curr_dat_sz(end);% updated dataset size (#samples)
end

h5disp('val.h5');
