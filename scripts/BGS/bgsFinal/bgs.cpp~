/*

*/
#include <iostream>
#include <opencv2/opencv.hpp>

#include <dirent.h>
#if CV_MAJOR_VERSION >= 2 && CV_MINOR_VERSION >= 4 && CV_SUBMINOR_VERSION >= 3
#include "package_bgs/GMG.h"
#endif

#include "package_bgs/dp/DPZivkovicAGMMBGS.h"
void processImage(IBGS *bgs, std::string imagePath,std::string savePath);

int main(int argc, char **argv)
{
   if(argc!=3) {
      std::cout << "usage" << std::endl;
      return 1;
   }

   std::cout << "Using OpenCV " << CV_MAJOR_VERSION << "." << CV_MINOR_VERSION << "." << CV_SUBMINOR_VERSION << std::endl;

   /* Background Subtraction Methods. */
   IBGS *bgs;

   bgs = new DPZivkovicAGMMBGS;
   
   std:: stringstream filePaths, savePaths; 
   std::cout << "loading files from  " << argv[1] << std::endl;
   std::cout << "saving files to  " << argv[2] << std::endl;
   struct dirent ** dirContents;
   int n = scandir(argv[1], &dirContents, NULL, alphasort);
   if(n<0) {
      std::cout << "ERROR: could not open dir" << argv[1] << std::endl;
      return 1;
   }
   int m=0;
   while(m<n) {
      filePaths.str("");
      savePaths.str("");
      filePaths << argv[1] << "/" << dirContents[m]->d_name; 
      savePaths << argv[2] << "/" << "mask_" << dirContents[m]->d_name; 
      std::cout << "processing " << filePaths.str() << std::endl;
      processImage(bgs, filePaths.str(), savePaths.str());
      free(dirContents[m]);
      ++m;
   }
   
 free(dirContents);
  int key = 0;
  std::string fileExt = ".png";

  /*while(key != 'q')
  {
   std::stringstream ss;
    ss << frameNumber;
    std::string fileName =  
        "/space/data_to_backup/Ben/data/video_training/Subject1_Normal1/Subject1_Normal1_cleaned/clean_depth_" +
         ss.str() + fileExt;
    std::cout << "reading " << fileName << std::endl;
    key = cvWaitKey(33);

    frameNumber++;
  }
  cvWaitKey(0);*/
  delete bgs;

  cvDestroyAllWindows();

  return 0;
}

void processImage(IBGS *bgs, std::string imagePath,std::string savePath)
{
    cv::Mat img_input = cv::imread(imagePath, CV_LOAD_IMAGE_GRAYSCALE);
    
    if (img_input.empty()) {
       std::cout << "ERROR: could not open file " << imagePath << std::endl;
       return;   
    }

    //cv::imshow("input", img_input);

    cv::Mat img_mask;
    cv::Mat img_bkgmodel;
    bgs->process(img_input, img_mask, img_bkgmodel); // by default, it shows automatically the foreground mask image 
    if(!img_mask.empty()) {
       cv::imshow("mask", img_mask);
       cv::imwrite(savePath, img_mask);
    }
}
