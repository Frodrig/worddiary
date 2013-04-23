//
//  WDValueSetterModuleViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 22/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDValueSetterModuleViewControllerDataSource.h"
#import "WDValueSetterModuleViewControllerDelegate.h"

@interface WDValueSetterModuleViewController : UIViewController

@property(nonatomic, weak)id<WDValueSetterModuleViewControllerDataSource> dataSource;
@property(nonatomic, weak)id<WDValueSetterModuleViewControllerDelegate>   delegate;

@property(nonatomic)BOOL enabled;

- (void) refreshDataValue;

@end
