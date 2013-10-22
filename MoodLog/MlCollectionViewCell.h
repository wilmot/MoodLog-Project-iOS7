//
//  MlCollectionViewCell.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/18/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MlCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *moodName;
@property (weak, nonatomic) IBOutlet UILabel *checkMark;
@property (weak, nonatomic) IBOutlet UIImageView *face;

@end
