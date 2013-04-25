//
//  WDHelpScreenViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDHelpScreenViewControllerDelegate.h"

@interface WDHelpScreenViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic, weak)id<WDHelpScreenViewControllerDelegate>    delegate;

@end
