//
//  WDFont.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDWord;

@interface WDFont : NSManagedObject

@property (nonatomic, retain) NSString * family;
@property (nonatomic, retain) NSSet *word;
@end

@interface WDFont (CoreDataGeneratedAccessors)

- (NSComparisonResult)compare:(WDFont *)otherFont;

- (void)addWordObject:(WDWord *)value;
- (void)removeWordObject:(WDWord *)value;
- (void)addWord:(NSSet *)values;
- (void)removeWord:(NSSet *)values;

@end
