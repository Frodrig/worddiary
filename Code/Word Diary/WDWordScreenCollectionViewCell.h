//
//  WDWordCollectionViewCell.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDWordRepresentationView.h"

@class WDWord;

@interface WDWordScreenCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView                   *dateContainerView;
@property (weak, nonatomic) IBOutlet UIView                   *wordRepresentationContainerView;
@property (weak, nonatomic) IBOutlet WDWordRepresentationView *wordRepresentationView;

- (void) setWord:(WDWord *)word;

- (void) fadeInDecoratorText;
- (void) fadeOutDecoratorText;

@end
