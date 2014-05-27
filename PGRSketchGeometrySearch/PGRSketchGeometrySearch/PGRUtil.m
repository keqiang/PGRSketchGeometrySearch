//
//  PGRUtil.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-16.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRUtil.h"
#import "DollarPoint.h"
#import "PGRControlPoint.h"

@implementation PGRUtil

const float SAME_POINT_DISTANCE = 30;
const float IGNORED_STROKE_LENGTH = 30;

- (NSNumber *)meanOf:(NSArray *)array
{
    double runningTotal = 0.0;
    
    for(NSNumber *number in array)
    {
        runningTotal += [number doubleValue];
    }
    
    return [NSNumber numberWithDouble:(runningTotal / [array count])];
}

- (NSNumber *)standardDeviationOf:(NSArray *)array
{
    if(![array count]) return nil;
    
    double mean = [[self meanOf:array] doubleValue];
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in array)
    {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / [array count])];
}

// calculate the mean distance from points 1,2...n-2 to the line formed by points 0 and n - 1
+ (BOOL)isLineSegment:(NSArray *)points
{
    if ([points count] <= 2) {
        return true;
    }

    
    DollarPoint *start = [points objectAtIndex:0];
    DollarPoint *end = [points objectAtIndex:[points count] - 1];
    
    float lineLengh = sqrtf(powf(([end y] - [start y]), 2) + powf(([end x] - [start x]), 2));
    
    float totalDistance = 0;
    
    if ([start x] == [end x]) {
        for (int i = 1; i < [points count] - 1; ++i) {
            DollarPoint *tmpPoint = [points objectAtIndex:i];
            float tmpDist = [tmpPoint x] - [start x];
            if (tmpDist < 0) {
                tmpDist = -tmpDist;
            }
            totalDistance += tmpDist;
        }
    } else {
        
        float k = (float)([end y] - [start y]) / ([end x] - [start x]);
        float b = [end y] - k * [end x];
        
        for (int i = 1; i < [points count] - 1; ++i) {
            DollarPoint *tmpPoint = [points objectAtIndex:i];
            float up = k * [tmpPoint x] - [tmpPoint y] + b;
            if (up < 0) {
                up = -up;
            }
            float down = sqrtf(k * k + 1);
            totalDistance += (float)up / down;
        }
    }
    
    if ((float)totalDistance / ([points count] - 2) > (float)lineLengh / 15) {
        return false;
    }
    return true;
}

// find the nearest control point to see if they can be merged to a single point
+ (PGRControlPoint *)findNearestControllPoint:(DollarPoint *)newControlPoint in:(NSDictionary *)controlPoints {
    float minDistance = +INFINITY;
    
    PGRControlPoint *foundPoint = nil;
    CGPoint temp = CGPointMake(newControlPoint.x, newControlPoint.y);
    
    NSArray *allControlPoints = [controlPoints allValues];
    
    for (PGRControlPoint *point in allControlPoints) {
        float curDistance = [self distance:[point coordinates] from:temp];
        if (curDistance < minDistance) {
            minDistance = curDistance;
            foundPoint = point;
        }
    }
    
    if (minDistance < SAME_POINT_DISTANCE && foundPoint != nil) {
        return foundPoint;
    } else {
        return nil;
    }
}

// returns true when this point is a pre-created control point
+ (BOOL)refineStartAndEnd:(DollarPoint *)point in:(NSMutableDictionary *)allControlPoints
{
    PGRControlPoint *relatedCP = [self findNearestControllPoint:point in:allControlPoints];
    if (relatedCP != nil) {
        // modify the starting point according to the found control point
        [point setX:[relatedCP coordinates].x];
        [point setY:[relatedCP coordinates].y];
        return true;
    } else {
        [PGRUtil createNewControlPointAt:point in:allControlPoints];
        return false;
    }
}

// create a new control point at specified location
+ (PGRControlPoint *)createNewControlPointAt:(DollarPoint *)location in:(NSMutableDictionary *)allControlPoints
{
    PGRControlPoint *newPoint = [[PGRControlPoint alloc] initWithCGPoint:CGPointMake(location.x, location.y)];
    
    [allControlPoints setObject:newPoint forKey:[newPoint getKey]];
    return newPoint;
}

+ (CGFloat)distance:(CGPoint)a from:(CGPoint)b
{
    CGFloat xDist = (a.x - b.x);
    CGFloat yDist = (a.y - b.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

+ (float)calculateLength:(NSArray *)points
{
    float length = 0;
    for (int i = 0; i < [points count] - 1; ++i) {
        DollarPoint *a = [points objectAtIndex:i];
        DollarPoint *b = [points objectAtIndex:i+1];
        length += sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
    }
    return length;
}

@end
