//
//  WDAuxiliaryScreenAboutPanelView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDAuxiliaryScreenAboutPanelView : UIView

@property (weak, nonatomic) IBOutlet UILabel  *wordDiaryTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *wordDiaryURLButton;
@property (weak, nonatomic) IBOutlet UILabel  *designedAndDevelopedByLabel;
@property (weak, nonatomic) IBOutlet UILabel  *developerNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *twitterURLButton;
@property (weak, nonatomic) IBOutlet UILabel  *allRightReservedLabel;
@end
