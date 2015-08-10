function [processedMask] = processMask(mask)

%imshow(mask);

%pause
CC = bwconncomp(mask);
numPixels = cellfun(@numel,CC.PixelIdxList);

if isempty(numPixels)
    processedMask = mask; 
    return;
end

[a b] = sort(numPixels,'descend');
maskBorder = zeros(size(mask));
maskBorder(CC.PixelIdxList{b(1)}) = 1;
%maskBorder(CC.PixelIdxList{b(2)}) = 0;
close all
%imshow(maskBorder)

%drawnow

%imwrite(maskBorder,[fold_out, d(i).name]);

%pause

processedMask = maskBorder;
end