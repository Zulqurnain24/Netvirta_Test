//
//  MSERFeature.h
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.
//

#import <Foundation/Foundation.h>

@interface MSERFeature : NSObject

@property NSInteger numberOfHoles;
@property double convexHullAreaRate;
@property double minRectAreaRate;
@property double skeletLengthRate;
@property double contourAreaRate;

-(double) distace: (MSERFeature *) other;

-(NSString *)description;

-(NSString *)toString;

@end
