//
//  MLManager.m
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.
//


#import "MLManager.h"
#import "ImageUtils.h"
#include <opencv2/highgui/highgui.hpp>
#import "MSERManager.h"
#import "GeometryUtil.h"

#define KEY_NUMBER_OF_HOLES @"KEY_NUMBER_OF_HOLES"
#define KEY_CONVEX_AREA_RATE @"KEY_CONVEX_AREA_RATE"
#define KEY_MIN_RECT_AREA_RATE @"KEY_MIN_RECT_AREA_RATE"
#define KEY_SKELET_LENGTH_RATE @"KEY_SKELET_LENGTH_RATE"
#define KEY_CONTOUR_AREA_RATE @"KEY_CONTOUR_AREA_RATE"

#define AVERAGE 0.113544
#define STDEV 0.063218

@interface MLManager()

@property MSERFeature *logoTemplate;

@end

@implementation MLManager

/**
 * sharedInstance
 * @explaination - A singleton that manages the 
                   machine learning aspect.
 */
+ (MLManager *) sharedInstance
{
    static MLManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MLManager alloc] init];
        [instance loadTemplate];
    });
    
    return instance;
}

/**
 * learn
 * @param image
 * @explaination - Learns MSER features from the given image
                   and a MSER feature template out of it.
                   Which is saved in the persistence storage
 */
- (void) learn: (UIImage *) templateImage;
{
    cv::Mat logo = [ImageUtils cvMatFromUIImage: templateImage];
    
    //get gray image
    cv::Mat gray;
    cvtColor(logo, gray, CV_BGRA2GRAY);
    
    //mser with maximum area is
    std::vector<cv::Point> maxMser = [ImageUtils maxMser: &gray];
    
    if(maxMser.size() > 4){
    //get 4 vertices of the maxMSER minrect
    cv::RotatedRect rect = cv::minAreaRect(maxMser);
    cv::Point2f points[4];
    rect.points(points);
    
    //normalize image
    cv::Mat M = [GeometryUtil getPerspectiveMatrix: points toSize: rect.size];
    cv::Mat normalizedImage = [GeometryUtil normalizeImage: &gray withTranformationMatrix: &M withSize: rect.size.width];
    
    //get maxMser from normalized image
    std::vector<cv::Point> normalizedMser = [ImageUtils maxMser: &normalizedImage];
    
    //remember the template
    self.logoTemplate = [[MSERManager sharedInstance] extractFeature: &normalizedMser];
    
    //store the feature
    [self storeTemplate];
    }
}

/**
 * learn
 * @param image
 * @returns - Distance(MSER precision) based on five aspects of mser(i.e. numer of holes, MSER_AREA / CONVEX_HULL_AREA, MSER_AREA / MIN_RECT_AREA, MSER_SKELET_LENGTH / MSER_AREA, MSER_AREA / CONTOUR_AREA)
 */
- (double) distance: (MSERFeature *) feature
{
    return [self.logoTemplate distace: feature];
}

/**
 * isReferenceLogo
 * @param MSERFeature
 * @returns - Judges whether the current image features are close enough to the leaned image from the reference image template
 */
- (BOOL) isReferenceLogo: (MSERFeature *) feature;
{
    if (_logoTemplate.numberOfHoles != feature.numberOfHoles) {
        return NO;
    }
    
    if ( fabs(_logoTemplate.convexHullAreaRate - feature.convexHullAreaRate) > 0.05) { // 0.1) {

        return NO;
    }
    if ( fabs(_logoTemplate.minRectAreaRate - feature.minRectAreaRate) > 0.05) { // 0.1) {

        return NO;
    }
    if ( fabs(_logoTemplate.skeletLengthRate - feature.skeletLengthRate) > 0.02) {

        return NO;
    }
    if ( fabs(_logoTemplate.contourAreaRate - feature.contourAreaRate) > 0.1) {//0.2) {

        return NO;
    }
    
    return YES;
}

#pragma mark - helper
/**
 * loadTemplate
 * @explaination - Loads the feature matrix from the reference image                template that has been stored in the persistence store previously
 */
- (void) loadTemplate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _logoTemplate = [[MSERFeature alloc] init];
    
    _logoTemplate.numberOfHoles = [defaults integerForKey: KEY_NUMBER_OF_HOLES];
    _logoTemplate.convexHullAreaRate = [defaults doubleForKey: KEY_CONVEX_AREA_RATE];
    _logoTemplate.minRectAreaRate = [defaults doubleForKey: KEY_MIN_RECT_AREA_RATE];
    _logoTemplate.skeletLengthRate = [defaults doubleForKey: KEY_SKELET_LENGTH_RATE];
    _logoTemplate.contourAreaRate = [defaults doubleForKey: KEY_CONTOUR_AREA_RATE];
}

/**
 * storeTemplate
 * @explaination - Store the MSER feature template into the device's persistence store memory
 */
- (void) storeTemplate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger: _logoTemplate.numberOfHoles forKey: KEY_NUMBER_OF_HOLES];
    [defaults setDouble: _logoTemplate.convexHullAreaRate forKey: KEY_CONVEX_AREA_RATE];
    [defaults setDouble: _logoTemplate.minRectAreaRate forKey: KEY_MIN_RECT_AREA_RATE];
    [defaults setDouble: _logoTemplate.skeletLengthRate forKey: KEY_SKELET_LENGTH_RATE];
    [defaults setDouble: _logoTemplate.contourAreaRate forKey: KEY_CONTOUR_AREA_RATE];
    
    [defaults synchronize];
}

@end
