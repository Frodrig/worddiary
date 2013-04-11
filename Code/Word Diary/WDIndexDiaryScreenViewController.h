;//
//  WDIndexDiaryScreenViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 10/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDIndexDiaryCollectionViewControllerDelegate.h"
#import "WDIndexDiaryCollectionViewControllerDataSource.h"
#import "WDIndexDiaryScreenViewControllerDelegate.h"
#import "WDIndexDiaryScreenViewControllerDataSource.h"

@interface WDIndexDiaryScreenViewController : UIViewController<WDIndexDiaryCollectionViewControllerDelegate,
                                                            WDIndexDiaryCollectionViewControllerDataSource>

@property(nonatomic, weak)id<WDIndexDiaryScreenViewControllerDelegate>   delegate;
@property(nonatomic, weak)id<WDIndexDiaryScreenViewControllerDataSource> dataSource;

@end
