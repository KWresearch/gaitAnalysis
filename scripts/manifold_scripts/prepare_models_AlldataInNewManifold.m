function prepare_models_AlldataInNewManifold(training_data_filenames, list_frames, smoothing, windowSize, alignment_type, feature_type, numDim, use_kNN, robust_coef, LBcoef, Nsteps, manifold_filename, periodic)
% training_data_filenames : list of filenames
% list_frames : first and last frames to be used. Only used when Procrustes
%   alignment is not used.
%periodic : binary - 1 = periodic movement, 0 = non-periodic
%% arguments for preprocessor
% smoothing : 1 for smoothing of skeleton coordinates (recommended), 0 otherwise
% windowSize : size of window
% alignment_type : string that indicates the type of alignment to use for the
%   skeletons. Choices available: procrustes, torso_scaling, none.
% feature_type : string that indicates the type of features to extract from
%   the skeleton. Choices available: angles, joint_position,
%   joint_velocity, pairwise_relative_positions, pairwise_relative_angles
% the skeleton alignment types recommended per feature extraction type are:
% 'procrustes' + 'joint_position'
% 'procrustes' + 'joint_velocity'
% 'none + 'pairwise_relative_angles'
% 'torso_scaling' + 'pairwise_relative_positions'
%% arguments for manifold
% numDim : number of dimension of the manifold
% use_kNN : binary - 1 recommended
% robust_coef : weight of the robust extension - around 0.01 is fine
% LBcoef : 1 for Laplace-Beltrami
% Nsteps : 1 is fine
% manifold_filename : name under which the manifold should be saved

nb_seq = length(training_data_filenames);

raw_data = [];
T = [];
low_level_features = [];
flipped_low_level_features = [];
file_names = [];
line_numbers = [];
isNormalSeqNonFlipped = [];
preprocessor = Preprocessing(smoothing, windowSize, alignment_type, feature_type);

for s=1:nb_seq
    % reading data
    data = load(char(training_data_filenames(s)));
    S = data(:,2:end);
    P = (size(S,2))/4; % #joint points
    idx = reshape(1:P*4,4,P);
    index = reshape(idx(2:4,:),3*P,1);
    
    r_data = S(1:end,index);
    r_data_size = size(r_data,1);

    flipped_r_data = flipX_low_level_features(r_data);
    r_data_with_flipped = [r_data;flipped_r_data];
   % plot_skeletons(r_data);
    % extract low-level features
    [new_features,selection] = preprocessor.preprocess(r_data_with_flipped);
    
    % select frames to be used to build the models (i.e. reject noisy outliers)
    if strcmp(feature_type, 'joint_velocity') == 1
        selection = seAClection(2:end);
    end
    
    if strcmp(alignment_type, 'procrustes') == 0
        % At the moment, only Procrustes alignment provides a selection of valid frames. Other methods must have user defined selections.
        frames = load(char(list_frames(s)));
        selection = frames(1):frames(2);
    end
    
    shape = reshape(low_level_features(10,:),3,15)';
    PlotSkeleton_SDK(shape);
    pause;
    shape = reshape(flipped_low_level_features(10,:),3,15)';
    PlotSkeleton_SDK(shape);
    
%    raw_data = [raw_data; r_data(selection,:)];
   % T = [T; data(selection,1)];
    newLowLvlFeatNonFlipped = new_features(1:r_data_size,:);
    newLowLvlFeatNonFlipped = newLowLvlFeatNonFlipped( selection(1:r_data_size), : );
    
    newLowLvlFeatFlipped = new_features(r_data_size+1:end,:);
    newLowLvlFeatFlipped = newLowLvlFeatFlipped( selection(r_data_size+1:end), : );


    %flippedNewLowLvlFeat = flipX_low_level_features(newLowLvlFeat);
    
    low_level_features = [low_level_features; newLowLvlFeatNonFlipped];
    flipped_low_level_features = [flipped_low_level_features; newLowLvlFeatFlipped];
    
   % plot_skeletons(low_level_features);
    %file_names = [file_names; char(training_data_filenames(s))];
    
    selection = selection(1:length(selection)/2);
    
    all_lines = 1:length(selection);
    selected_lines = all_lines(selection);
    line_numbers{s} = selected_lines;
    isNormal = strfind( training_data_filenames(s), 'Normal')
     if(~isempty(isNormal{1}))
         disp(training_data_filenames(s));
        seqFlag = logical(ones(size(newLowLvlFeatNonFlipped,1),1));
     else 
         seqFlag = logical(zeros(size(newLowLvlFeatNonFlipped,1),1));
     end
     isNormalSeqNonFlipped = [isNormalSeqNonFlipped; seqFlag];

    
%     plot_skeletons(r_data(frames(1):frames(2),:))
%     plot_skeletons(new_features(frames(1):frames(2),:))
end

clear data
clear S
clear P
clear idx
clear index
%clear raw_data
clear preprocessor

% build manifold

%Manifold = Manifold('/home/sphere/gait_cnn/datasets/scripts/scripts/Manifold_scritps/manifold.mat');
flippedAndUnflippedFeat = [low_level_features; flipped_low_level_features];

high_level_features = build_manifold(flippedAndUnflippedFeat, numDim, use_kNN, robust_coef, LBcoef, Nsteps, manifold_filename);
training_data_filenames = training_data_filenames;
line_numbers = line_numbers;
low_level_features = low_level_features;
%save('selected_skeletons_allTogether','low_level_features','high_level_features','training_data_filenames','line_numbers')

figure,
hold on
%tmp=1:length(isNormalSeqNonFlipped);
%tmp2 = tmp(isNormalSeqNonFlipped);
isNormalSeqNonFlipped = isNormalSeqNonFlipped == 1;
plot3(high_level_features(isNormalSeqNonFlipped,1),high_level_features(isNormalSeqNonFlipped,2),high_level_features(isNormalSeqNonFlipped,3),'r.')
NisNormalSeqNonFlipped = ~isNormalSeqNonFlipped;
plot3(high_level_features(NisNormalSeqNonFlipped,1),high_level_features(NisNormalSeqNonFlipped,2),high_level_features(NisNormalSeqNonFlipped,3),'.')

% high_level_features_Flipped = build_manifold(flipped_low_level_features, numDim, use_kNN, robust_coef, LBcoef, Nsteps, manifold_filename);
% low_level_features_Flipped = flipped_low_level_features;
% save('selected_skeletons_Flipped','high_level_features_Flipped','low_level_features_Flipped');



disp('saved');

clear low_level_features

% build dynamics model (part 1)
%[X_training, Y_training, indexes_training, nb_cycles] = find_cycles(high_level_features, T);
%save('training.mat','X_training','Y_training','indexes_training');

%disp('Now run the following python script:');
%sprintf('./pdf_estimations.py %d %d bw step',numDim,periodic)
%disp('(Requires the Python library scikit_learn)');
%disp('0.09 is a good guess for "bw" for the BMVC2014 training dataset')
%disp('"step" is the step size of the grid on which the pdf is pre-computed. A small value requires more RAM. 80 was used in our experiments in 3D.')

%disp('When done, run prepare_models_part2');

end