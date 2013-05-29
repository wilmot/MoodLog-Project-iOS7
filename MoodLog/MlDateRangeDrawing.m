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
    // Vertical gray line if values match
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, start, 0.0); //start at this point
    CGContextAddLineToPoint(context, start, rect.size.height); //draw to this point
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, end, 0.0); //start at this point
    CGContextAddLineToPoint(context, end, rect.size.height); //draw to this point
    CGContextStrokePath(context);

    CGContextSetRGBFillColor(context, 0.75, 0.75, 0.75, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, CGRectMake(0.0 + start, 0.7, end - start, rect.size.height));

}

@end
