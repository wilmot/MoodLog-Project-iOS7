//
//  MlEmailEventCountDrawing.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 6/2/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlEmailEventCountDrawing.h"
#import <QuartzCore/QuartzCore.h>

@implementation MlEmailEventCountDrawing

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
//    CGFloat colorsGloss [] = {
//        1.0, 1.0, 1.0, 0.35,
//        1.0, 1.0, 1.0, 0.1
//    };
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 2.0);
        
//    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
//    CGContextFillRect(context, CGRectMake(0.0, 0.0, rect.size.width, rect.size.height));
//    CGContextStrokeRect(context, CGRectMake(0.0, 0.0, rect.size.width, rect.size.height));
//    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
// 
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
//    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//    
//    gradient = CGGradientCreateWithColorComponents(baseSpace, colorsGloss, NULL, 2);
//    startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
//    endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    [self drawRoundedRect:context rect:rect radius:10.0];
}

- (void)drawRoundedRect:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat)radius {
//    CGFloat colors [] = {
//        1.0, 1.0, 1.0, 1.0,
//        0.8, 0.0, 0.0, 1.0
//    };
	
    CGContextSaveGState(context);
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();

	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.0); // clear fill
    CGContextSetLineWidth(context, 12.0);
   
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
    
	// Fill & stroke the path
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
//    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextSetRGBFillColor(context, 255/255.0, 255/255.0, 255/255.0, 1.0);
    CGContextFillRect(context, rect);

	CGContextDrawPath(context, kCGPathFillStroke);
//    CFRelease(gradient);
    CFRelease(baseSpace);
 
//    CGContextSetLineWidth(context, 0.5);
//	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5);
//	// Start at 1
//	CGContextMoveToPoint(context, minx, midy);
//	// Add an arc through 2 to 3
//	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
//	// Add an arc through 4 to 5
//	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
//	// Add an arc through 6 to 7
//	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
//	// Add an arc through 8 to 9
//	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
//	// Close the path
//	CGContextClosePath(context);
//	// Fill & stroke the path
//	CGContextDrawPath(context, kCGPathFillStroke);

    CGContextRestoreGState(context);
}

@end
