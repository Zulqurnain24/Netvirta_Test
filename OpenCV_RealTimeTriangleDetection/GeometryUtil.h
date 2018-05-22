//
//  GeometryUtil.h
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.
//


#import <Foundation/Foundation.h>
#import "opencv2/opencv_modules.hpp"
#import <stdio.h>
#include <opencv2/imgproc/imgproc.hpp>

/*
 This static class provides perspective transformation function
 */
@interface GeometryUtil : NSObject

/*
 Return perspective transformation matrix for given points to square with
 origin [0,0] and with size (size.width, size.width)
 */
+ (cv::Mat) getPerspectiveMatrix: (cv::Point2f[]) points toSize: (cv::Size2f) size;

/*
 Returns new perspecivly transformed image with given size
 */
+ (cv::Mat) normalizeImage: (cv::Mat *) image withTranformationMatrix: (cv::Mat *) M withSize: (float) size;

@end
