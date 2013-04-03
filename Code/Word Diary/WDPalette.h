//
//  WDPalette.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WDEmotion;

@interface WDPalette : NSManagedObject

@property (nonatomic, retain) NSString  *idName;
@property (nonatomic, retain) NSString  *backgroundColor;
@property (nonatomic, retain) NSString  *wordColor;
@property (nonatomic, retain) NSString  *accessoriesColor;
@property (nonatomic, retain) NSString  *reservedColor;
@property (nonatomic, retain) WDEmotion *emotion;

@end
