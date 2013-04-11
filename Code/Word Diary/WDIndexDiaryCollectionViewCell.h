//
//  WDIndexDiaryCollectionViewCell.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 10/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDIndexDiaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayDiaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView  *wordContainerView;

- (void)showInitialLetterOfWord:(NSString *)word fontFamily:(NSString *)font andColor:(UIColor *)color;
- (void)showAllLettersOfWord:(NSString *)word fontFamily:(NSString *)font andColor:(UIColor *)color;
- (void)hideWord;

@end
