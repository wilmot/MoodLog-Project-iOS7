//
//  MlChartDrawingView.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/23/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlChartDrawingView.h"
#import "Prefs.h"

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

    // Vertical gray line at right edge
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, rect.size.width, 0.0); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height); //draw to this point
    CGContextStrokePath(context);

    if ([self.chartType isEqual:@"Bar"]) {
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

        // Horizontal gray line through middle
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.75);
        CGContextMoveToPoint(context, 0.0, interval*10.0); //start at this point
        CGContextAddLineToPoint(context, rect.size.width, interval*10.0); //draw to this point
        CGContextStrokePath(context);
    }
    else { // Pie
        CGFloat pi = 3.1415926535897932384626433832795;
        CGFloat circumference = 40.0;
        CGFloat centerx = rect.size.width/2.0;
        CGFloat centery = rect.size.height/4.0;
        CGContextAddArc(context,centerx, centery,circumference,0,2*pi,1);
        CGContextDrawPath(context,kCGPathStroke);
        CGFloat loveCount = [self.categoryCounts[love] floatValue];
        CGFloat joyCount = [self.categoryCounts[joy] floatValue];
        CGFloat surpriseCount = [self.categoryCounts[surprise] floatValue];
        CGFloat angerCount = [self.categoryCounts[anger] floatValue];
        CGFloat sadnessCount = [self.categoryCounts[sadness] floatValue];
        CGFloat fearCount = [self.categoryCounts[fear] floatValue];
        CGFloat totalCount = loveCount + joyCount + surpriseCount + fearCount + angerCount + sadnessCount;
        CGFloat loveStart = 3*pi/2.0;
        CGFloat loveEnd = loveStart + 2*pi*(loveCount/totalCount);
        CGFloat joyStart = loveEnd;
        CGFloat joyEnd = joyStart + 2*pi*(joyCount/totalCount);
        CGFloat surpriseStart = joyEnd;
        CGFloat surpriseEnd = surpriseStart + 2*pi*(surpriseCount/totalCount);
        CGFloat angerStart = surpriseEnd;
        CGFloat angerEnd = angerStart + 2*pi*(angerCount/totalCount);
        CGFloat sadnessStart = angerEnd;
        CGFloat sadnessEnd = sadnessStart + 2*pi*(sadnessCount/totalCount);
        CGFloat fearStart = sadnessEnd;
        CGFloat fearEnd = fearStart + 2*pi*(fearCount/totalCount);
        // Love - Green
        CGContextSetFillColor(context, CGColorGetComponents( [[[UIColor greenColor] darkerColor] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,circumference,loveEnd,loveStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Joy - Orange
        CGContextSetFillColor(context, CGColorGetComponents( [[UIColor orangeColor] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,circumference,joyEnd,joyStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Surprise - Purple
        CGContextSetFillColor(context, CGColorGetComponents( [[UIColor purpleColor] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,circumference,surpriseEnd,surpriseStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Anger - Red
        CGContextSetFillColor(context, CGColorGetComponents( [[UIColor redColor] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,circumference,angerEnd,angerStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
       // Sadness - Blue
        CGContextSetFillColor(context, CGColorGetComponents( [[UIColor blueColor] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,circumference,sadnessEnd,sadnessStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Fear - Yellow
        CGContextSetFillColor(context, CGColorGetComponents( [[[UIColor yellowColor] darkerColor] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,circumference,fearEnd,fearStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
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
    barHeight = interval*abs(round(self.chartHeight));
    if (self.chartHeight > 0) {
        barOriginY = interval*10.0 - barHeight;
    }
    else {
        barOriginY = interval*10.0;        
    }
    CGContextFillRect(context, CGRectMake(0.0, barOriginY, rect.size.width, barHeight));
}

@end
