clear 
clc
close all
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts');
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/Manifold_scritps');
%datapath = '/home/sphere/gait_cnn/datasets/staircase/rawSkeletones'% all
%training only:
datapath = '/home/sphere/gait_cnn/datasets/staircase/bgresiy3olk41nilo7k6xpkqf/Shared_dataset_BMVC2014_stairs_gait/stairs_gait_BMVC2014_skeleton_only/training_data/full_sequences'; 
imNames = cellstr(strsplit(ls(datapath)));
%liste = dir(['/home/sphere/gait_cnn/datasets/staircase/bgresiy3olk41nilo7k6xpkqf/Shared_dataset_BMVC2014_stairs_gait/stairs_gait_BMVC2014_skeleton_only/testing_data/Subject' '*.txt'])
[list, inds] = sort_nat(imNames);%sorts to correct order

for i=2:length(list)
    list_names{i-1}=cellstr(strcat(datapath,'/', list(i)));
end
list_names2 = [list_names{:}];

%list_names = cell2mat(list_names);
prepare_models_FINAL(list_names2,[],1,9,'procrustes','joint_position',3,1,0.03,1,1,'manifoldAlldata',1)

     