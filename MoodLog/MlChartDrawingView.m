//
//  MlChartDrawingView.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/23/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlChartDrawingView.h"
#import "Prefs.h"
#import "MlColorChoices.h"

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

//- (void)setBounds:(CGRect)bounds {
//    NSLog(@"Chart drawing view: %@", NSStringFromCGRect(bounds));
//    [super setBounds:bounds];
//}

-(void) drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDictionary *colorz = [MlColorChoices basicColors];
    
    if ([self.chartType isEqual:@"Bar"]) { // Bar chart
        NSUInteger interval = rect.size.height/numberOfDivisions;
      
        // Draw the chart bar
        [self drawChartBars:rect];
        
        // Outline
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextStrokeRect(context, rect);

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
        if (self.circumference == 0.0) {
            self.circumference = 40.0; // default circumference
        }
        CGFloat centerx = rect.size.width/2.0;
        CGFloat centery;
        if (self.dividerLine) { // hacky way of telling that I'm on the chart page
             centery = rect.size.height/4.0;
        }
        else { // I'm on the detailView
             centery = rect.size.height/2.0;
        }
        
        // Outline around pie chart
//        CGContextAddArc(context,centerx, centery,self.circumference,0,2*pi,1);
//        CGContextDrawPath(context,kCGPathStroke);
        
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
        CGContextSetFillColor(context, CGColorGetComponents( [[colorz objectForKey:love] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,self.circumference,loveEnd,loveStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Joy - Orange
        CGContextSetFillColor(context, CGColorGetComponents( [[colorz objectForKey:joy] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,self.circumference,joyEnd,joyStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Surprise - Purple
        CGContextSetFillColor(context, CGColorGetComponents( [[colorz objectForKey:surprise] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,self.circumference,surpriseEnd,surpriseStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Anger - Red
        CGContextSetFillColor(context, CGColorGetComponents( [[colorz objectForKey:anger] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,self.circumference,angerEnd,angerStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
       // Sadness - Blue
        CGContextSetFillColor(context, CGColorGetComponents( [[colorz objectForKey:sadness] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,self.circumference,sadnessEnd,sadnessStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
        // Fear - Yellow
        CGContextSetFillColor(context, CGColorGetComponents( [[colorz objectForKey:fear] CGColor]));
        CGContextMoveToPoint(context, centerx, centery);
        CGContextAddArc(context,centerx,centery,self.circumference,fearEnd,fearStart,1);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    
    // Vertical gray line at right edge
    if (self.dividerLine) {
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, rect.size.width, 0.0); //start at this point
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height); //draw to this point
        CGContextStrokePath(context);
    }
}

-(void) drawChartBars: (CGRect) rect {
    CGFloat barHeight, barOriginY;
    NSUInteger interval = rect.size.height/numberOfDivisions;
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11], NSFontAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
   // CGContextSetRGBFillColor(context, 0.25, 0.75, 0.25, 0.25);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    
    // Overall
    // Bar should start in the middle
    // and draw up for positive, down for negative
    // Range is -10..10
    barHeight = interval*fabs(round(self.chartHeightOverall));
    if (self.chartHeightOverall > 0) {
        barOriginY = interval*10.0 - barHeight;
    }
    else {
        barOriginY = interval*10.0;
    }
    CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightOverall] CGColor]);
    CGRect overallRect = CGRectMake(0.0, barOriginY, rect.size.width/4 - 1, barHeight);
    CGRect overallBoundingRect = CGRectMake(0.0, 0.0, rect.size.width/4 - 1, interval*10.0);
    CGContextFillRect(context, overallRect);
    [@"Overall" drawInRect:overallBoundingRect withAttributes:attrsDictionary];

    // Sleep
    barHeight = interval*fabs(round(self.chartHeightSleep));
    if (self.chartHeightSleep > 0) {
        barOriginY = interval*10.0 - barHeight;
    }
    else {
        barOriginY = interval*10.0;
    }
    CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightSleep] CGColor]);
    CGRect sleepRect = CGRectMake(0.0 + rect.size.width/4, barOriginY, rect.size.width/4 - 1, barHeight);
    CGRect sleepBoundingRect = CGRectMake(0.0 + rect.size.width/4, 0.0, rect.size.width/4 - 1, interval*10.0);
    CGContextFillRect(context, sleepRect);
    [@"Sleep" drawInRect:sleepBoundingRect withAttributes:attrsDictionary];

    // Energy
    barHeight = interval*fabs(round(self.chartHeightEnergy));
    if (self.chartHeightEnergy > 0) {
        barOriginY = interval*10.0 - barHeight;
    }
    else {
        barOriginY = interval*10.0;
    }
    CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightEnergy] CGColor]);
    CGRect energyRect = CGRectMake(0.0 + 2*rect.size.width/4, barOriginY, rect.size.width/4 - 1, barHeight);
    CGRect energyBoundingRect = CGRectMake(0.0 + 2*rect.size.width/4, 0.0, rect.size.width/4 - 1, interval*10.0);
    CGContextFillRect(context, energyRect);
    [@"Energy" drawInRect:energyBoundingRect withAttributes:attrsDictionary];

    // Health
    barHeight = interval*fabs(round(self.chartHeightHealth));
    if (self.chartHeightHealth > 0) {
        barOriginY = interval*10.0 - barHeight;
    }
    else {
        barOriginY = interval*10.0;
    }
    CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightHealth] CGColor]);
    CGRect healthRect = CGRectMake(0.0 + 3*rect.size.width/4, barOriginY, rect.size.width/4 - 1, barHeight);
    CGRect healthBoundingRect = CGRectMake(0.0 + 3*rect.size.width/4, 0.0, rect.size.width/4 - 1, interval*10.0);
    CGContextFillRect(context, healthRect);
    [@"Health" drawInRect:healthBoundingRect withAttributes:attrsDictionary];
}

- (UIColor *) theBarColor: (CGFloat) barHeight {
    UIColor *barColor;
    if (barHeight >= 0) { // Tint green
        barColor = [UIColor colorWithRed:fabsf((barHeight  - 10.0)/20.0) green:(barHeight + 10.0)/20.0 blue:1.0 - (barHeight + 10.0)/20.0 alpha:1.0];
    }
    else { // Tint red
        barColor = [UIColor colorWithRed:fabsf((barHeight - 10.0)/20.0) green:(barHeight + 10.0)/20.0 blue:1.0 - fabsf((barHeight - 10.0)/20.0) alpha:1.0];
    }
    return barColor;
}

@end
