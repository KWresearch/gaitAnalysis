clear 
clc
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/Manifold_scritps/getSelectedSkeletons/selected_skeletons_training_withLowLvlFeat.mat');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/Manifold_scritps/getSelectedSkeletons/selected_skeletons_testing_wtLowLvlFeat.mat');

high_level_features = cat(1, high_level_features_train, high_level_features_test);
line_numbers = cat(2, line_numbers_train, line_numbers_test); 
raw_data = cat(1, raw_data_train, raw_data_test);
low_level_features = cat(1, low_level_features_train, low_level_features_test);

file_names2 = cellstr(strsplit(ls('/home/sphere/gait_cnn/datasets/staircase/video_training')));
[file_names2, inds] = sort_nat(file_names2);%sorts to correct order
file_offsets = [102,111,174,171,88,81,141,106,185,321,113,230,134,120,212,140,133,218,66,71,309,139,113,176,137,193,217,179,177,248,165,188,133,119,127,179,207,295,172,111,160,127,156,148,137,125,159,123];
total=0
for i=1:length(line_numbers)
    total = total +length(line_numbers{i})
end
sequence_names = file_names2(2:end);
img_dir = '/home/sphere/gait_cnn/datasets/staircase/video_training';
save('/home/sphere/gait_cnn/datasets/scripts/scripts/selected_skeletons.mat', 'sequence_names', 'img_dir','high_level_features', 'low_level_features', 'line_numbers', 'raw_data','file_offsets' );