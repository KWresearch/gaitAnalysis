function prepare_models_part1(training_data_filenames, list_frames, smoothing, windowSize, alignment_type, feature_type, numDim, use_kNN, robust_coef, LBcoef, Nsteps, manifold_filename, periodic)

nb_seq = length(training_data_filenames);

raw_data = [];
T = [];
low_level_features = [];

preprocessor = Preprocessing(smoothing, windowSize, alignment_type, feature_type);

for s=1:nb_seq
    % reading data
    data = load(char(training_data_filenames(s)));
    S = data(:,2:end);
    P = (size(S,2))/4; % #joint points
    idx = reshape(1:P*4,4,P);
    index = reshape(idx(2:4,:),3*P,1);
    r_data = S(1:end,index);
    
    % extract low-level features
    [new_features,selection] = preprocessor.preprocess(r_data);
    
    % select frames to be used to build the models (i.e. reject noisy outliers)
    if strcmp(feature_type, 'joint_velocity') == 1
        selection = selection(2:end);
    end
    
    if strcmp(alignment_type, 'procrustes') == 0
        % At the moment, only Procrustes alignment provides a selection of valid frames. Other methods must have user defined selections.
        frames = load(char(list_frames(s)));
        selection = frames(1):frames(2);
    end
    
    raw_data = [raw_data; r_data(selection,:)];
    T = [T; data(selection,1)];
    low_level_features = [low_level_features; new_features(selection,:)];
    
%     plot_skeletons(r_data(frames(1):frames(2),:))
%     plot_skeletons(new_features(frames(1):frames(2),:))
end

clear data
clear S
clear P
clear idx
clear index
clear raw_data
clear preprocessor

% build manifold
high_level_features = build_manifold(low_level_features, numDim, use_kNN, robust_coef, LBcoef, Nsteps, manifold_filename);

clear low_level_features

% build dynamics model (part 1)
[X_training, Y_training, indexes_training, nb_cycles] = find_cycles(high_level_features, T);
save('training.mat','X_training','Y_training','indexes_training');

disp('Now run the following python script:');
sprintf('./pdf_estimations.py %d %d bw step',numDim,periodic)
disp('(Requires the Python library scikit_learn)');
disp('0.09 is a good guess for "bw" for the BMVC2014 training dataset')
disp('"step" is the step size of the grid on which the pdf is pre-computed. A small value requires more RAM. 80 was used in our experiments in 3D.')

disp('When done, run prepare_models_part2');

end