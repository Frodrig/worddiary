//
//  WDBackgroundStore.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 06/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDBackgroundDefs.h"

@interface WDBackgroundStore : NSObject

+ (WDBackgroundStore *) sharedStore;

- (NSNumber *)          createBackgroundOfCategory:(WDBackgroundCategory)category forView:(UIView *)view;
- (NSNumber *)          createBackgroundCopyOfBackgroundWithID:(NSNumber *)idBackground forView:(UIView *)view;
- (void)                releaseBackgroundWithID:(NSNumber *)idBackground;

@end
