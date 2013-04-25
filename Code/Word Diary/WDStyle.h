//
//  WDFont.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDWord;

@interface WDStyle : NSManagedObject

@property (nonatomic, retain) NSString  *familyFont;
@property (nonatomic, retain) NSSet     *word;
@property (nonatomic, strong) NSNumber  *orderValue;

- (NSComparisonResult)compare:(WDStyle *)otherFont;

@end

@interface WDStyle (CoreDataGeneratedAccessors)

- (void)addWordObject:(WDWord *)value;
- (void)removeWordObject:(WDWord *)value;
- (void)addWord:(NSSet *)values;
- (void)removeWord:(NSSet *)values;

@end
