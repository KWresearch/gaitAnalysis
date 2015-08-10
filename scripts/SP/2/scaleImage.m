function [scaledImg] = scaleImage(image,meanAtWaist)

scaledImg = histeq(image);
%imshow(image)
%figure,  imhist(image,64)
%pause;
%imshow(scaledImg)
%figure,  imhist(scaledImg,64)
%pause(0.001);
%close all
% imglf = im2double(image);
% 
% pixelsDistanceFromMean = imglf-meanAtWaist;
% sMin = min(min(pixelsDistanceFromMean));
% sMax = max(max(pixelsDistanceFromMean));
% imMin = min(min(imglf));
% imMax = max(max(imglf));
% scaler = 1/(imMax*sMax);
% scaleArray = pixelsDistanceFromMean.*scaler;
% 
% scaledImg = imglf.*scaleArray;
% minScaledImg = min(min(scaledImg))
% scaledImgShifted = scaledImg+meanAtWaist;
% imshow(scaledImg.*255);
% max(max(scaledImg))
% min(min(scaledImg))
% pause;

