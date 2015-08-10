
dataDir=['/space/data_to_backup/Ben/data/video_training/Subject1_Normal2/']
resDir=[dataDir 'Subject1_Normal2_cleaned']
mkdir(resDir);
for imageNumber=5:58
    cleanImage(imageNumber, dataDir, resDir,4);
end