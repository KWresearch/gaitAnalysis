function [] = cleanImage(imageNumber, dataDir, resDir,numberOfIterations)
cd(dataDir)
imageExt = num2str(imageNumber);
depthPath=strcat('depth_', imageExt );
depthPath=strcat(depthPath, '.png');
depthImage=imread(depthPath);
depthImageSmooth=imread(depthPath);
rgbPath=strcat('img_', imageExt );
rgbPath=strcat(rgbPath, '.png');
rgbImage=imread(rgbPath);

maxV=[];
minV=[];
stPointR=1;
stPointC=1;



depthImage=double(depthImage(stPointR:end,stPointC:end));
maxV=[maxV max(max(depthImage))];
findNoZero=depthImage>0;
minV=[minV min(min(depthImage(findNoZero)))];

minD=min(minV);
maxD=max(maxV);

rangeD=maxD-minD;

generateRawImageCut=0;
%if(generateRawImageCut)
%[depth_60_8BITS_Enhance,noPixelMask]=depth2GrayScaleEnhanced2(depthImage,0,minD,maxD);
depth_SpecialColor=depth2SpecialColor(depthImage,0);

%end

nFrameToLoad=1;

rStart=1;
rEnd=size(depth_SpecialColor,1);
cStart=1;
cEnd=size(depth_SpecialColor,2);
depth_SpecialColor=depth_SpecialColor(rStart:rEnd,cStart:cEnd,:);
rgbImage=rgbImage(rStart:rEnd,cStart:cEnd,:);
depthImageSmooth=depthImageSmooth(rStart:rEnd,cStart:cEnd,:);
depthImage=depthImage(rStart:rEnd,cStart:cEnd,:);


if(generateRawImageCut)

    imwrite(depth_SpecialColor,'cutDepth_table_small_1_25.png');
    %imwrite(depth_SpecialColor,'cutDepthSmooth_0177.png');
    imwrite(rgbImage,'cutImg_table_small_1_25.png');

end

% rStart=38;
% rEnd=475;
% cStart=28;
% cEnd=611;

rStart2=1;
rEnd2=-rStart+rEnd+1;
cStart2=1;
cEnd2=-cStart+cEnd+1;
close all
if(0)

    %     depthImage=depthImage(rStart:rEnd,cStart:cEnd,:);
    %     rgbImage=rgbImage(rStart:rEnd,cStart:cEnd,:);

    depth_60_8BITS=depth2GrayScale(depthImage);
    [depth_60_8BITS_Enhance,noPixelMask]=depth2GrayScaleEnhanced2(depthImage,0,minD,maxD);
    depth_60_8BITSpecial=depth2SpecialColorNoScale(depth_60_8BITS_Enhance,0);
    yesPixelMask=~noPixelMask;

    %depth_60_8BITSpecial
    imshow(depth_60_8BITS_Enhance);
    [xp,yp] = ginput(2);
    xp=round(xp);
    yp=round(yp);
    %%hold on
    plotSquare(xp,yp)

    rStart2=yp(1);
    rEnd2=yp(2);
    cStart2=xp(1);
    cEnd2=xp(2);
end

%reEstimateInterval
depthImageSelection=depthImage(rStart2:rEnd2,cStart2:cEnd2);
depthImageSmoothSelection=double(depthImageSmooth(rStart2:rEnd2,cStart2:cEnd2));


maxV2=[];
maxV2=[maxV2 max(max(depthImageSmoothSelection))];
findNoZero=depthImageSmoothSelection>0;
minV2=[];
minV2=[minV2 min(min(depthImageSmoothSelection(findNoZero)))];

minD2=min(minV2);
maxD2=max(maxV2);

[depth_60_8BITS_EnhanceSel,noPixelMask]=depth2GrayScaleEnhanced2(depthImageSelection,0,minD2,maxD2);
depth_60_8BITSpecialCUT=depth2SpecialColorNoScale(depth_60_8BITS_EnhanceSel,0);

rangeD2=maxD2-minD2;
[depthImageSmoothSelection8BITS,noPixelMask]=depth2GrayScaleEnhanced2(depthImageSmoothSelection,0,minD2,maxD2);

depthImageSmoothSelectionNEWInterval=depthImageSmoothSelection8BITS;



dummyModel=[];
runGaussModel=[];
mapCounter=[];
noDataModel=[];
tmpVarMod=[];
tmpVar=[];
examplePointX=305;
examplePointY=140;

invAlpha=25;

w=7;
sigmaD=3.5;
sigmaRVisual=25/255;%[10]/255;
sigmaRDepth=[30]/5000;
tmpSigma=[sigmaD sigmaRVisual(1) sigmaRDepth(1)];

mcTh=1;
mcPercentage=0.35;
for i=1:numberOfIterations
    cd(dataDir)
    if(i<invAlpha)
        %alpha=1/i;
        alpha=1/invAlpha;
    else
        alpha=1/invAlpha;
    end
    %load images
    tmpMat=imread(depthPath);
    tmpImg=imread(rgbPath);

    tmpMat=tmpMat(rStart:rEnd,cStart:cEnd);
    tmpMat=double(tmpMat(rStart2:rEnd2,cStart2:cEnd2));
    [depth8BIT,tmpMat_NAN,noData]=depth2GrayScaleEnhanced3(tmpMat,0,minD2,maxD2);
    %tmpMat_NAN=double(depth8BIT)/255;
    tmpMat_NAN(noData)=NaN;



    tmpImg=tmpImg(rStart:rEnd,cStart:cEnd,:);
    tmpImg=tmpImg(rStart2:rEnd2,cStart2:cEnd2,:);

    tmpImg_Gray=rgb2gray(tmpImg);
    tmpImg_GrayNorm=double(tmpImg_Gray)/255;


    if(i==1)
        %GENERATE EDGE MASK
        depthGradient=gradientMagnitude(tmpMat_NAN);
        visualGradient=gradientMagnitude(tmpImg_GrayNorm);

        % Ehnanced Edge MASKS
        finalMask=enhancedEdgeMask(depthGradient, 0.02, noData);

        %FILTERING
        %filteredImage=myJointBilateralEdgeExtremeWithMask(tmpMat_NAN,tmpImg_GrayNorm,tmpMat_NAN, finalMask,w,tmpSigma,~noData);
        %filteredImage=myJointBilateralEdgeExtremeWithMaskNew(tmpMat_NAN,tmpImg_GrayNorm,tmpMat_NAN, finalMask,w,tmpSigma,~noData);
        filteredImage=myJointBilateralEdgeExtremeWithMaskNew2(tmpMat_NAN,tmpImg_GrayNorm,tmpMat_NAN, finalMask,w,tmpSigma,~noData);
        %filteredImage=myJointBilateralEdgeExtremeWithMaskNew2HSV(tmpMat_NAN,rgb2hsv(tmpImg),tmpMat_NAN, finalMask,w,tmpSigma,~noData);

        %%DUMMY HOLE FILLING
        mapCounterTh=~noData;
        filteredImageN = myJointBilateralEdgeExtremeWithMask_HF_MP(filteredImage,tmpImg_GrayNorm,filteredImage, finalMask,w,tmpSigma,noData,mapCounterTh,mcPercentage);
        %filteredImageN = myJointBilateralEdgeExtremeWithMask_HF_MPHSV(filteredImage,rgb2hsv(tmpImg),filteredImage, finalMask,w,tmpSigma,noData,mapCounterTh,mcPercentage);
        dummyModel=tmpMat_NAN;
        runGaussModel=filteredImageN;
        noDataModel=isnan(filteredImageN);
        mapCounter=double(~noDataModel);
        %tmpVarMod=[tmpVarMod runGaussModel(examplePointX,examplePointY)];
    else
        %Fill holes with model values
        [dummy, newPixel, commonPixel]=detectNewPixelEnhanced(noData,noDataModel);
        [dummy, newPixel2, commonPixel]=detectNewPixelEnhanced(noDataModel,noData);
        %%INSERT MAP COUNTER CONTROL
        %newPixel=newPixel(??????????????)
        %insert some new pixel in the temporal Model???function () = name(
        %%%%%%%%%%%%%%%%%%
        tmpMat_NAN(newPixel)=runGaussModel(newPixel);
        tmpRunGaussModel=runGaussModel;
        tmpRunGaussModel(newPixel2)= tmpMat_NAN(newPixel2);
        noData=isnan(tmpMat_NAN);

        %GENERATE EDGE MASK
        depthGradient=gradientMagnitude(tmpMat_NAN);
        %depthGradientModel=gradientMagnitude(runGaussModel);
        depthGradientModel=gradientMagnitude(tmpRunGaussModel);
        visualGradient=gradientMagnitude(tmpImg_GrayNorm);

        % Ehnanced Edge MASKS
        %finalMask=enhancedEdgeMaskWithModel(depthGradient,depthGradientMfunction () = name(odel, 0.02, noData);
        finalMask=enhancedEdgeMask(depthGradient, 0.02, noData);
        %FILTERING OK DATA
        %filteredImage=myJointBilateralEdgeExtremeWithMask(tmpMat_NAN,tmpImg_GrayNorm,tmpRunGaussModel, finalMask,w,tmpSigma,~noData);
        %filteredImage=myJointBilateralEdgeExtremeWithMaskNew(tmpMat_NAN,tmpImg_GrayNorm,tmpRunGaussModel, finalMask,w,tmpSigma,~noData);
        filteredImage=myJointBilateralEdgeExtremeWithMaskNew2(tmpMat_NAN,tmpImg_GrayNorm,tmpRunGaussModel, finalMask,w,tmpSigma,~noData);
        %filteredImage=myJointBilateralEdgeExtremeWithMaskNew2HSV(tmpMat_NAN,rgb2hsv(tmpImg),tmpRunGaussModel, finalMask,w,tmpSigma,~noData);

        %FILTERING HOLES
        %dummy one iteration
        %mapCounterTh=~noData;
        mapCounterTh=mapCounter>mcTh;
        filteredImageN = myJointBilateralEdgeExtremeWithMask_HF_MP(filteredImage,tmpImg_GrayNorm,filteredImage, finalMask,w,tmpSigma,noData,mapCounterTh,mcPercentage);
        %filteredImageN = myJointBilateralEdgeExtremeWithMask_HF_MPHSV(filteredImage,rgb2hsv(tmpImg),filteredImage, finalMask,w,tmpSigma,noData,mapCounterTh,mcPercentage);

        %%Running Average Model
        noData=isnan(filteredImageN);
        [runGaussModel,mapCounter,noDataModel]=runningGaussianAverage(runGaussModel,filteredImageN,alpha,noDataModel,noData,mapCounter);
    end
    %tmpVar=[tmpVar tmpMat_NAN(examplePointX,examplePointY)];
    %tmpVarMod=[tmpVarMod runGaussModel(examplePointX,examplePointY)];
    if( i==numberOfIterations)
        cd(resDir);
        tmpDepthResStruct.depthModScaled=runGaussModel;
        tmpDepthResStruct.depthFiltScaled=filteredImageN;
        tmpDepthResStruct.depthModInRange=grayScaleToOriginalRange(runGaussModel,1,minD,maxD);
        tmpDepthResStruct.depthFiltInRange=grayScaleToOriginalRange(filteredImageN,1,minD,maxD);
        tmpDepthResStruct.depthModNoData=noDataModel;
        tmpDepthResStruct.depthFiltNoData=noData;
        tmpDepthResStruct.depthModMapCounter=mapCounter;

        tmpRGBIMG=(filteredImageN*255);
        [tmpRGBIMG]=depth2SpecialColorNoScale(tmpRGBIMG,1);
        tmpDepth8BIT_JET=depth2SpecialColorNoScaleJET(filteredImageN*255,1);
       % strImage=sprintf('filterDepth_%d.bmp',i);
        %tmpRGBIMG2=ind2RGB8(
        depthSaveName=strcat('clean_depth_', imageExt );
        depthSaveName=strcat(depthSaveName, '.png' );
        imwrite(tmpRGBIMG,depthSaveName, 'png');

      %  strImage=sprintf('filterDepthJET_%d.bmp',i);
       % imwrite(tmpDepth8BIT_JET,strImage,'bmp');


        tmpRGBIMG=(runGaussModel*255);
        [tmpRGBIMG]=depth2SpecialColorNoScale(tmpRGBIMG,1);
        tmpDepth8BIT_JET=depth2SpecialColorNoScaleJET(runGaussModel*255,1);
      %  strImage=sprintf('modelDepth_%d.bmp',i);
       % imwrite(tmpRGBIMG,strImage,'bmp');

       % strImage=sprintf('modelDepthJET_%d.bmp',i);
        %imwrite(tmpDepth8BIT_JET,strImage,'bmp');

        strStruct=sprintf('depthStruct_%d=tmpDepthResStruct;',i);
        eval(strStruct);
      %  strSaveStruct=sprintf('save depthStruct_%d.mat depthStruct_%d',i,i);
       % eval(strSaveStruct);

        str=sprintf('clear depthStruct_%d',i);
        eval(str);
    end

    str=sprintf('clear depth_%d',i);
    eval(str);

end
disp('finito')
%save parametersResults.mat alpha cEnd cEnd2 cStart cStart2 dataDir invAlpha manualSelection  maxD maxV mcPercentage mcTh minD minV rEnd rEnd2 rStart rStart2 rangeD resDir saveOK sigmaD sigmaRDepth sigmaRVisual

%depth_60_8BITSpecialCUT=depth_60_8BITSpecial(rStart2:rEnd2,cStart2:cEnd2);
cd(dataDir);
% imwrite(tmpImg,'1_414.png');
%imwrite(depth_60_8BITSpecialCUT,'2_414.png');

%tmpDepth8BIT_JET=depth2SpecialColorNoScaleJET(depth8BIT,0);

% imwrite(tmpDepth8BIT_JET,'meeting_small_1_8_depth_JET.png','png');
%imwrite(depthImageSmoothSelection8BITS,'meeting_small_1_8.png');
end