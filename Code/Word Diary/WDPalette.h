//
//  WDPalette.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDWord;

@interface WDPalette : NSManagedObject

@property (nonatomic, retain) NSString      *lightBackground;
@property (nonatomic, retain) NSString      *idName;
@property (nonatomic, retain) NSString      *wordColor;
@property (nonatomic, retain) NSSet         *word;

- (UIColor *) makeLightBackgroundColorObject;
- (UIColor *) makeWordColorObject;

@end

@interface WDPalette (CoreDataGeneratedAccessors)

- (void)addWordObject:(WDWord *)value;
- (void)removeWordObject:(WDWord *)value;
- (void)addWord:(NSSet *)values;
- (void)removeWord:(NSSet *)values;

@end
