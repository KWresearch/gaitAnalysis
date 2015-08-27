function [  ] = createHdf5SetFINALWithNums(folder,filename, imgData, labels,imgNumber )
filename = strcat(filename, '.h5');


addpath('/home/sphere/gait_cnn/datasets/scripts/scripts');
cd(folder);


created_flag=false;
totalct=0;
numLabels = size(labels,2)
numImgs = size(imgData,4)
numNums = size(imgNumber,2)
num_total_samples=numLabels
chunksz=floor(num_total_samples);
if(num_total_samples~=0)
    for batchno=1:num_total_samples/chunksz
      fprintf('batch no. %d\n', batchno);
      last_read=(batchno-1)*chunksz;

      % to simulate maximum data to be held in memory before dumping to hdf5 file 
      batchdata=imgData(:,:,:,last_read+1:last_read+chunksz); 
      batchlabs=labels(:,last_read+1:last_read+chunksz);
      batchImgNums = imgNumber(last_read+1:last_read+chunksz);
      % store to hdf5
      startloc=struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1], 'num', [1,totalct+1]);
      curr_dat_sz=store2hdf5WithNums(filename, batchdata, batchlabs,batchImgNums, ~created_flag, startloc, chunksz); 
      created_flag=true;% flag set so that file is created only once
      totalct=curr_dat_sz(end);% updated dataset size (#samples)
    end
h5disp(filename);
end

