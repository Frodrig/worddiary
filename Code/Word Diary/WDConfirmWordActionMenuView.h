//
//  WDConfirmWordActionMenuView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDConfirmWordActionMenuView : UIView

@property (weak, nonatomic) IBOutlet UILabel  *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;

@end
