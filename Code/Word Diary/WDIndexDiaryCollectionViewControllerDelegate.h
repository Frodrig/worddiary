//
//  WDIndexDiaryScreenViewControllerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 11/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDIndexDiaryCollectionViewController;

@protocol WDIndexDiaryCollectionViewControllerDelegate <NSObject>

- (void)indexDiaryScreenViewController:(WDIndexDiaryCollectionViewController *)controller wordSelectedAtIndex:(NSUInteger)index;

@end
