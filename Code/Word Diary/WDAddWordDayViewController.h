//
//  WDAddWordDayViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 22/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDValueSetterModuleViewControllerDataSource.h"
#import "WDValueSetterModuleViewControllerDelegate.h"

@interface WDAddWordDayViewController : UIViewController<WDValueSetterModuleViewControllerDataSource, WDValueSetterModuleViewControllerDelegate>

@end
