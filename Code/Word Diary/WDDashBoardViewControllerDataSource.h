//
//  WDDashBoardViewControllerDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 29/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDDashBoardViewController;

@protocol WDDashBoardViewControllerDataSource <NSObject>

- (NSDateComponents *)dateComponentsFromWordDaySelectedForDashBoardViewController:(WDDashBoardViewController *)dashBoardViewController;

@end
