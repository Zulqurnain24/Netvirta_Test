//
//  FPS.m
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.
//


#import "FPS.h"
#import <sys/time.h>
#import "ImageUtils.h"

@implementation FPS

static long long last;

/**
 * tick
 * @explaination - Method that counts time ticks to maintain a record of frame rate
 */
+(int) tick
{
    struct timeval t;
    gettimeofday(&t, NULL);
    
    long long now = (((long long) t.tv_sec) * 1000) + (((long long) t.tv_usec) / 1000);
    
    int result = (int)(1000.0 / (now - last));
    last = now;
    
    return result;
}

/**
 * draw
 * @explaination - Displays frame rate
 */
+(void) draw: (cv::Mat) rgb;
{
    int fps = [FPS tick];
    const char* str_fps = [[NSString stringWithFormat: @"FPS: %d", fps] cStringUsingEncoding: NSUTF8StringEncoding];
    
    cv::putText(rgb, str_fps, cv::Point(10, 20), CV_FONT_HERSHEY_PLAIN, 1.0, RED);
}

@end
