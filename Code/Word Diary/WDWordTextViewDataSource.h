//
//  WDWordTextViewDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWordTextView;

@protocol WDWordTextViewDataSource <NSObject>

- (NSString *)actualTextValueForWordTextView:(WDWordTextView *)wordTextView;
- (NSString *)actualFamilyFontForWordTextView:(WDWordTextView *)wordTextView;
- (UIColor *)actualCursorColorForWordTextView:(WDWordTextView *)wordTextView;
- (CGPoint)actualStartPointDrawingForWordTextView:(WDWordTextView *)wordTextView;

- (BOOL)isInWritingModeForWordTextView:(WDWordTextView *)wordTextView;

@end
