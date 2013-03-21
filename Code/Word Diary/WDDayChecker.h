//
//  WDMinuteChecker.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 21/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDDayCheckerDelegate.h"

@interface WDDayChecker : NSObject

@property(nonatomic, weak) id<WDDayCheckerDelegate> delegate;

- (id)init;

- (void)pause;
- (void)resume;

@end
