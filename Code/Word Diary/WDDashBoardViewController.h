//
//  WDDashBoardViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDDashBoardViewControllerDelegate.h"
#import "WDSettingsScreenViewControllerDelegate.h"
#import "WDDashBoardViewControllerDataSource.h"
#import "WDDateSelectorViewDataSource.h"
#import "WDDateSelectorViewDelegate.h"

@interface WDDashBoardViewController : UIViewController<WDSettingsScreenViewControllerDelegate,
                                                        WDDateSelectorViewDataSource,
                                                        WDDateSelectorViewDelegate>

@property(nonatomic, weak) id<WDDashBoardViewControllerDelegate>   delegate;
@property(nonatomic, weak) id<WDDashBoardViewControllerDataSource> dataSource;

@end
