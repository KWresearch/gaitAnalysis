function PlotSkeleton_SDK(shape)

DrawIdx{1} = [1,2,9];
DrawIdx{2} = [2,3,5,7];
DrawIdx{3} = [2,4,6,8];
DrawIdx{4} = [9,10,12,14];
DrawIdx{5} = [9,11,13,15];

hold off
figure;
for k = 1:length(DrawIdx)
    plot3(shape(DrawIdx{k},1),shape(DrawIdx{k},2),-shape(DrawIdx{k},3),'k','LineWidth',2);
    hold on
end

end