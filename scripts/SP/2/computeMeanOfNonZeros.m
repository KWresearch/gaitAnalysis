function [ mean ] = computeMeanOfNonZeros( img, tol )

img(abs(img)<tol)=NaN;
mean = nanmean(img(:))
end

