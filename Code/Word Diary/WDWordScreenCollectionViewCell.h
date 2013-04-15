//
//  WDWordCollectionViewCell.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDWord;

@interface WDWordScreenCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *wordLabelTmp;

- (void) setWord:(WDWord *)word;

@end
