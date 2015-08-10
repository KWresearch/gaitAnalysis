clear 
clc

% liste of training data
liste = dir(['\\rdsfcifs.acrc.bris.ac.uk\SPHEREIRC\sftp\WP2_DATA_SWAP\BMVC dataset\stairs_gait_BMVC2014_skeleton_only\stairs_gait_BMVC2014\training_data\full_sequences\Subject' '*.txt']);
for i=1:length(liste)
    list_names{i}=strcat('\\rdsfcifs.acrc.bris.ac.uk\SPHEREIRC\sftp\WP2_DATA_SWAP\BMVC dataset\stairs_gait_BMVC2014_skeleton_only\stairs_gait_BMVC2014\training_data\full_sequences\', liste(i).name);
    list_frames{i}=strcat('\\rdsfcifs.acrc.bris.ac.uk\SPHEREIRC\sftp\WP2_DATA_SWAP\BMVC dataset\stairs_gait_BMVC2014_skeleton_only\stairs_gait_BMVC2014\training_data\full_sequences\Selected_frames_', liste(i).name);
end

% 4 implemented combinaisons of skeleton alignment and feature extraction:
% 'procrustes' + 'joint_position'
% 'procrustes' + 'joint_velocity'
% 'none + 'pairwise_relative_angles'
% 'torso_scaling' + 'pairwise_relative_positions'

prepare_models_part1(list_names,list_frames,1,9,'procrustes','joint_position',3,1,0.03,1,1,'manifold',1)