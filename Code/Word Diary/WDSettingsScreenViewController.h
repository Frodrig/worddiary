//
//  WDSettingsScreenViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 24/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDSettingsScreenViewControllerDelegate.h"

@interface WDSettingsScreenViewController : UIViewController

@property(nonatomic, weak)id<WDSettingsScreenViewControllerDelegate>delegate;

@end
