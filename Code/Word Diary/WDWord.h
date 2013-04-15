//
//  WDWord.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDPalette, WDStyle;

@interface WDWord : NSManagedObject

// CoreData
@property (nonatomic) double                timeInterval;
@property (nonatomic, retain) NSString      *word;
@property (nonatomic, retain) WDStyle       *style;
@property (nonatomic, retain) WDPalette     *palette;

// Other
@property (nonatomic, strong, readonly) NSDateComponents *dateComponents;

- (BOOL)               isEmpty;
- (BOOL)               isTodayWord;
- (NSUInteger)         daysSinceTodayDate;

- (NSString *)         yearAsString;
- (NSString *)         dayAndMonthAsString;
- (NSString *)         dayAndMonthAbreviateAsString;

- (NSComparisonResult) compare:(WDWord *)otherWord;

@end
