n=0;
for i=4:70
    depthPath=strcat('depth_', num2str(i) );
    depthPath=strcat(depthPath, '.png');
    image=imread(depthPath);
    if(n==0) 
         aveBG =im2double(image);
    else 
         aveBG = aveBG+im2double(image);
    end
    n=n+1;
end
aveBG=aveBG./n;
aveBG=aveBG.*((1/max(aveBG(:)))*255)
imwrite(uint8(aveBG),'aveBG.png');
%cleanImage(i,'/space/data_to_backup/Ben/data/video_training/Subject1_Normal1','/space/data_to_backup/Ben/data/video_training/bgsTestFrames')
