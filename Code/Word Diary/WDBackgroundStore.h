//
//  WDBackgroundStore.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 06/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDBackgroundDefs.h"

@class WDBackground;

@interface WDBackgroundStore : NSObject

@property(nonatomic, readonly) BOOL swipeMode;

+ (WDBackgroundStore *) sharedStore;

- (NSNumber *)          createBackgroundOfCategory:(WDBackgroundCategory)category forView:(UIView *)view;
- (NSNumber *)          createBackgroundCopyOfBackgroundWithID:(NSNumber *)idBackground forView:(UIView *)view;

- (void)                changeBackground:(NSNumber *)idBackground toCategory:(WDBackgroundCategory)category withDuration:(CGFloat)time;

- (void)                enterSwipeMode:(NSNumber *)idBackground;
- (void)                exitSwipemode:(NSNumber *)idBackground;

- (void)                releaseBackgroundWithID:(NSNumber *)idBackground;

- (WDBackground *)      findBackgroundWithID:(NSNumber *)idBackground;

@end
