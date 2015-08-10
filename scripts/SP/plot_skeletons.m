function plot_skeletons(training_data_for_manifold)

xmin = min(min(training_data_for_manifold(:,1:3:end)));
xmax = max(max(training_data_for_manifold(:,1:3:end)));
ymin = min(min(training_data_for_manifold(:,2:3:end)));
ymax = max(max(training_data_for_manifold(:,2:3:end)));
zmin = min(min(training_data_for_manifold(:,3:3:end)));
zmax = max(max(training_data_for_manifold(:,3:3:end)));

for i=1:size(training_data_for_manifold,1)
    shape = reshape(training_data_for_manifold(i,:),3,15)';
    figure(1);
    PlotSkeleton_SDK(shape);
    plot3(shape(:,1),shape(:,2),-shape(:,3),'r.');
    axis([xmin xmax ymin ymax -zmax -zmin]);
    pause(0.05);
    hold off;
end

end