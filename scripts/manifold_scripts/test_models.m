%% liste of testing data
liste = dir(['\\rdsfcifs.acrc.bris.ac.uk\SPHEREIRC\sftp\WP2_DATA_SWAP\BMVC dataset\stairs_gait_BMVC2014_skeleton_only\stairs_gait_BMVC2014\testing_data\Subject' '*.txt']);

%% initialisation
% set display to -1 to disable
display = 7;
interface = Interface_Periodic(1,9,'procrustes','joint_position', 'manifold', 'interpolants_2D', display);
% set initial_alpha = -1 to have it estimated automatically
initial_alpha = -1; %0.025;
sigma_estimation = 7e-3;
sigma_test = 1e-3;
possible_local_minimum = 1;
threshold_pose = -2;
threshold_dynamics = -6;

%% testing
for i=1:length(liste)
    filename = strcat('\\rdsfcifs.acrc.bris.ac.uk\SPHEREIRC\sftp\WP2_DATA_SWAP\BMVC dataset\stairs_gait_BMVC2014_skeleton_only\stairs_gait_BMVC2014\testing_data\', liste(i).name);
    
    interface.process_new_sequence(filename, initial_alpha, sigma_estimation, sigma_test, possible_local_minimum, threshold_pose, threshold_dynamics);
end