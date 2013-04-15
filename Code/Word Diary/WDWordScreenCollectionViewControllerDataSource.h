//
//  WDWordScreenCollectionViewControllerDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWordScreenCollectionViewController;

@protocol WDWordScreenCollectionViewControllerDataSource <NSObject>

- (NSUInteger)selectedWordIndexForWordScreenCollectionViewController:(WDWordScreenCollectionViewController *)controller;

@end
