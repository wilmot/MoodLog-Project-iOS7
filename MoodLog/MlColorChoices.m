//
//  MlColorChoices.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/1/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlColorChoices.h"
#import "Prefs.h"

@implementation MlColorChoices

- (id)init{
    if (self = [super init]){
        self.basicColors = @{ love: [UIColor colorWithRed:102/255.0f green:217/255.0f blue:27/255.0f alpha:1.0f],
                              joy: [UIColor colorWithRed:255.0f/255.0f green:158.0f/255.0f blue:29.0f/255.0f alpha:1.0f],
                              surprise: [UIColor colorWithRed:206/255.0f green:82/255.0f blue:212/255.0f alpha:1.0f],
                              anger: [UIColor colorWithRed:246/255.0f green:50/255.0f blue:36/255.0f alpha:1.0f],
                              sadness: [UIColor colorWithRed:69/255.0f green:126/255.0f blue:248/255.0f alpha:1.0f],
                              fear: [UIColor colorWithRed:253/255.0f green:239/255.0f blue:2/255.0f alpha:1.0f],
                              };
        self.textColors = @{ love: [UIColor colorWithRed:102/255.0f green:217/255.0f blue:27/255.0f alpha:1.0f],
                             joy: [UIColor colorWithRed:218/255.0f green:122/255.0f blue:22/255.0f alpha:1.0f],
                             surprise: [UIColor colorWithRed:206/255.0f green:82/255.0f blue:212/255.0f alpha:1.0f],
                             anger: [UIColor colorWithRed:246/255.0f green:50/255.0f blue:36/255.0f alpha:1.0f],
                             sadness: [UIColor colorWithRed:69/255.0f green:126/255.0f blue:248/255.0f alpha:1.0f],
                             fear: [UIColor colorWithRed:204/255.0f green:194/255.0f blue:9/255.0f alpha:1.0f],
                             };
        self.textDesaturatedColors = @{ love: [UIColor colorWithRed:183/255.0f green:210/255.0f blue:166/255.0f alpha:1.0f],
                             joy: [UIColor colorWithRed:209/255.0f green:179/255.0f blue:149/255.0f alpha:1.0f],
                             surprise: [UIColor colorWithRed:200/255.0f green:164/255.0f blue:202/255.0f alpha:1.0f],
                             anger: [UIColor colorWithRed:242/255.0f green:178/255.0f blue:175/255.0f alpha:1.0f],
                             sadness: [UIColor colorWithRed:169/255.0f green:191/255.0f blue:246/255.0f alpha:1.0f],
                             fear: [UIColor colorWithRed:207/255.0f green:205/255.0f blue:145/255.0f alpha:1.0f],
                             };
        self.mutedColors = @{love: [[UIColor greenColor] lighterColor],
                             joy: [[UIColor orangeColor] lighterColor],
                             surprise: [[UIColor purpleColor] lighterColor],
                             anger: [[UIColor redColor] lighterColor],
                             sadness: [[UIColor blueColor] lighterColor],
                             fear: [[UIColor yellowColor] lighterColor]};
        self.translucentColors = @{ love: [UIColor colorWithRed:102/255.0f green:217/255.0f blue:27/255.0f alpha:0.2f],
                                    joy: [UIColor colorWithRed:255.0f/255.0f green:158.0f/255.0f blue:29.0f/255.0f alpha:0.2f],
                                    surprise: [UIColor colorWithRed:206/255.0f green:82/255.0f blue:212/255.0f alpha:0.2f],
                                    anger: [UIColor colorWithRed:246/255.0f green:50/255.0f blue:36/255.0f alpha:0.2f],
                                    sadness: [UIColor colorWithRed:69/255.0f green:126/255.0f blue:248/255.0f alpha:0.2f],
                                    fear: [UIColor colorWithRed:253/255.0f green:239/255.0f blue:2/255.0f alpha:0.2f],
                                    };

    }
    return self;
}

+ (NSDictionary *) basicColors {
    MlColorChoices *newColorChoices = [[MlColorChoices alloc] init];
    return newColorChoices.basicColors;
}

+ (NSDictionary *) textColors {
    MlColorChoices *newColorChoices = [[MlColorChoices alloc] init];
    return newColorChoices.textColors;
}

+ (NSDictionary *) textDesaturatedColors {
    MlColorChoices *newColorChoices = [[MlColorChoices alloc] init];
    return newColorChoices.textDesaturatedColors;
}

+ (NSDictionary *) mutedColors {
    MlColorChoices *newColorChoices = [[MlColorChoices alloc] init];
    return newColorChoices.mutedColors;
}

+ (NSDictionary *) translucentColors: (float) translucency {
    return @{ love: [UIColor colorWithRed:102/255.0f green:217/255.0f blue:27/255.0f alpha:translucency],
              joy: [UIColor colorWithRed:255.0f/255.0f green:158.0f/255.0f blue:29.0f/255.0f alpha:translucency],
              surprise: [UIColor colorWithRed:206/255.0f green:82/255.0f blue:212/255.0f alpha:translucency],
              anger: [UIColor colorWithRed:246/255.0f green:50/255.0f blue:36/255.0f alpha:translucency],
              sadness: [UIColor colorWithRed:69/255.0f green:126/255.0f blue:248/255.0f alpha:translucency],
              fear: [UIColor colorWithRed:253/255.0f green:239/255.0f blue:2/255.0f alpha:translucency],
              };
}


@end
