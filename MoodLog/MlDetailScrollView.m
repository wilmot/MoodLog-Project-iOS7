//
//  MlDetailScrollView.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 6/13/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlDetailScrollView.h"

@implementation MlDetailScrollView

- (void)setBounds:(CGRect)bounds {
    NSLog(@"Detail Scroll View bounds: %@", NSStringFromCGRect(bounds));
    NSLog(@"Scroll enabled? %hhd",self.scrollEnabled);
    [super setBounds:bounds];
}

@end
