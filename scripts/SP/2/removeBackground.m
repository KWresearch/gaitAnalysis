clear 
clc
addpath('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet');
load('/home/sphere/gait_cnn/datasets/scripts/scripts/testingSet/selected_skeletons.mat');
cd('/home/sphere/gait_cnn/datasets/staircase/video_training');
kept = 0;
total = 0;
disc = 0;
width_25a=[];
width_5a=[];
width_75a =[];
width2a =[];
shouldersStartRowa=[];
shouldersStartFraca=[];
for f=1:length(sequence_names)
    sequenceName = sequence_names{f}
    sequencePath=strcat(img_dir,'/', sequenceName);
    sequenceDir=[sequencePath];
    imsPath=strcat(sequencePath, '/','quickFilled');
    imsDir= [imsPath];
    masksPath=strcat(imsPath, '/processedMasks');
    masksDir=[masksPath];
    
    resPath=strcat(imsPath,'/extractedFGadjusted');
    mkdir(resPath)
    numFrames = length(line_numbers{f});
    for i=1:length(line_numbers{f})
        total = total +1; 
        if(f==19 || f==33)
            disc = disc +1;
            continue;
        end
        
        image_number=line_numbers{f}(i)+file_offsets(f)-1;
        if(f==1 && image_number>=102 && image_number<=116)
               disc = disc +1;
               continue;
        end
        if(f==5 && image_number>=88 && image_number<=118)
               disc = disc +1;
               continue;
        end
         if(f==6 && image_number>=61 && image_number<=115)
               disc = disc +1;
               continue;
        end
        if(f==7 && (image_number==190 || (image_number>=1 && image_number<=157)))
                disc = disc +1;
                continue;
        end
        if(f==9 && image_number<=204)
               disc = disc +1;
               continue;
        end
        if(f==38 && image_number==426)
                disc = disc +1;
                continue;
        end
        if(f==25 && ( image_number>=169 && image_number<=181))
                disc = disc +1;

                continue;
        end
        if(f==10 && image_number>=408)
            disc = disc +1;
 
            continue;
        end
         if(f==22 && image_number==259)
            disc = disc +1;
 
            continue;
        end
        if(f==9 &&( image_number==369 || image_number>=396))
            disc = disc +1;
            continue;
        end
         if(f==36 &&( image_number==241 || image_number==245 ||image_number==246))
            disc = disc +1;
            continue;
         end
        if(f==24 &&( image_number==219 || image_number>=398 ))
            disc = disc +1;
            continue;
        end
        if(f==11 && image_number>=291)
            disc = disc +1;
            continue;
        end
        if(f==26 && image_number>=270 && image_number<=273)
            disc = disc +1;
            continue;
        end
        if(f==39 && image_number==353)
            disc = disc +1;
            continue;
        end
        if(f==38 && ((image_number>=427 && image_number<=433) || image_number<=437))
            disc = disc +1;
            continue;
        end
        imagePath=strcat(imsPath,'/qFilled_', sprintf('%03d',image_number), '.png' );
        if exist(imagePath, 'file')==2 && ~isempty(strfind( imagePath, '.png'))
            img = imread(imagePath);
        else
            disp('missing file');
            disp(imagePath);
            disc = disc +1;

            continue;
        end
        maskPath = strcat(masksPath, '/mask_', sprintf('%03d',image_number), '.png' );
        mask = imread(maskPath);
        savePath = strcat(resPath, '/depth_',  sprintf('%03d',image_number), '.png');
        %foreground = applyMask(img, mask);
        foreground = applyMask(img, mask);
       
        if(foreground~=-1)
            %disp(image_number);
            imshow(foreground);
            pause(0.01);
            imwrite(foreground,savePath);
            kept = kept+1;
    
        else
            disc = disc +1 ; 
        end
        
        %imshow(foreground);
       % pause(0.004);
    end
end
disp(total);
disp(disc);
disp(kept);
nbins = 50;
disp('shouldersStartRow');
hist(shouldersStartRowa,nbins);
pause;

disp('shouldersStartFrac');
hist(shouldersStartFraca,nbins);
pause;

disp('2*headhight');
hist(width2a,nbins);
pause;

disp('.25*headhight');
hist(width_25a,nbins);
pause;

disp('.5*headhight');
hist(width_5a,nbins);
pause;

disp('.75*headhight');
hist(width_75a,nbins);
