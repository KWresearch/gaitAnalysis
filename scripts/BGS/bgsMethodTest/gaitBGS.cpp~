/*
This file is part of BGSLibrary.

BGSLibrary is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

BGSLibrary is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with BGSLibrary.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <iostream>
#include <opencv2/opencv.hpp>
#include <sstream>
#include <iomanip>

#include "package_bgs/FrameDifferenceBGS.h"
#include "package_bgs/StaticFrameDifferenceBGS.h"
#include "package_bgs/WeightedMovingMeanBGS.h"
#include "package_bgs/WeightedMovingVarianceBGS.h"
#include "package_bgs/MixtureOfGaussianV1BGS.h"
#include "package_bgs/MixtureOfGaussianV2BGS.h"
#include "package_bgs/AdaptiveBackgroundLearning.h"
#include "package_bgs/AdaptiveSelectiveBackgroundLearning.h"

#if CV_MAJOR_VERSION >= 2 && CV_MINOR_VERSION >= 4 && CV_SUBMINOR_VERSION >= 3
#include "package_bgs/GMG.h"
#endif

#include "package_bgs/dp/DPAdaptiveMedianBGS.h"
#include "package_bgs/dp/DPGrimsonGMMBGS.h"
#include "package_bgs/dp/DPZivkovicAGMMBGS.h"
#include "package_bgs/dp/DPMeanBGS.h"
#include "package_bgs/dp/DPWrenGABGS.h"
#include "package_bgs/dp/DPPratiMediodBGS.h"
#include "package_bgs/dp/DPEigenbackgroundBGS.h"
#include "package_bgs/dp/DPTextureBGS.h"

#include "package_bgs/tb/T2FGMM_UM.h"
#include "package_bgs/tb/T2FGMM_UV.h"
#include "package_bgs/tb/T2FMRF_UM.h"
#include "package_bgs/tb/T2FMRF_UV.h"
#include "package_bgs/tb/FuzzySugenoIntegral.h"
#include "package_bgs/tb/FuzzyChoquetIntegral.h"

#include "package_bgs/lb/LBSimpleGaussian.h"
#include "package_bgs/lb/LBFuzzyGaussian.h"
#include "package_bgs/lb/LBMixtureOfGaussians.h"
#include "package_bgs/lb/LBAdaptiveSOM.h"
#include "package_bgs/lb/LBFuzzyAdaptiveSOM.h"

#include "package_bgs/ck/LbpMrf.h"
#include "package_bgs/jmo/MultiLayerBGS.h"
// The PBAS algorithm was removed from BGSLibrary because it is
// based on patented algorithm ViBE
// http://www2.ulg.ac.be/telecom/research/vibe/
//#include "package_bgs/pt/PixelBasedAdaptiveSegmenter.h"
#include "package_bgs/av/VuMeter.h"
#include "package_bgs/ae/KDE.h"
#include "package_bgs/db/IndependentMultimodalBGS.h"
#include "package_bgs/sjn/SJN_MultiCueBGS.h"
#include "package_bgs/bl/SigmaDeltaBGS.h"

#include "package_bgs/pl/SuBSENSE.h"
#include "package_bgs/pl/LOBSTER.h"

int main(int argc, char **argv)
{
  std::cout << "Using OpenCV " << CV_MAJOR_VERSION << "." << CV_MINOR_VERSION << "." << CV_SUBMINOR_VERSION << std::endl;

  /* Background Subtraction Methods */
  IBGS *bgs;

  /*** Default Package ***/
 // bgs = new FrameDifferenceBGS; //bad
 // bgs = new StaticFrameDifferenceBGS; //ok but noisey
 // bgs = new WeightedMovingMeanBGS; //bad
 // bgs = new WeightedMovingVarianceBGS; //bad
  //bgs = new MixtureOfGaussianV1BGS; //bad
  //bgs = new MixtureOfGaussianV2BGS; //bad
  //bgs = new AdaptiveBackgroundLearning;  //bad
  //bgs = new AdaptiveSelectiveBackgroundLearning; //really good but needs preceeding BG frames
  //bgs = new GMG; //bad
  
  /*** DP Package (thanks to Donovan Parks) ***/
  //bgs = new DPAdaptiveMedianBGS; //good except feet
 // bgs = new DPGrimsonGMMBGS; //bad
 bgs = new DPZivkovicAGMMBGS;// good doesnt need BG frames
  //bgs = new DPMeanBGS;//bad
 // bgs = new DPWrenGABGS;//ok
  //bgs = new DPPratiMediodBGS; //bad
  //bgs = new DPEigenbackgroundBGS;//bad
 // bgs = new DPTextureBGS;//segfaults

  /*** TB Package (thanks to Thierry Bouwmans, Fida EL BAF and Zhenjie Zhao) ***/
//these won't compile
 // bgs = new T2FGMM_UM;
  //bgs = new T2FGMM_UV;
  //bgs = new T2FMRF_UM;
  //bgs = new T2FMRF_UV;
  //bgs = new FuzzySugenoIntegral;
  //bgs = new FuzzyChoquetIntegral;

  /*** JMO Package (thanks to Jean-Marc Odobez) ***/
 // bgs = new MultiLayerBGS;//bad

  /*** PT Package (thanks to Martin Hofmann, Philipp Tiefenbacher and Gerhard Rigoll) ***/
  //bgs = new PixelBasedAdaptiveSegmenter;//cant find the c file in package_bgs

  /*** LB Package (thanks to Laurence Bender) ***/
 // bgs = new LBSimpleGaussian;//bad
  //bgs = new LBFuzzyGaussian;//not quite
  //bgs = new LBMixtureOfGaussians;//bad
  //bgs = new LBAdaptiveSOM;//bad
//  bgs = new LBFuzzyAdaptiveSOM;//bad

  /*** LBP-MRF Package (thanks to Csaba Kertész) ***/
//doesnt compile
  //bgs = new LbpMrf;

  /*** AV Package (thanks to Lionel Robinault and Antoine Vacavant) ***/
 // bgs = new VuMeter;//doesnt compile

  /*** EG Package (thanks to Ahmed Elgammal) ***/
  //bgs = new KDE;//deosnt compile
  
  /*** DB Package (thanks to Domenico Daniele Bloisi) ***/
  //bgs = new IndependentMultimodalBGS;//works quite well, needs lots of preceeding bg frames

  /*** SJN Package (thanks to SeungJong Noh) ***/
  //bgs = new SJN_MultiCueBGS;//doesnt compile

  /*** BL Package (thanks to Benjamin Laugraud) ***/
  //bgs = new SigmaDeltaBGS;

  /*** PL Package (thanks to Pierre-Luc) ***/
//doesnt compile
  //bgs = new SuBSENSEBGS();
 // bgs = new LOBSTERBGS();

  int frameNumber = 1;
  int key = 0;
  std::string fileExt = ".png";
  while(key != 'q')
  {
    std::stringstream ss;
    ss << std::setw(3) << std::setfill('0') << frameNumber;
    std::string fileName = "/space/data_to_backup/Ben/data/video_training/Subject1_Normal1/Subject1_Normal1_quickFillAllFrames/qFilled_" + ss.str() + fileExt;
    std::cout << "reading " << fileName << std::endl;

    cv::Mat img_input = cv::imread(fileName, CV_LOAD_IMAGE_COLOR);
    
    if (img_input.empty()) {
      ++frameNumber;
    }
    else {
   	 cv::imshow("input", img_input);

   	 cv::Mat img_mask;
    	 cv::Mat img_bkgmodel;
   	 bgs->process(img_input, img_mask, img_bkgmodel); // by default, it shows automatically the foreground mask image
    
    	key = cvWaitKey(33); 
        frameNumber++;
    }
  }
  cvWaitKey(0);
  delete bgs;

  cvDestroyAllWindows();

  return 0;
}
