//
//  WDWord.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDColor, WDFont;

@interface WDWord : NSManagedObject

@property (nonatomic) double timeInterval;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) WDFont *font;
@property (nonatomic, retain) WDColor *wordColor;
@property (nonatomic, retain) WDColor *backgroundColor;

@property (nonatomic, strong, readonly) NSDateComponents *dateComponents;

- (BOOL)               isEmpty;

- (NSComparisonResult) compare:(WDWord *)otherWord;


@end
