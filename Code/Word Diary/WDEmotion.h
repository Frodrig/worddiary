//
//  WDEmotion.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDPalette, WDWord;

@interface WDEmotion : NSManagedObject

@property (nonatomic, retain) NSString     *name;
@property (nonatomic, retain) NSSet        *palette;
@property (nonatomic, retain) NSSet        *word;
@property (nonatomic, readonly) NSUInteger priorityOrder;

- (WDPalette *)findPaletteOfIdName:(NSString *)idName;

- (NSComparisonResult)compare:(WDEmotion *)otherEmotion;

- (NSString *)description;

@end

@interface WDEmotion (CoreDataGeneratedAccessors)

- (void)addPaletteObject:(WDPalette *)value;
- (void)removePaletteObject:(WDPalette *)value;
- (void)addPalette:(NSSet *)values;
- (void)removePalette:(NSSet *)values;

- (void)addWordObject:(WDWord *)value;
- (void)removeWordObject:(WDWord *)value;
- (void)addWord:(NSSet *)values;
- (void)removeWord:(NSSet *)values;

@end
