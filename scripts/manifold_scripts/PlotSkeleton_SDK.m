function PlotSkeleton_SDK(shape)

DrawIdx{1} = [1,2,9];
DrawIdx{2} = [2,3,5,7];
DrawIdx{3} = [2,4,6,8];
DrawIdx{4} = [9,10,12,14];
DrawIdx{5} = [9,11,13,15];

%hold off
for k = 1:length(DrawIdx)
    if(k==3)
            plot3(shape(DrawIdx{k},1),shape(DrawIdx{k},2),-shape(DrawIdx{k},3),'r','LineWidth',2);
    else
            plot3(shape(DrawIdx{k},1),shape(DrawIdx{k},2),-shape(DrawIdx{k},3),'k','LineWidth',2);

    end
    hold on
end

end