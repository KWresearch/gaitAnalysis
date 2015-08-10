function[meanImage]=computeMeanImageSP(sequencesForTesting)
	disp('Computing mean image...')
    load('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet/selected_skeletons.mat');
	n=0;
    trainSetSize=0
	sumImage=[];
    for f=1:length(sequence_names)
        if(any(sequencesForTesting == f));
            continue;
        end
        sequenceName = sequence_names{f}
        sequencePath=strcat(img_dir,'/', sequenceName);
        sequenceDir=[sequencePath];
        imsPath=strcat(sequencePath, '/quickFilled/extractedFGadjusted');%'/quickFilled/extractedFG'); %
        imsDir= [imsPath];
        
	    imNames = cellstr(strsplit(ls(imsPath))); %careful if command window is wider than 1 file name, order will be wrong
	    [imNames, indexs] = sort_nat(imNames);%sorts to correct order
	    fileBeginsLine = 0;
        for f2=1:f-1
            fileBeginsLine = fileBeginsLine + length(line_numbers{f2});
        end
        %numberOfImages=length(imNames)
       % lengthOfLine_numbers= length(line_numbers{f})
        
	    for i=2:length(imNames)%careful : ls has a / file name, which can be first or last depending on sort
	        
            n=n+1;
	        imagePath=strcat(imsPath, '/', imNames{i});
	        
	        start_index = strfind( imNames{i}, '_')+1;
	        end_index = strfind( imNames{i}, '.')-1;
	        imageNumber = sscanf(imNames{i}(start_index:end_index), '%d', 1);
	      % disp(imageNumber)
	        lineNumberValue=imageNumber-file_offsets(f)+1;
            lineNumber = find(line_numbers{f}==lineNumberValue);
	        highLevelFeaturesLineNumber = fileBeginsLine + lineNumber;
            disp(highLevelFeaturesLineNumber);
	        featureData = high_level_features(highLevelFeaturesLineNumber,1:3);	        
	        
	        img = imread(imagePath);
	        img = imresize(img, [227 227]);
	    
	        if(1)
                trainSetSize=trainSetSize+1;
	            if(isempty(sumImage))
	               sumImage = im2double(img);
	            else 
	               sumImage = sumImage + im2double(img);
	            end
	        end
	       end
	       end
  meanImage = sumImage./trainSetSize;
  
  meanImageUint8 = uint8(meanImage.*255);
  
  imwrite(meanImage, '/home/sphere/gait_cnn/datasets/staircase/meanTrainImageDouble.png');
  imwrite(meanImageUint8, '/home/sphere/gait_cnn/datasets/staircase/meanTrainImageUint8.png');

end