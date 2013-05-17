//
//  MlCollectionViewCell.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/18/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlCollectionViewCell.h"

@implementation MlCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if ([self.reuseIdentifier isEqual:@"moodCellFaces"]) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        // Horizontal gray line along bottom
        CGContextSetRGBStrokeColor(context, 0.6, 0.6, 0.6, 0.45); // red, green, blue, alpha
        CGContextMoveToPoint(context, 0.0, rect.size.height); //start at this point
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height); //draw to this point
        CGContextStrokePath(context);
    }
}

@end
