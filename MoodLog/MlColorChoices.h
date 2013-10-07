//
//  MlColorChoices.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/1/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MlColorChoices : NSObject

@property (strong, nonatomic) NSDictionary *basicColors;
@property (strong, nonatomic) NSDictionary *textColors;
@property (strong, nonatomic) NSDictionary *textDesaturatedColors;
@property (strong, nonatomic) NSDictionary *mutedColors;
@property (strong, nonatomic) NSDictionary *translucentColors;


+ (NSDictionary *) basicColors;
+ (NSDictionary *) textColors;
+ (NSDictionary *) textDesaturatedColors;
+ (NSDictionary *) mutedColors;
+ (NSDictionary *) translucentColors: (float) translucency;

@end
