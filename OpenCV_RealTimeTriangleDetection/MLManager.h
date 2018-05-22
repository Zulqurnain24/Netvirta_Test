//
//  MLManager.h
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MSERFeature.h"

/*
 This singleton class wraps object recognition function
 */
@interface MLManager : NSObject

+ (MLManager *) sharedInstance;

/*
 Stores feature from the biggest MSER in the templateImage
 */
- (void) learn: (UIImage *) templateImage;

/*
 Sum of differences between logo feature and given feature
 */
- (double) distance: (MSERFeature *) feature;

/*
 Returns true if the given feature is similar to the one learned from the template
 */
- (BOOL) isReferenceLogo: (MSERFeature *) feature;

@end
