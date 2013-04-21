//
//  WDMainMenuViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 21/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDMainMenuViewControllerDelegate.h"
#import "WDMainMenuViewControllerDataSource.h"

@interface WDMainMenuViewController : UIViewController

@property(nonatomic, weak)id<WDMainMenuViewControllerDelegate> delegate;
@property(nonatomic, weak)id<WDMainMenuViewControllerDataSource> dataSource;

@end
