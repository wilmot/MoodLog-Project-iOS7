//
//  MlDateRangeDrawing.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/28/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlDateRangeDrawing.h"

@implementation MlDateRangeDrawing

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    float start = rect.size.width*self.startValue.floatValue;
    float end = rect.size.width*self.endValue.floatValue;

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Outline of whole rect
    CGContextSetRGBFillColor(context, 232/255.0, 139/255.0, 140/255.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextStrokeRect(context, rect );

    // Dates rect
    CGContextSetRGBFillColor(context, 232/255.0, 139/255.0, 140/255.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGRect datesRect = CGRectMake(0.0 + start, 0.7, end - start, rect.size.height);
    CGContextFillRect(context, datesRect);

    // Line at far left
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextMoveToPoint(context, 0.5, 0.0); //start at this point
    CGContextAddLineToPoint(context, 0.5, rect.size.height); //draw to this point
    CGContextStrokePath(context);
    // Line at far right
    CGContextMoveToPoint(context, rect.size.width - 0.5, 0.0); //start at this point
    CGContextAddLineToPoint(context, rect.size.width - 0.5, rect.size.height); //draw to this point
    CGContextStrokePath(context);

    // Vertical line showing where sliders are at
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
 
    CGContextMoveToPoint(context, start, 0.0); //start at this point
    CGContextAddLineToPoint(context, start, rect.size.height); //draw to this point
    CGContextStrokePath(context);
    if (end != start) {
        CGContextMoveToPoint(context, end, 0.0); //start at this point
        CGContextAddLineToPoint(context, end, rect.size.height); //draw to this point
        CGContextStrokePath(context);
    }

    
}

@end
