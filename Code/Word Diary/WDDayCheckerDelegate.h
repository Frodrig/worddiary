//
//  WDDayCheckerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 21/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDDayChecker;

@protocol WDDayCheckerDelegate <NSObject>

- (void)dayCheckerOnNewDay:(WDDayChecker *)dayChecker;

@end
