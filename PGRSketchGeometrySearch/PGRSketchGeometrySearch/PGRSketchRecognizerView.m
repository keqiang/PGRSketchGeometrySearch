//
//  PGRSketchRecognizerView.m
//  SketchGeometry
//
//  Created by Li Keqiang on 14-5-22.
//  Copyright (c) 2014年 Li Keqiang. All rights reserved.
//

#import "PGRSketchRecognizerView.h"
#import "PGRStroke.h"
#import "DollarPoint.h"
#import "DollarP.h"
#import "PGRUtil.h"
#import "DollarDefaultGestures.h"
#import "DollarResult.h"
#import "PGRCircle.h"
#import "PGRLine.h"
#import "PGRTriangle.h"
#import "PGRRectangle.h"

@implementation PGRSketchRecognizerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    touchPoints = [NSMutableArray array];
    controlPoints = [[NSMutableDictionary alloc] init];
    recognizedShape = [NSMutableArray array];
    strokes = [[NSMutableDictionary alloc] init];
    
    strokeID = 0;
    
    dollarP = [[DollarP alloc] init];
    [dollarP setPointClouds:[DollarDefaultGestures defaultPointClouds]];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    // only sketching by one finger is accepted
    [self setMultipleTouchEnabled:FALSE];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    strokeID++;
    
    // only one touch is allowed because multiple touch is disabled
    UITouch* touch = [[touches allObjects] firstObject];
    
    // the key of current touch
    //NSValue *key = [NSValue valueWithNonretainedObject:touch];
    CGPoint location = [touch locationInView:self];
    DollarPoint *point = [[DollarPoint alloc] initWithStamp:@(strokeID)
                                                          x:location.x
                                                          y:location.y
                                                      stamp:[touch timestamp]];
    [touchPoints addObject:point];
    
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch* touch = [[touches allObjects] firstObject];
    
    // the key of current touch
    //NSValue *key = [NSValue valueWithNonretainedObject:touch];
    CGPoint location = [touch locationInView:self];
    DollarPoint *point = [[DollarPoint alloc] initWithStamp:@(strokeID)
                                                          x:location.x
                                                          y:location.y
                                                      stamp:[touch timestamp]];
    [touchPoints addObject:point];
    
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch* touch = [[touches allObjects] firstObject];
    
    // the key of current touch
    //NSValue *key = [NSValue valueWithNonretainedObject:touch];
    CGPoint location = [touch locationInView:self];
    DollarPoint *point = [[DollarPoint alloc] initWithStamp:@(strokeID)
                                                          x:location.x
                                                          y:location.y
                                                      stamp:[touch timestamp]];
    [touchPoints addObject:point];
    
    // if a stroke is too short, it will be removed from the canvas
    if ([PGRUtil calculateLength:touchPoints] <= IGNORED_STROKE_LENGTH) {
        [touchPoints removeAllObjects];
        [self setNeedsDisplay];
        return;
    }
    
    DollarPoint *originalStart = [touchPoints firstObject];
    DollarPoint *originalEnd = [touchPoints lastObject];
    // check the related control points or generate new ones
    BOOL startHasCP = [PGRUtil refineStartAndEnd:originalStart in:controlPoints];
    BOOL endHasCP = [PGRUtil refineStartAndEnd:originalEnd in:controlPoints];
    // display the changes of the end points
    [self setNeedsDisplay];
    
    // for later use
    CGPoint startCGPoint = CGPointMake([originalStart x], [originalStart y]);
    PGRControlPoint *startControlPoint = [controlPoints objectForKey:[NSValue valueWithCGPoint:startCGPoint]];
    CGPoint endCGPoint = CGPointMake([originalEnd x], [originalEnd y]);
    PGRControlPoint *endControlPoint = [controlPoints objectForKey:[NSValue valueWithCGPoint:endCGPoint]];
    
    // original end and original start has been modified already, so if they are equal, the stroke is a self-closed shape
    BOOL isClosed = originalEnd.x == originalStart.x && originalEnd.y == originalStart.y;
    // if the stroke connects 2 different existing control points, it forms new shapes.
    BOOL newClosedShapeFormed = startHasCP && endHasCP && !isClosed;
    
    if (isClosed) { // being closed means this single stroke ends at where it starts
        
        DollarResult *r = [dollarP recognize:touchPoints];
        NSLog(@"is closed, type is %@, score is %f", [r name], [r score]);
        
        if ([r score] > 0.0f) {
            [recognizedShape addObject:[self beautifyCircle:touchPoints retainPoint:originalStart]];
            
            // remove the control point if itself has generated a control point
            if (!startHasCP) {
                CGPoint startingPoint = CGPointMake([originalStart x], [originalStart y]);
                [controlPoints removeObjectForKey:[NSValue valueWithCGPoint:startingPoint]];
            }
            
            // single stroke is recognized as a circle, so just remove all the touch points
            [touchPoints removeAllObjects];
            [self setNeedsDisplay];
            NSLog(@"control point number is %d", [controlPoints count]);
            return;
            
        } else { // generate turning points if there is any and then check if it is a triangle or a rectangle.
            
            // candidateIndice contains all the possible turning points
            NSMutableArray *possibleTurningPointsIndice = [[[self findCandidateTurningPoints:touchPoints] allObjects] mutableCopy];
            // sort the indice with ascending order
            NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
            [possibleTurningPointsIndice sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            // filter the possible turning points by evaluating the intersection angle
            NSArray *candidateIndice = [self verifyTurningPoints:possibleTurningPointsIndice inTouchPoints:touchPoints];
            
            if ([candidateIndice count] >= 3) {
                
                DollarPoint *pointLT = [touchPoints firstObject];
                DollarPoint *pointRT = [touchPoints objectAtIndex:[[candidateIndice objectAtIndex:0] intValue]];
                DollarPoint *pointRB = [touchPoints objectAtIndex:[[candidateIndice objectAtIndex:1] intValue]];
                DollarPoint *pointLB = [touchPoints objectAtIndex:[[candidateIndice objectAtIndex:2] intValue]];
                
                CGPoint cgLT = CGPointMake([pointLT x], [pointLT y]);
                CGPoint cgRB = CGPointMake([pointRB x], [pointRB y]);
                
                float r = [PGRUtil distance:cgLT from:cgRB] / 2;
                
                CGPoint center = CGPointMake(([pointLT x] + [pointRB x]) / 2, ([pointLT y] + [pointRB y]) / 2);
                double slope = atan2([pointRT y] - center.y, [pointRT x] - center.x);
                float xLB = center.x - r * cos(slope);
                float yLB = center.y - r * sin(slope);
                
                float xRT = center.x + r * cos(slope);
                float yRT = center.y + r * sin(slope);
                
                [pointRT setX:xRT];
                [pointRT setY:yRT];
                
                [pointLB setX:xLB];
                [pointLB setY:yLB];
                
                CGPoint cgRT = CGPointMake([pointRT x], [pointRT y]);
                CGPoint cgLB = CGPointMake([pointLB x], [pointLB y]);
                
                PGRControlPoint *cp1 = [[PGRControlPoint alloc] initWithCGPoint:cgRT];
                PGRControlPoint *cp2 = [[PGRControlPoint alloc] initWithCGPoint:cgRB];
                PGRControlPoint *cp3 = [[PGRControlPoint alloc] initWithCGPoint:cgLB];
                PGRControlPoint *cp4 = [controlPoints objectForKey:[NSValue valueWithCGPoint:cgLT]];
                
                // add the conneting status to the adjacent table
                [[cp1 connectedControlPoints] setObject:cp2 forKey:[cp2 getKey]];
                [[cp1 connectedControlPoints] setObject:cp4 forKey:[cp4 getKey]];
                [[cp2 connectedControlPoints] setObject:cp1 forKey:[cp1 getKey]];
                [[cp2 connectedControlPoints] setObject:cp3 forKey:[cp3 getKey]];
                [[cp3 connectedControlPoints] setObject:cp2 forKey:[cp2 getKey]];
                [[cp3 connectedControlPoints] setObject:cp4 forKey:[cp4 getKey]];
                [[cp4 connectedControlPoints] setObject:cp1 forKey:[cp1 getKey]];
                [[cp4 connectedControlPoints] setObject:cp3 forKey:[cp3 getKey]];
                
                [controlPoints setObject:cp1 forKey:[cp1 getKey]];
                [controlPoints setObject:cp2 forKey:[cp2 getKey]];
                [controlPoints setObject:cp3 forKey:[cp3 getKey]];
                
                PGRRectangle *newRectangle = [[PGRRectangle alloc] initWithPoint1:pointLT point2:pointRT point3:pointRB point4:pointLB];
                [recognizedShape addObject:newRectangle];
                
                NSLog(@"control point number is %d", [controlPoints count]);
                NSLog(@"connected number is %d %d %d %d", [[cp1 connectedControlPoints] count], [[cp2 connectedControlPoints] count], [[cp3 connectedControlPoints] count], [[cp4 connectedControlPoints] count]);
                
                [touchPoints removeAllObjects];
                [self setNeedsDisplay];
                return;
            } else if ([candidateIndice count] >= 2) {
                // add the turning points to the control points dictionary
                DollarPoint *p1 = [touchPoints objectAtIndex:[[candidateIndice objectAtIndex:0] intValue]];
                DollarPoint *p2 = [touchPoints objectAtIndex:[[candidateIndice objectAtIndex:1] intValue]];
                DollarPoint *p3 = [touchPoints firstObject];
                
                
                CGPoint CGP1 = CGPointMake([p1 x], [p1 y]);
                CGPoint CGP2 = CGPointMake([p2 x], [p2 y]);
                CGPoint CGP3 = CGPointMake([p3 x], [p3 y]);
                PGRControlPoint *cp1 = [[PGRControlPoint alloc] initWithCGPoint:CGP1];
                PGRControlPoint *cp2 = [[PGRControlPoint alloc] initWithCGPoint:CGP2];
                PGRControlPoint *cp3 = [controlPoints objectForKey:[NSValue valueWithCGPoint:CGP3]];
                
                // add the conneting status to the adjacent table
                [[cp1 connectedControlPoints] setObject:cp2 forKey:[cp2 getKey]];
                [[cp1 connectedControlPoints] setObject:cp3 forKey:[cp3 getKey]];
                [[cp2 connectedControlPoints] setObject:cp1 forKey:[cp1 getKey]];
                [[cp2 connectedControlPoints] setObject:cp3 forKey:[cp3 getKey]];
                [[cp3 connectedControlPoints] setObject:cp2 forKey:[cp2 getKey]];
                [[cp3 connectedControlPoints] setObject:cp1 forKey:[cp1 getKey]];
                
                [controlPoints setObject:cp1 forKey:[cp1 getKey]];
                [controlPoints setObject:cp2 forKey:[cp2 getKey]];
                
                PGRTriangle *newTriangle = [[PGRTriangle alloc] initWithPoint1:p1 point2:p2 point3:p3];
                [recognizedShape addObject:newTriangle];
                
                [touchPoints removeAllObjects];
                [self setNeedsDisplay];
                
                NSLog(@"control point number is %d", [controlPoints count]);
                NSLog(@"connected number is %d %d %d", [[cp1 connectedControlPoints] count], [[cp2 connectedControlPoints] count], [[cp3 connectedControlPoints] count]);
                return;
            } else { // not recognized, clean everything
                // remove the control point if itself has generated a control point but not recognized
                if (!startHasCP) {
                    CGPoint startingPoint = CGPointMake([originalStart x], [originalStart y]);
                    [controlPoints removeObjectForKey:[NSValue valueWithCGPoint:startingPoint]];
                }
                [touchPoints removeAllObjects];
                [self setNeedsDisplay];
            }
        }
        
    } else { // for not self-closed stroke
        
        if ([PGRUtil isLineSegment:touchPoints]) {
            // beautify the line segment
            NSLog(@"is Line");
            PGRLine *newLine = [[PGRLine alloc] initWithStartPoint:originalStart endPoint:originalEnd];
            [recognizedShape addObject:newLine];
            if (newClosedShapeFormed) {
                // passing nil to the function means it is a line.
                [recognizedShape addObjectsFromArray:[self searchAndRecognizeFrom:startControlPoint to:endControlPoint withTurningPoints:nil]];
            }
            CGPoint cgp1 = CGPointMake([originalStart x], [originalStart y]);
            CGPoint cgp2 = CGPointMake([originalEnd x], [originalEnd y]);
            PGRControlPoint *cp1 = [controlPoints objectForKey:[NSValue valueWithCGPoint:cgp1]];
            PGRControlPoint *cp2 = [controlPoints objectForKey:[NSValue valueWithCGPoint:cgp2]];
            // set the connecting status
            [[cp1 connectedControlPoints] setObject:cp2 forKey:[cp2 getKey]];
            [[cp2 connectedControlPoints] setObject:cp1 forKey:[cp1 getKey]];
            
            NSLog(@"new closed is %d", newClosedShapeFormed);
        } else {
            // generate the turning points
            NSLog(@"not line");
            
            // candidateIndice contains all the possible turning points
            NSMutableArray *possibleTurningPointsIndice = [[[self findCandidateTurningPoints:touchPoints] allObjects] mutableCopy];
            // sort the indice with ascending order
            NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
            [possibleTurningPointsIndice sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            // filter the possible turning points by evaluating the intersection angle
            NSArray *candidateIndice = [self verifyTurningPoints:possibleTurningPointsIndice inTouchPoints:touchPoints];
            NSLog(@"candidate number is %d", [candidateIndice count]);
            
            if ([candidateIndice count]  < 2) {
                if (newClosedShapeFormed) {
                    if ([[startControlPoint referredStroke] count] > 0) {
                        NSArray *relatedStrokes = [[startControlPoint referredStroke] allValues];
                        for (PGRStroke *stroke in relatedStrokes) {
                            NSMutableArray *pointCloud = [NSMutableArray arrayWithArray:[stroke points]];
                            [pointCloud addObjectsFromArray:touchPoints];
                            DollarResult *r = [dollarP recognize:pointCloud];
                            NSLog(@"is closed, type is %@, score is %f", [r name], [r score]);
                            
                            if ([r score] > 0.0f) {
                                [recognizedShape addObject:[self beautifyCircle:pointCloud retainPoint:originalStart]];
                                [strokes removeObjectForKey:[stroke id]];
                                [controlPoints removeObjectForKey:[startControlPoint getKey]];
                                [controlPoints removeObjectForKey:[endControlPoint getKey]];
                            }                             // remove the control point if itself has generated a control point
                        }
                    }
                    
                    [touchPoints removeAllObjects];
                    [self setNeedsDisplay];
                    NSLog(@"control point number is %d", [controlPoints count]);
                    return;
                    
                } else {
                    // continue to draw
                    PGRStroke *newStroke = [[PGRStroke alloc] init];
                    [newStroke setPoints:[touchPoints copy]];
                    [newStroke setId:@(strokeID)];
                    // bind the stroke to the control points, it's easier to find it later.
                    [[startControlPoint referredStroke] setObject:newStroke forKey:@(strokeID)];
                    [[endControlPoint referredStroke] setObject:newStroke forKey:@(strokeID)];
                    [touchPoints removeAllObjects];
                    [strokes setObject:newStroke forKey:@(strokeID)];
                    [self setNeedsDisplay];
                }
                return;
            } else {
                // if new stroke has several turning points and can be recognized later, just remove the referred unrecognized strokes drew before
                [[startControlPoint referredStroke] removeAllObjects];
                [self setNeedsDisplay];
            }
            
            DollarPoint *startPoint = originalStart;
            DollarPoint *endPoint = nil;

            for (int i = 0; i < [candidateIndice count] - 1; ++i) {
                endPoint = [touchPoints objectAtIndex:[[candidateIndice objectAtIndex:i] intValue]];
                PGRLine *newLine = [[PGRLine alloc] initWithStartPoint:startPoint endPoint:endPoint];
                [recognizedShape addObject:newLine];
                startPoint = endPoint;
            }
            
            PGRLine *newLine = [[PGRLine alloc] initWithStartPoint:startPoint endPoint:originalEnd];
            [recognizedShape addObject:newLine];
            
            // if new shape formed, use a depth first algorithm to search the strokes
            if (newClosedShapeFormed) {
                // recognize new shapes
                [recognizedShape addObjectsFromArray:[self searchAndRecognizeFrom:startControlPoint to:endControlPoint withTurningPoints:candidateIndice]];
            }
            
            PGRControlPoint *lastCP = startControlPoint;
            for (int i = 0; i < [candidateIndice count] - 1; ++i) {
                endPoint = [touchPoints objectAtIndex:[[candidateIndice objectAtIndex:i] intValue]];
                CGPoint tempPoint = CGPointMake([endPoint x], [endPoint y]);
                PGRControlPoint *newControlPoint = [[PGRControlPoint alloc] initWithCGPoint:tempPoint];
                [[lastCP connectedControlPoints] setObject:newControlPoint forKey:[newControlPoint getKey]];
                [[newControlPoint connectedControlPoints] setObject:lastCP forKey:[lastCP getKey]];
                [controlPoints setObject:newControlPoint forKey:[newControlPoint getKey]];
                lastCP = newControlPoint;
            }
            
            [[lastCP connectedControlPoints] setObject:endControlPoint forKey:[endControlPoint getKey]];
            [[endControlPoint connectedControlPoints] setObject:lastCP forKey:[lastCP getKey]];
            [controlPoints setObject:lastCP forKey:[lastCP getKey]];
            
            NSLog(@"new closed is %d", newClosedShapeFormed);
        }
    }
    
    [touchPoints removeAllObjects]; // remove all the points when ends drawing a new stroke
    NSLog(@"control point number is %d", [controlPoints count]);
    [self setNeedsDisplay];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (NSArray *)searchAndRecognizeFrom:(PGRControlPoint *)start to:(PGRControlPoint *)end withTurningPoints:(NSArray *)candidateIndice
{
    NSMutableArray *result = [NSMutableArray array];
    
    int levelNumber;
    if (candidateIndice == nil) {
        levelNumber = 0;
    } else {
        levelNumber = 4 - [candidateIndice count];
    }
    // this is to make sure the level number is a valid level number
    if ([candidateIndice count] > 3) {
        return result;
    }
    
    
    
    return nil;
}

- (NSArray *)verifyTurningPoints:(NSArray *)pointsIndice inTouchPoints:(NSArray *)allTouchPoints
{
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 1; i < [pointsIndice count]; ++i) {
        NSNumber *index = [pointsIndice objectAtIndex:i];
        int realIndex = [index intValue];
        
        NSMutableArray *possibleLine1 = [NSMutableArray array];
        NSMutableArray *possibleLine2 = [NSMutableArray array];
        
        NSNumber *lastIndex = [pointsIndice objectAtIndex:i-1];
        for (int j = realIndex; j >= [lastIndex intValue]; --j) {
            [possibleLine1 addObject:[allTouchPoints objectAtIndex:j]];
        }
        NSNumber *nextIndex = [pointsIndice objectAtIndex:(i+1) % [pointsIndice count]];
        for (int j = realIndex; j <= ([nextIndex intValue] + [allTouchPoints count]) % [allTouchPoints count]; j = (j + 1) % [allTouchPoints count]) {
            [possibleLine2 addObject:[allTouchPoints objectAtIndex:j]];
        }
        if ([PGRUtil isLineSegment:possibleLine1] && [PGRUtil isLineSegment:possibleLine2]) {
            DollarPoint *sameStart = [possibleLine1 firstObject];
            DollarPoint *endPoint1 = [possibleLine1 lastObject];
            DollarPoint *endPoint2 = [possibleLine2 lastObject];
            
            float x1 = [endPoint1 x] - [sameStart x];
            float y1 = [endPoint1 y] - [sameStart y];
            
            float x2 = [endPoint2 x] - [sameStart x];
            float y2 = [endPoint2 y] - [sameStart y];
            
            float consineTheta = (x1 * x2 + y1 * y2) / (sqrt(x1 * x1 + y1 * y1) * sqrt(x2 * x2 + y2 * y2));
            NSLog(@"%f", consineTheta);
            if (consineTheta >= -0.9 && consineTheta <= 0.9) {
                [result addObject:index];
            }
        }
        
    }
    NSLog(@"verified points number is %d", [result count]);
    return result;
}


- (NSSet *)findCandidateTurningPoints:(NSArray *)points
{
    float lengthOfStroke = [PGRUtil calculateLength:points];
    NSLog(@"length of stroke is %f", lengthOfStroke);
    NSMutableArray *diff = [NSMutableArray array];
    
    for (int i = 1; i < [points count] - 1; ++i) {
        DollarPoint *prevPoint = [points objectAtIndex:i-1];
        DollarPoint *nextPoint = [points objectAtIndex:i+1];
        float timeDiff = [nextPoint timeStamp] - [prevPoint timeStamp];
        [diff addObject:[NSNumber numberWithFloat:timeDiff]];
    }
    
    NSMutableSet *result = [[NSMutableSet alloc] init];
    NSMutableSet *checked = [[NSMutableSet alloc] init];
    
    for (int j = 0; j < [points count] / 4 && j < [diff count]; ++j) {
        float max = 0;
        int maxIndex = 0;
        for (int i = 0; i < [diff count]; ++i) {
            NSNumber *index = [NSNumber numberWithInt:i];
            float curDiff = [[diff objectAtIndex:i] floatValue];
            if (curDiff > max) {
                if (![checked containsObject:index]) {
                    max = curDiff;
                    maxIndex = i;
                }
            }
        }
        
        NSNumber *temp = [NSNumber numberWithInt:maxIndex];
        [checked addObject:temp];
        
        BOOL existed = false;
        for (NSNumber *existingIndex in [result allObjects]) {
            DollarPoint *point1 = [points objectAtIndex:[existingIndex intValue]];
            DollarPoint *point2 = [points objectAtIndex:maxIndex];
            CGPoint p1 = CGPointMake([point1 x], [point1 y]);
            CGPoint p2 = CGPointMake([point2 x], [point2 y]);
            float distance = [PGRUtil distance:p1 from:p2];
            if (distance < 5 * lengthOfStroke / [points count]) {
                existed = true;
                break;
            }
        }
        
        if (!existed) {
            [result addObject:temp];
            [self setNeedsDisplay];
        }
        
    }
    
    NSLog(@"all points number is %d, candidate points number is %d", [points count], [result count]);
    return result;
}

- (PGRCircle *)beautifyCircle:(NSArray *)points retainPoint:(DollarPoint *)retainPoint
{
    float xSum = 0;
    float ySum = 0;
    
    NSArray *resampledPoints = [DollarP resample:points numPoints:32];
    
    NSUInteger strokePointNum = [resampledPoints count];
    for (DollarPoint *point in resampledPoints) {
        xSum += [point x];
        ySum += [point y];
    }
    
    CGPoint center = CGPointMake(xSum / strokePointNum, ySum / strokePointNum);
    
    CGPoint startingPoint = CGPointMake([retainPoint x], [retainPoint y]);
    float radius = [PGRUtil distance:center from:startingPoint];
    return [[PGRCircle alloc] initWithCenter:center andRadius:radius];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 5.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    [[UIColor redColor] set];
    
    
    for (DollarPoint *point in touchPoints) {
        CGContextFillRect(context, CGRectMake(point.x - 5, point.y - 5, 10, 10));
    }
    
    for (PGRStroke *stroke in [strokes allValues]) {
        for (DollarPoint *point in [stroke points]) {
            CGContextFillRect(context, CGRectMake(point.x - 5, point.y - 5, 10, 10));
        }
    }
    
    [[UIColor blueColor] set];
    
    for (PGRControlPoint *cp in [controlPoints allValues]) {
        CGContextFillRect(context, CGRectMake([cp coordinates].x - 5, [cp coordinates].y - 5, 10, 10));
    }
    
    /*
    for (NSNumber *value in possibleTurningPointsIndice) {
        NSInteger i = [value integerValue];
        DollarPoint *temp = [touchPoints objectAtIndex:i];
        [[UIColor blackColor] set];
        CGContextFillRect(context, CGRectMake(temp.x - 5, temp.y - 5, 10, 10));
        
    }
    
    for (NSNumber *value in candidateIndice) {
        NSInteger i = [value integerValue];
        DollarPoint *temp = [touchPoints objectAtIndex:i];
        [[UIColor blueColor] set];
        CGContextFillRect(context, CGRectMake(temp.x - 5, temp.y - 5, 10, 10));
        
    }
     */
    
    [[UIColor redColor] set];
    [self drawRecognizeShapeInContext:context];
}

- (void)drawRecognizeShapeInContext:(CGContextRef)context
{
    for (PGRShape *shape in recognizedShape) {
        if ([shape type] == TYPE_CIRCLE) {
            [self drawCircle:(PGRCircle *)shape inContext:context];
        } else if ([shape type] == TYPE_LINE) {
            [self drawLine:(PGRLine *)shape inContext:context];
        } else if ([shape type] == TYPE_TRIANGLE) {
            [self drawTriangle:(PGRTriangle *)shape inContext:context];
        } else if ([shape type] == TYPE_RECTANGLE) {
            [self drawRectangle:(PGRRectangle *)shape inContext:context];
        }
    }
}

- (void)drawTriangle:(PGRTriangle *)shape inContext:(CGContextRef)context
{
    CGContextMoveToPoint(context, [shape p1].x, [shape p1].y);
    CGContextAddLineToPoint(context, [shape p2].x, [shape p2].y);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, [shape p2].x, [shape p2].y);
    CGContextAddLineToPoint(context, [shape p3].x, [shape p3].y);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, [shape p3].x, [shape p3].y);
    CGContextAddLineToPoint(context, [shape p1].x, [shape p1].y);
    CGContextStrokePath(context);
}

- (void)drawRectangle:(PGRRectangle *)shape inContext:(CGContextRef)context
{
    CGContextMoveToPoint(context, [shape p1].x, [shape p1].y);
    CGContextAddLineToPoint(context, [shape p2].x, [shape p2].y);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, [shape p2].x, [shape p2].y);
    CGContextAddLineToPoint(context, [shape p3].x, [shape p3].y);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, [shape p3].x, [shape p3].y);
    CGContextAddLineToPoint(context, [shape p4].x, [shape p4].y);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, [shape p4].x, [shape p4].y);
    CGContextAddLineToPoint(context, [shape p1].x, [shape p1].y);
    CGContextStrokePath(context);
}

- (void)drawCircle:(PGRCircle *)circle inContext:(CGContextRef)context
{
    CGContextAddArc(context, [circle center].x, [circle center].y, [circle radius], 0.0, M_PI * 2.0, YES);
    CGContextStrokePath(context);
}


- (void)drawLine:(PGRLine *)line inContext:(CGContextRef)context
{
    CGContextMoveToPoint(context, [line start].x, [line start].y);
    CGContextAddLineToPoint(context, [line end].x, [line end].y);
    
    CGContextStrokePath(context);
    
}

- (UIColor *)randomColor {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

-(void)searchShape
{
    
}

- (void)clearAll {
    [touchPoints removeAllObjects];
    [controlPoints removeAllObjects];
    [recognizedShape removeAllObjects];
    [strokes removeAllObjects];
    
    strokeID = 0;
    
    [self setNeedsDisplay];
}

@end

