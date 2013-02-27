//
//  WDColor.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDWord;

@interface WDColor : NSManagedObject

@property (nonatomic) float red;
@property (nonatomic) float green;
@property (nonatomic) float blue;
@property (nonatomic) float alpha;
@property (nonatomic, retain) NSSet *wordColor;
@property (nonatomic, retain) NSSet *backgroundColor;

@property (nonatomic, strong) UIColor *colorObject;
@end

@interface WDColor (CoreDataGeneratedAccessors)

- (void)addWordColorObject:(WDWord *)value;
- (void)removeWordColorObject:(WDWord *)value;
- (void)addWordColor:(NSSet *)values;
- (void)removeWordColor:(NSSet *)values;

- (void)addBackgroundColorObject:(WDWord *)value;
- (void)removeBackgroundColorObject:(WDWord *)value;
- (void)addBackgroundColor:(NSSet *)values;
- (void)removeBackgroundColor:(NSSet *)values;

@end
