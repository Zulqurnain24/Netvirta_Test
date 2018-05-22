//
//  ImageUtils.h
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <opencv2/opencv.hpp>

@interface ImageUtils : NSObject

extern const cv::Scalar RED;
extern const cv::Scalar GREEN;
extern const cv::Scalar BLUE;
extern const cv::Scalar BLACK;
extern const cv::Scalar WHITE;
extern const cv::Scalar YELLOW;
extern const cv::Scalar LIGHT_GRAY;

+ (cv::Mat) cvMatFromUIImage: (UIImage *) image;
+ (cv::Mat) cvMatGrayFromUIImage: (UIImage *)image;

+ (UIImage *) UIImageFromCVMat: (cv::Mat)cvMat;

+ (cv::Mat) mserToMat: (std::vector<cv::Point> *) mser;

+ (void) drawMser: (std::vector<cv::Point> *) mser intoImage: (cv::Mat *) image withColor: (cv::Scalar) color;

+ (std::vector<cv::Point>) maxMser: (cv::Mat *) gray;

@end
