function [ foreground] = applyMask( image, mask )
[inputRows,inputCols]=size(image);

binaryMask =  im2bw(mask, 0.99);
persistent lastMaskSize;
maskRowSums=sum(binaryMask,2);
maskSize = sum(maskRowSums);
if(((maskSize>3*lastMaskSize) & (lastMaskSize>0)) | maskSize<3000 | (maskRowSums(1) & maskRowSums(inputRows)))
   % imshow(image);
    %imshow(mask);
  % pause;
    width_25 = [];
    width_5 = [];
    width_75 = [];
    width2 = [];
    shouldersStartRow=[];
    shouldersStartFrac=[];
    foreground = -1;
    return;
else 
    lastMaskSize=maskSize;
end
foregroundDouble = im2double(image).*binaryMask;
 
%mean = computeMeanOfNonZeros(foregroundDouble, 0.000001);
%stdD = computeStdDevOfNonZeros(foregroundDouble, 0.000001);
if(maskSize<6000)
    se = strel('disk',10);        
else 
    se = strel('disk',16);        
end
erodedMask = imerode(binaryMask,se);

%erodedImage=im2double(image).*erodedMask;
%erodedImage=uint8(erodedImage.*((1/max(erodedImage(:)))*255));
%imshow(erodedImage);


meanVal = mean(foregroundDouble(binaryMask));
stdD = std(foregroundDouble(binaryMask));
modeV = mean(foregroundDouble(erodedMask));%mode(mode(foregroundDouble(erodedMask)))
foregroundDouble(foregroundDouble>(meanVal+2*stdD))=-100;

foregroundDouble(binaryMask)=foregroundDouble(binaryMask)+(0.5-modeV);


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


%imshow(binaryMask(minY:maxY, minX:maxX));
%pause;
binaryMask = binaryMask(minY:maxY, minX:maxX);

maskRowSums=sum(binaryMask,2);
%from typical human proportions:
headSize = height/7.5;
width_25 = maskRowSums(floor(headSize*0.25))/width;
width_5 = maskRowSums(floor(headSize*0.5))/width;
width_75 = maskRowSums(floor(headSize*0.75))/width;
width2 = maskRowSums(floor(headSize*2))/width;
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

%adjust background value:

%original:
% adjustedMeanVal = mean(foregroundDouble(foregroundDouble>0));
% adjStdD = std(foregroundDouble(foregroundDouble>0));
% setBGto = adjustedMeanVal;
% foregroundDouble(foregroundDouble<=0)=setBGto;

%

foregroundDouble2 = im2double(foreground);

fgRowSums=sum(foregroundDouble2,2);

binMaskRowSums=sum(binaryMask,2);

meanAtWaist= mean(fgRowSums(floor(height*0.45):floor(height*0.55))./binMaskRowSums(floor(height*0.45):floor(height*0.55)));

setBgTo = 0.82*meanAtWaist*255;
foreground(foreground<=0)=setBgTo;

%foreground(floor(height*0.45),:)=255;
%foreground(floor(height*0.55),:)=255;



persistent prevMissingBottomRows;

if(shouldersStartFrac<0.22)
    missingFrac = 0.22-shouldersStartFrac;
    missingRows = floor(missingFrac*height);
    newWidth = 0.504*(height + missingRows) ;
    foreground = imresize(foreground, [height newWidth]);
    [rows, cols] = size(foreground);
   % disp(height+missingRows-(missingRows+1));
   % disp(width);
    newFG(1:missingRows,1:cols) = setBgTo;
    newFG(missingRows+1:rows+missingRows,1:cols) = foreground(1:rows,1:cols);
    %[rows, cols] = size(foreground);
    %disp(cols/rows)
    newHeight = height*missingFrac;
    if(~isempty(prevMissingBottomRows))
        newWidth = 0.504*(height + prevMissingBottomRows);
        newFG = imresize(newFG, [height newWidth]);
        [rows, cols] = size(newFG);
       % disp(height+missingRows-(missingRows+1));
       % disp(width);
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
   % disp(height+missingRows-(missingRows+1));
   % disp(width);

    newFG(1:rows,1:cols) = foreground(1:rows,1:cols);
    newFG(rows+1:rows+missingRows,1:cols) =  setBgTo;
    foreground = uint8(newFG);
    %[rows, cols] = size(foreground);
    %disp(cols/rows)
end



 foreground = scaleImage(foreground,meanAtWaist);




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

