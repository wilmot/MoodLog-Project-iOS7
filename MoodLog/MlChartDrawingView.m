//
//  MlChartDrawingView.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/23/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlChartDrawingView.h"

@implementation MlChartDrawingView

static NSUInteger numberOfDivisions = 20;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSUInteger interval = rect.size.height/numberOfDivisions;
  
    // Draw the chart bar
    [self drawChartBar:rect];

    // Horizontal stripes
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.25);
    for (NSUInteger i=0; i<=20*interval; i+=interval) {
        CGContextMoveToPoint(context, 0.0, i); //start at this point
        CGContextAddLineToPoint(context, rect.size.width, i); //draw to this point
        CGContextStrokePath(context);
    }

    // Vertical gray line at right edge
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, rect.size.width, 0.0); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height); //draw to this point
    CGContextStrokePath(context);

    // Horizontal gray line through middle
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.75);
    CGContextMoveToPoint(context, 0.0, interval*10.0); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, interval*10.0); //draw to this point
    CGContextStrokePath(context);
        
}

-(void) drawChartBar: (CGRect) rect {
    CGFloat barHeight, barOriginY;
    NSUInteger interval = rect.size.height/numberOfDivisions;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.25, 0.75, 0.25, 0.25);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    
    // Bar should start in the middle
    // and draw up for positive, down for negative
    // Range is -10..10
    barHeight =  interval*abs(self.chartHeight);
    if (self.chartHeight > 0) {
        barOriginY = interval*10.0 - barHeight;
    }
    else {
        barOriginY = interval*10.0;        
    }
    CGContextFillRect(context, CGRectMake(0.0, barOriginY, rect.size.width, barHeight));
}

@end
