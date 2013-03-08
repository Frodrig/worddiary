//
//  WDSelectedWordScreenDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDSelectedWordScreenDelegate <NSObject>

- (void) selectedWordChanged;
- (void) selectedWordWillBeRemoved;

@end
