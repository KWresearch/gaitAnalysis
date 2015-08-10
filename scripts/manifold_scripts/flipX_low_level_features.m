function[flipped_low_level_features]=flipX_low_level_features(low_level_features)
%plot_skeletons(low_level_features);
%shape = reshape(low_level_features(10,:),3,15)';
%PlotSkeleton_SDK(shape);
%pause;
flipped_low_level_features_step1=low_level_features;
for joint=1:3:size(low_level_features, 2);
    flipped_low_level_features_step1(:,joint)=low_level_features(:,joint).*-1;
end
flipped_low_level_features_step2 = flipped_low_level_features_step1;

joints_that_need_swapping = [3,5,7,10,12,14];%they always swap with the one after
for joint = joints_that_need_swapping
    joint_position_in_45el = joint*3;
    joint_position_to_swap = (joint+1)*3;
    for xyz=-2:0
        swapping = joint_position_in_45el + xyz;
        flipped_low_level_features_step2(:,swapping)= flipped_low_level_features_step1(:,swapping+3);
        flipped_low_level_features_step2(:,swapping+3)= flipped_low_level_features_step1(:,swapping);
    end
end
flipped_low_level_features=flipped_low_level_features_step2;
% for frame=1:size(low_level_features, 1);
% %     neckPos=low_level_feature(4:6)
% %     torsoPos=low_level_feature(25:27)
%     for joint=1:3:size(low_level_features, 2);
%         low_level_features(frame,joint)=-low_level_features(frame,joint);
%     end
% end
%figure(1)
%hold on
%plot_skeletons(flipped_low_level_features);

%shape = reshape(flipped_low_level_features(10,:),3,15)';
%PlotSkeleton_SDK(shape);
%pause;
%hold off




