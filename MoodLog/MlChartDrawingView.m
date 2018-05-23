//
//  MlChartDrawingView.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/23/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlChartDrawingView.h"
#import "Prefs.h"
#import "MlColorChoices.h"

@implementation MlChartDrawingView

static NSUInteger numberOfDivisions = 20.0;
static CGFloat pi = 3.1415926535897932384626433832795;
static CGFloat sidewaysWidthThreshhold = 64.0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.chartFontSize = 14.0; // Default font size
    }
    return self;
}

-(void) drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDictionary *colorz = [MlColorChoices basicColors];
    NSUInteger interval = rect.size.height/numberOfDivisions;

    // Outline
    if (self.drawOutline) {
        CGRect outlineRect = CGRectMake(0.0, 0.0, rect.size.width, interval*(numberOfDivisions) + 10);
        CGContextSetLineWidth(context, 0.25);
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextStrokeRect(context, outlineRect);
    }

    if ([self.chartType isEqual:@"Bar"]) { // Bar chart
      
        // Draw the chart bar
        [self drawChartBars:rect];

        // Horizontal stripes
        CGContextSetLineWidth(context, 2.0);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.25);
        for (NSUInteger i=0; i<=20*interval; i+=interval) {
            CGContextMoveToPoint(context, 0.0, i); //start at this point
            CGContextAddLineToPoint(context, rect.size.width, i); //draw to this point
            CGContextStrokePath(context);
        }

        // Horizontal gray line through middle
        CGContextSetLineWidth(context, 0.5);
        CGContextSetRGBStrokeColor(context, 0.4, 0.4, 0.4, 0.55);
        CGContextMoveToPoint(context, 0.0, interval*10.0); //start at this point
        CGContextAddLineToPoint(context, rect.size.width, interval*10.0); //draw to this point
        CGContextStrokePath(context);
    }
    else { // Pie
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
    CGFloat numberOfBars = 6;
    NSUInteger interval = rect.size.height/numberOfDivisions;
    CGContextRef context = UIGraphicsGetCurrentContext();
   // CGContextSetRGBFillColor(context, 0.25, 0.75, 0.25, 0.25);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]); // Start with white
    if (self.chartFactorType == 0) { // If the chart type is empty
        self.chartFactorType = AllType;
    }

    // Overall Mood
    // Bar should start in the middle
    // and draw up for positive, down for negative
    // Range is -10..10
    if (self.chartFactorType == AllType || self.chartFactorType == MoodType) {
        barHeight = interval*fabs(round(self.chartHeightOverall));
        if (self.chartHeightOverall > 0) {
            barOriginY = interval*10.0 - barHeight;
        }
        else {
            barOriginY = interval*10.0;
        }
        CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightOverall] CGColor]);
        CGRect overallRect = CGRectMake(0.0, barOriginY, rect.size.width/numberOfBars - 1, barHeight);
        CGRect overallBoundingRect = CGRectMake(0.0, 0.0, rect.size.width/numberOfBars - 1, interval*10.0);
        CGContextFillRect(context, overallRect);
        [self drawTextInBar:NSLocalizedString(@"Mood", @"Mood") inRect:overallBoundingRect withContext:context];
    }
    
    // Stress
    if (self.chartFactorType == AllType || self.chartFactorType == StressType) {
        barHeight = interval*fabs(round(self.chartHeightStress));
        if (self.chartHeightStress > 0) {
            barOriginY = interval*10.0 - barHeight;
        }
        else {
            barOriginY = interval*10.0;
        }
        CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightStress] CGColor]);
        CGRect stressRect = CGRectMake(0.0 + rect.size.width/numberOfBars, barOriginY, rect.size.width/numberOfBars - 1, barHeight);
        CGRect stressBoundingRect = CGRectMake(0.0 + rect.size.width/numberOfBars, 0.0, rect.size.width/numberOfBars - 1, interval*10.0);
        CGContextFillRect(context, stressRect);
        [self drawTextInBar:NSLocalizedString(@"Stress", @"Stress") inRect:stressBoundingRect withContext:context];
    }
    
    // Energy
    if (self.chartFactorType == AllType || self.chartFactorType == EnergyType) {
        barHeight = interval*fabs(round(self.chartHeightEnergy));
        if (self.chartHeightEnergy > 0) {
            barOriginY = interval*10.0 - barHeight;
        }
        else {
            barOriginY = interval*10.0;
        }
        CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightEnergy] CGColor]);
        CGRect energyRect = CGRectMake(0.0 + 2*rect.size.width/numberOfBars, barOriginY, rect.size.width/numberOfBars - 1, barHeight);
        CGRect energyBoundingRect = CGRectMake(0.0 + 2*rect.size.width/numberOfBars, 0.0, rect.size.width/numberOfBars - 1, interval*10.0);
        CGContextFillRect(context, energyRect);
        [self drawTextInBar:NSLocalizedString(@"Energy", @"Energy") inRect:energyBoundingRect withContext:context];
    }
    
    // Thoughts
    if (self.chartFactorType == AllType || self.chartFactorType == ThoughtsType) {
        barHeight = interval*fabs(round(self.chartHeightThoughts));
        if (self.chartHeightThoughts > 0) {
            barOriginY = interval*10.0 - barHeight;
        }
        else {
            barOriginY = interval*10.0;
        }
        CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightThoughts] CGColor]);
        CGRect thoughtsRect = CGRectMake(0.0 + 3*rect.size.width/numberOfBars, barOriginY, rect.size.width/numberOfBars - 1, barHeight);
        CGRect thoughtsBoundingRect = CGRectMake(0.0 + 3*rect.size.width/numberOfBars, 0.0, rect.size.width/numberOfBars - 1, interval*10.0);
        CGContextFillRect(context, thoughtsRect);
        [self drawTextInBar:NSLocalizedString(@"Mindfulness", @"Mindfulness") inRect:thoughtsBoundingRect withContext:context];
    }
    
    // Health
    if (self.chartFactorType == AllType || self.chartFactorType == HealthType) {
        barHeight = interval*fabs(round(self.chartHeightHealth));
        if (self.chartHeightHealth > 0) {
            barOriginY = interval*10.0 - barHeight;
        }
        else {
            barOriginY = interval*10.0;
        }
        CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightHealth] CGColor]);
        CGRect healthRect = CGRectMake(0.0 + 4*rect.size.width/numberOfBars, barOriginY, rect.size.width/numberOfBars - 1, barHeight);
        CGRect healthBoundingRect = CGRectMake(0.0 + 4*rect.size.width/numberOfBars, 0.0, rect.size.width/numberOfBars - 1, interval*10.0);
        CGContextFillRect(context, healthRect);
        [self drawTextInBar:NSLocalizedString(@"Health", @"Health") inRect:healthBoundingRect withContext:context];
    }
    
    // Sleep
    if (self.chartFactorType == AllType || self.chartFactorType == SleepType) {
        barHeight = interval*fabs(round(self.chartHeightSleep));
        if (self.chartHeightSleep > 0) {
            barOriginY = interval*10.0 - barHeight;
        }
        else {
            barOriginY = interval*10.0;
        }
        CGContextSetFillColorWithColor(context, [[self theBarColor:self.chartHeightSleep] CGColor]);
        CGRect sleepRect = CGRectMake(0.0 + 5*rect.size.width/numberOfBars, barOriginY, rect.size.width/numberOfBars - 1, barHeight);
        CGRect sleepBoundingRect = CGRectMake(0.0 + 5*rect.size.width/numberOfBars, 0.0, rect.size.width/numberOfBars - 1, interval*10.0);
        CGContextFillRect(context, sleepRect);
        [self drawTextInBar:NSLocalizedString(@"Sleep", @"Sleep") inRect:sleepBoundingRect withContext:context];
    }
}

- (UIColor *) theBarColor: (CGFloat) barHeight {
    UIColor *barColor;
    if (barHeight >= 0) { // Tint green
        barColor = [UIColor colorWithRed:fabs((barHeight  - 10.0)/20.0) green:(barHeight + 10.0)/20.0 blue:1.0 - (barHeight + 10.0)/20.0 alpha:1.0];
    }
    else { // Tint red
        barColor = [UIColor colorWithRed:fabs((barHeight - 10.0)/20.0) green:(barHeight + 10.0)/20.0 blue:1.0 - fabs((barHeight - 10.0)/20.0) alpha:1.0];
    }
    return barColor;
}

- (void) drawTextInBar: (NSString *)text inRect:(CGRect) rect withContext:(CGContextRef) context {
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:self.chartFontSize], NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
    if (rect.size.width > sidewaysWidthThreshhold) { // Horizontal text
        CGRect hRect = CGRectMake(rect.origin.x, rect.origin.y + 2.0, rect.size.width, rect.size.height);
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [text drawInRect:hRect withAttributes:attrsDictionary];
        }
        else {
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attrsDictionary];
            [attributedText drawInRect:hRect];
        }
    }
    else { // Vertical text
        CGPoint point = CGPointMake(rect.origin.x + rect.size.width/2.0 - 6.0, rect.origin.y + rect.size.height*2.0 - 4.0);
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
        CGContextTranslateCTM(context, point.x, point.y);
        CGAffineTransform textTransform = CGAffineTransformMakeRotation(-pi/2);
        CGContextConcatCTM(context, textTransform);
        CGContextTranslateCTM(context, -point.x, -point.y);
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:self.chartFontSize], NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.75]};
        [text drawAtPoint:CGPointMake(rect.origin.x + rect.size.width/2.0 - 6.0, rect.origin.y + rect.size.height*2.0 - 4.0) withAttributes: attributes];
        CGContextRestoreGState(context);
    }
}

@end
