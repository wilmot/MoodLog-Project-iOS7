//
//  MlChartCollectionViewCell.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/22/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlChartCollectionViewCell.h"
#import "MlChartCellEntryViewController.h"

@implementation MlChartCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)pressDetailButton:(id)sender {
    // TODO: Okay, I don't know what I'm doing here, which is probably why it isn't working :-)
    // I want to show more information when the button is pressed, but I need to understand the view hierarchy more completely
//    self.myViewController.aString = [[self.detailItem valueForKey:@"date"] description];
    self.myViewController.detailItem = self.detailItem;
    [self.myViewController performSegueWithIdentifier:@"chartCellDetail" sender:self.myViewController];
}
@end
