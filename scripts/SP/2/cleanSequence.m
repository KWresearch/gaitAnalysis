function [] = cleanSequence(sequenceName, lineNumbers, lineOffset)
%close all
%clear all
%clc
dataPath=strcat('/space/data_to_backup/Ben/data/video_training/', sequenceName)
dataDir=[dataPath]
currentDirectory=cd(dataDir) 
addpath(currentDirectory);
manualSelection=0;
saveOK=1;

resDir=strcat(dataPath,'/', sequenceName, '_cleaned')
mkdir(resDir)


numberOfIterations=4;
for i=1:length(lineNumbers)
    %%LOAD IMAGE AND RANGE DETERMINATION....
    imageNumber=lineNumbers(i)+lineOffset-1
    if(i>(3*length(lineNumbers)/4)) 
        numberOfIterations = 7
    end
    cleanImage(imageNumber, dataDir, resDir,numberOfIterations);
end
end