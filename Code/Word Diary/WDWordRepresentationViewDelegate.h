//
//  WDWordRepresentationViewDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 14/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWordRepresentationView;

@protocol WDWordRepresentationViewDelegate <NSObject>

- (void)deleteBackwardsOnWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView;
- (void)wordRepresentationView:(WDWordRepresentationView *)wordRepresentationView insertText:(NSString *)text;
- (void)keyboardDoneOnWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView;

- (void)shakeOnWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView;

@end
