function [ foreground] = applyMask( image, mask )
[inputRows,inputCols]=size(image);

binaryMask =  im2bw(mask, 0.99);
persistent lastMaskSize;
maskRowSums=sum(binaryMask,2);
maskSize = sum(maskRowSums);
if(((maskSize>3*lastMaskSize) & (lastMaskSize>0)) | maskSize<3000 | (maskRowSums(1) & maskRowSums(inputRows)))
   imshow(image);
    imshow(mask);
  pause(0.3);

    foreground = -1;
    return;
else 
    lastMaskSize=maskSize;
end
foregroundDouble = im2double(image).*binaryMask;
 

if(maskSize<6000)
    se = strel('disk',10);        
else 
    se = strel('disk',16);        
end
erodedMask = imerode(binaryMask,se);



meanVal = mean(foregroundDouble(binaryMask));
stdD = std(foregroundDouble(binaryMask));
centreMeanV = mean(foregroundDouble(erodedMask));
foregroundDouble(foregroundDouble>(meanVal+2*stdD))=-100;

foregroundDouble(binaryMask)=foregroundDouble(binaryMask)+(0.5-centreMeanV);


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
height= maxY-minY;
width = maxX-minX;

%here we get rid of bright noise but only in top of image to save lower leg
oldFG = foreground;
foreground = foreground(minY:maxY, minX:maxX);
fgTop = foreground( 1:floor(0.75*height), 1:width);

fgTopDbl = im2double(fgTop);
meanVal = 255*mean(mean(fgTopDbl));
stdD= 255*std(std(fgTopDbl));
threshold = floor((meanVal+11*stdD));
fgTop(fgTop>threshold)=0;
foreground( 1:floor(0.75*height), 1:width) = fgTop;



binaryMask = binaryMask(minY:maxY, minX:maxX);

maskRowSums=sum(binaryMask,2);

    shouldersStartFrac=1;
for r = 1:height
    if(maskRowSums(r)/width > 0.65)
        shouldersStartFrac = r/height;
        break;
    end
end


%set background value
foregroundDouble2 = im2double(foreground);

fgRowSums=sum(foregroundDouble2,2);

binMaskRowSums=sum(binaryMask,2);

meanAtWaist= mean(fgRowSums(floor(height*0.45):floor(height*0.55))./binMaskRowSums(floor(height*0.45):floor(height*0.55)));

setBgTo = 0.82*meanAtWaist*255;
foreground(foreground<=0)=setBgTo;



persistent prevMissingBottomRows;

if(shouldersStartFrac<0.22)
    missingFrac = 0.22-shouldersStartFrac;
    missingRows = floor(missingFrac*height);
    newWidth = 0.504*(height + missingRows) ;
    foreground = imresize(foreground, [height newWidth]);
    [rows, cols] = size(foreground);

    newFG(1:missingRows,1:cols) = setBgTo;
    newFG(missingRows+1:rows+missingRows,1:cols) = foreground(1:rows,1:cols);

    newHeight = height*missingFrac;
    if(~isempty(prevMissingBottomRows))
        newWidth = 0.504*(height + prevMissingBottomRows);
        newFG = imresize(newFG, [height newWidth]);
        [rows, cols] = size(newFG);
        newFG(rows+1:rows+prevMissingBottomRows,1:cols) =  setBgTo;
    end
    foreground = uint8(newFG);
elseif(shouldersStartFrac>0.22 && shouldersStartFrac<0.4 )
    missingFrac = shouldersStartFrac-0.22;
    missingRows = floor(missingFrac*height);
    prevMissingBottomRows = missingRows;
    newWidth = 0.504*(height + missingRows);
    foreground = imresize(foreground, [height newWidth]);
    [rows, cols] = size(foreground);

    newFG(1:rows,1:cols) = foreground(1:rows,1:cols);
    newFG(rows+1:rows+missingRows,1:cols) =  setBgTo;
    foreground = uint8(newFG);
end



 foreground = scaleImage(foreground,meanAtWaist);





end

