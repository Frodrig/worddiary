//
//  WDMainMenuViewControllerDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 21/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDMainMenuViewController;

@protocol WDMainMenuViewControllerDataSource <NSObject>

- (BOOL)removeOptionAvailableForMainMenuViewController:(WDMainMenuViewController *)mainMenuViewController;

@end
