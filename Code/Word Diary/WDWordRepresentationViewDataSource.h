//
//  WDWordRepresentationViewDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWordRepresentationView;

@protocol WDWordRepresentationViewDataSource <NSObject>

- (NSString *) selectedWordTextForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation;
- (NSString *) selectedWordTextFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation;
- (UIColor *)  selectedWordColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation;

- (UIColor *)  selectedWordCursorColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation;

- (BOOL)       isKeyboardActiveForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation;

@end
