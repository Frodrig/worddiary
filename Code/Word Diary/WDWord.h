//
//  WDWord.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 06/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDFont;

@interface WDWord : NSManagedObject

@property (nonatomic) double             timeInterval;
@property (nonatomic, retain) NSString   *word;
@property (nonatomic) int16_t            backgroundCategory;
@property (nonatomic, retain) WDFont     *font;

@property (nonatomic, strong, readonly) NSDateComponents *dateComponents;

- (BOOL)               isEmpty;
- (BOOL)               isTodayWord;

- (NSComparisonResult) compare:(WDWord *)otherWord;

@end
