function [ foreground] = applyMaskRGB( image, mask )
[inputRows,inputCols]=size(image);

binaryMask =  im2bw(mask, 0.99);
binMask3chan = repmat(binaryMask,[1 1 3]);
persistent lastMaskSize;
maskRowSums=sum(binaryMask,2);
maskSize = sum(maskRowSums);
if(((maskSize>3*lastMaskSize) & (lastMaskSize>0)) | maskSize<3000 | (maskRowSums(1) & maskRowSums(inputRows)))
   % imshow(image);
    %imshow(mask);
  % pause;
%     width_25 = [];
%     width_5 = [];
%     width_75 = [];
%     width2 = [];
%     shouldersStartRow=[];
%     shouldersStartFrac=[];
    foreground = -1;
    return;
else 
    lastMaskSize=maskSize;
end
foregroundDouble = im2double(image).*binMask3chan;
 
%mean = computeMeanOfNonZeros(foregroundDouble, 0.000001);
%stdD = computeStdDevOfNonZeros(foregroundDouble, 0.000001);
if(maskSize<6000)
    se = strel('disk',10);        
else 
    se = strel('disk',16);        
end
erodedMask = imerode(binaryMask,se);
erodedMask3chan = repmat(binaryMask,[1 1 3]);
%erodedImage=im2double(image).*erodedMask;
%erodedImage=uint8(erodedImage.*((1/max(erodedImage(:)))*255));
%imshow(erodedImage);


meanVal = mean(foregroundDouble(binMask3chan));
stdD = std(foregroundDouble(binMask3chan));
modeV = mean(foregroundDouble(erodedMask3chan));%mode(mode(foregroundDouble(erodedMask)))
%foregroundDouble(foregroundDouble>(meanVal+1.6*stdD))=-100;
foregroundDouble(binMask3chan)=foregroundDouble(binMask3chan)+(0.5-modeV);

%adjust background value:
adjustedMeanVal = mean(foregroundDouble(foregroundDouble>0));
adjStdD = std(foregroundDouble(foregroundDouble>0));
setBGto = adjustedMeanVal-1*adjStdD;
foregroundDouble(foregroundDouble<=0)=setBGto;


se = strel('disk',3);        
foregroundDouble = imdilate(foregroundDouble,se);
foregroundDouble = imerode(foregroundDouble,se);


foreground =uint8(foregroundDouble.*255); %uint8(foregroundDouble.*((1/max(foregroundDouble(:)))*255));
%meanUint = computeMeanOfNonZeros(foreground, 1)
%imshow(foreground);
%foreground = uint8(foregroundDouble);
index_fg = find(binaryMask == 1);

[Ycoords,Xcoords]=ind2sub(size(binaryMask), index_fg);
minX = min(Xcoords);
minY = min(Ycoords);
maxX = max(Xcoords);
maxY = max(Ycoords);

while(((maxX-minX)/(maxY-minY)-0.504)>0.01 && minY>1 && maxY<inputRows)
    maxY=maxY+1;
    minY=minY-1;
end

while(((maxX-minX)/(maxY-minY)-0.504)<-0.01 && minX>1 && maxX<inputCols)
    maxX=maxX+1;
    minX=minX-1;
end
oldFG = foreground;
foreground = foreground(minY:maxY, minX:maxX,:);

%imshow(binaryMask(minY:maxY, minX:maxX));
%pause;
binaryMask = binaryMask(minY:maxY, minX:maxX);
height= maxY-minY;
width = maxX-minX;
maskRowSums=sum(binaryMask,2);
%from typical human proportions:
headSize = height/7.5;
% width_25 = maskRowSums(floor(headSize*0.25))/width;
% width_5 = maskRowSums(floor(headSize*0.5))/width;
% width_75 = maskRowSums(floor(headSize*0.75))/width;
% width2 = maskRowSums(floor(headSize*2))/width;
 shouldersStartRow=1;
     shouldersStartFrac=1;
for r = 1:height
    %disp(r);
   % disp(maskRowSums(r)/(maxX-minX));
    if(maskRowSums(r)/width > 0.65)
        shouldersStartRow = r;
        %foreground(r,:) = 255;
        shouldersStartFrac = r/height;
        break;
    end
end
if(shouldersStartFrac<0.22)
    missingFrac = 0.22-shouldersStartFrac;
    missingRows = floor(missingFrac*height);
    incWidthBy = 0.5*(height + missingRows) - width;
    foreground = imresize(foreground, [height width+incWidthBy]);
    [rows, cols,chans] = size(foreground);
   % disp(height+missingRows-(missingRows+1));
   % disp(width);
    newFG(1:missingRows,1:cols,1:chans) = setBGto*255;
    newFG(missingRows+1:rows+missingRows,1:cols,1:chans) = foreground(1:rows,1:cols,1:chans);
    foreground = uint8(newFG);
    %[rows, cols] = size(foreground);
    %disp(cols/rows);
end


    
%meanAll = mean(foreground(:));
% if(meanAll>130 || meanAll<120)
%     foreground = -1;
%     return
% end
%imshow(t2);
%pause(0.1);

%persistent cWidth;
%persistent cHeight;
%persistent n;
%width = maxX-minX;
%height = maxY-minY;
%if(isempty(cWidth))
 %   cWidth=0;
  %  cHeight=0;
  %  n=0;
%end
%cWidth = cWidth + width
%cHeight = cHeight + height
%n = n+1
%values over whole dataset were :
%ave Height = 334.11
%aveWidth = 168.45
%ratio=0.5041752716171321

%imshow(t1);
%pause;
%indMaxX = find(Xcoords==max(Xcoords));
%indMaxy = find(Ycoords==max(Ycoords));

%[Xsort, ind_Xsort]=sort(Xcoords); 
%selectInd = ind_Xsort(1:end/4);
%selX = Xcoords(selectInd);
%selY = Ycoords(selectInd);


%topOfImage = foregroundDouble .* 0;
%topOfImage(selX, selY) = foregroundDouble(selX, selY);
%imshow(topOfImage);

end

