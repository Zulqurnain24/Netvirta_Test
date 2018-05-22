//
//  MSERFeature.m
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 21/04/2018.
//

#import "MSERFeature.h"

@implementation MSERFeature

/**
 * distace
 * @param MSER Feature
 * @return returns the Distance(MSER precision) based on five aspects of mser(i.e. numer of holes, MSER_AREA / CONVEX_HULL_AREA, MSER_AREA / MIN_RECT_AREA, MSER_SKELET_LENGTH / MSER_AREA, MSER_AREA / CONTOUR_AREA)
 */
-(double) distace: (MSERFeature *) other
{
    return
    (self.numberOfHoles == other.numberOfHoles ? 1 : 10) *
    (log(fabs(self.convexHullAreaRate - other.convexHullAreaRate)) +
     log(fabs(self.minRectAreaRate - other.minRectAreaRate)) +
     log(fabs(self.skeletLengthRate - other.skeletLengthRate)) +
     log(fabs(self.contourAreaRate - other.contourAreaRate)));
}

/**
 * description
 * @explaination - Shows the entire description pertaining to five features of MSER
 */
-(NSString *)description
{
    return [NSString stringWithFormat:
            @"numberOfHoles: %li, convexHullAreaRate: %f, minRectAreaRate: %f, skeletLengthRate: %f, contourAreaRate: %f ",
            (long)self.numberOfHoles, self.convexHullAreaRate, self.minRectAreaRate, self.skeletLengthRate, self.contourAreaRate];
}

/**
 * toString
 * @explaination - Strings formatting algorithm
 */
-(NSString *)toString
{
    return [NSString stringWithFormat:
            @"%li \t %f \t %f \t %f \t %f ",
            (long)self.numberOfHoles, self.convexHullAreaRate, self.minRectAreaRate, self.skeletLengthRate, self.contourAreaRate];
}

@end
