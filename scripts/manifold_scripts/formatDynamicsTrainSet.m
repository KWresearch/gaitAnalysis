clear
clc
load('dynamics_model_train_data')
 high_level_features = high_level_features_catted(1:2793,:);
 image_numbers1 = image_numbers(1:2793);
 high_level_features_flipped = high_level_features_catted(8254:11047,:);
 image_numbers1_flipped = image_numbers(8254:11046);
save('dynamics_trainsetOnly', 'high_level_features', 'high_level_features_flipped', 'image_numbers1','image_numbers1_flipped');