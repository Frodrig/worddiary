//
//  WDIndexDiaryCollectionViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 10/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDIndexDiaryCollectionViewControllerDelegate.h"
#import "WDIndexDiaryCollectionViewControllerDataSource.h"

@interface WDIndexDiaryCollectionViewController : UICollectionViewController

@property(nonatomic, weak)id<WDIndexDiaryCollectionViewControllerDelegate>   delegate;
@property(nonatomic, weak)id<WDIndexDiaryCollectionViewControllerDataSource> dataSource;

- (id)init;

@end
