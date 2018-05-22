//
//  FPS.h
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.
//


#import <Foundation/Foundation.h>
#import "opencv2/opencv_modules.hpp"
#import <stdio.h>
#include <opencv2/imgproc/imgproc.hpp>

@interface FPS : NSObject

+(void) draw: (cv::Mat) rgb;

@end
