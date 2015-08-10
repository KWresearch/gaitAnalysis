
dataDir=['/space/data_to_backup/Ben/data/video_training/Subject1_Normal2/']
resDir=[dataDir 'Subject1_Normal2_cleaned']
for imageNumber=331:343
    cleanImage(imageNumber, dataDir, resDir,4);
end