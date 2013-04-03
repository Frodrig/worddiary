//
//  WDWord.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDEmotion, WDStyle;

@interface WDWord : NSManagedObject

@property (nonatomic) double            timeInterval;
@property (nonatomic, retain) NSString  *word;
@property (nonatomic, retain) NSString  *paletteIdNameOfEmotion;
@property (nonatomic, retain) WDEmotion *emotion;
@property (nonatomic, retain) WDStyle   *style;

@property (nonatomic, strong, readonly) NSDateComponents *dateComponents;

- (BOOL)isEmpty;
- (BOOL)isTodayWord;

- (NSComparisonResult) compare:(WDWord *)otherWord;

@end
