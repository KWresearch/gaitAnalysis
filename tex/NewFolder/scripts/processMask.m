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
close all

processedMask = maskBorder;
end