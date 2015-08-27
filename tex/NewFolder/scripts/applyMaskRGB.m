function [ foreground] = applyMaskRGB( image, mask )
[inputRows,inputCols]=size(image);

binaryMask =  im2bw(mask, 0.99);
binMask3chan = repmat(binaryMask,[1 1 3]);
persistent lastMaskSize;
maskRowSums=sum(binaryMask,2);
maskSize = sum(maskRowSums);
if(((maskSize>3*lastMaskSize) & (lastMaskSize>0)) | maskSize<3000 | (maskRowSums(1) & maskRowSums(inputRows)))
    foreground = -1;
    return;
else 
    lastMaskSize=maskSize;
end
foregroundDouble = im2double(image).*binMask3chan;

if(maskSize<6000)
    se = strel('disk',10);        
else 
    se = strel('disk',16);        
end
erodedMask = imerode(binaryMask,se);
erodedMask3chan = repmat(binaryMask,[1 1 3]);


meanVal = mean(foregroundDouble(binMask3chan));
stdD = std(foregroundDouble(binMask3chan));
modeV = mean(foregroundDouble(erodedMask3chan));
foregroundDouble(binMask3chan)=foregroundDouble(binMask3chan)+(0.5-modeV);

%adjust background value:
adjustedMeanVal = mean(foregroundDouble(foregroundDouble>0));
adjStdD = std(foregroundDouble(foregroundDouble>0));
setBGto = adjustedMeanVal-1*adjStdD;
foregroundDouble(foregroundDouble<=0)=setBGto;


se = strel('disk',3);        
foregroundDouble = imdilate(foregroundDouble,se);
foregroundDouble = imerode(foregroundDouble,se);


foreground =uint8(foregroundDouble.*255); 
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

binaryMask = binaryMask(minY:maxY, minX:maxX);
height= maxY-minY;
width = maxX-minX;
maskRowSums=sum(binaryMask,2);


     shouldersStartFrac=1;
for r = 1:height
    if(maskRowSums(r)/width > 0.65)
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
    newFG(1:missingRows,1:cols,1:chans) = setBGto*255;
    newFG(missingRows+1:rows+missingRows,1:cols,1:chans) = foreground(1:rows,1:cols,1:chans);
    foreground = uint8(newFG);
end


    


end

