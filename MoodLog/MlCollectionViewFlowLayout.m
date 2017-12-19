//
//  MlCollectionViewFlowLayout.m
//  Mood-Log
//
//  Created by Barry Langdon-Lassagne on 12/18/17.
//  Copyright © 2017 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlCollectionViewFlowLayout.h"

@implementation MlCollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
