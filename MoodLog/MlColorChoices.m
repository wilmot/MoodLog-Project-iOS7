//
//  MlColorChoices.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/1/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlColorChoices.h"
#import "Prefs.h"

@implementation MlColorChoices

- (id)init{
    if (self = [super init]){
        self.basicColors = @{love : [[UIColor greenColor] darkerColor],
                             joy : [UIColor orangeColor],
                             surprise : [UIColor purpleColor],
                             anger : [UIColor redColor],
                             sadness : [UIColor blueColor],
                             fear : [[[UIColor yellowColor] darkerColor] darkerColor]};
        NSLog(@"testing...");
        self.mutedColors = @{love: [[UIColor greenColor] lighterColor],
                             joy: [[UIColor orangeColor] lighterColor],
                             surprise: [[UIColor purpleColor] lighterColor],
                             anger: [[UIColor redColor] lighterColor],
                             sadness: [[UIColor blueColor] lighterColor],
                             fear: [[UIColor yellowColor] lighterColor]};
        
    }
    return self;
}

+ (NSDictionary *) basicColors {
    MlColorChoices *newColorChoices = [[MlColorChoices alloc] init];
    return newColorChoices.basicColors;
}

+ (NSDictionary *) mutedColors {
    MlColorChoices *newColorChoices = [[MlColorChoices alloc] init];
    return newColorChoices.mutedColors;
}


@end
