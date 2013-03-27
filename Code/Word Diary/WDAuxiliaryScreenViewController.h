//
//  WDAuxiliaryScreenViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDAuxiliaryScreenViewControllerDelegate.h"

@interface WDAuxiliaryScreenViewController : UIViewController

@property(nonatomic, weak) id<WDAuxiliaryScreenViewControllerDelegate> delegate;

- (void)showSupportScreenInView:(UIView *)view withDuration:(CGFloat)duration;
- (void)showAboutScreenInView:(UIView *)view withDuration:(CGFloat)duration;
- (void)showSettingsScreenInView:(UIView *)view withDuration:(CGFloat)duration;
- (void)showTipsScreenInView:(UIView *)view withDuration:(CGFloat)duration;

- (void)hideWithDuration:(CGFloat)duration;

- (BOOL)isShowed;

@end
