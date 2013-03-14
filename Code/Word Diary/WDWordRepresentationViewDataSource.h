//
//  WDWordRepresentationViewDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 14/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWordRepresentationView;

@protocol WDWordRepresentationViewDataSource <NSObject>

- (NSString *)actualTextValueForWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView;
- (NSString *)actualFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView;

@end
