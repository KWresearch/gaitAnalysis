function [ stdDev ] = computeStdDevOfNonZeros( img, tol )

img(abs(img)<tol)=NaN;
stdDev = nanvar(img(:))^2;
end

