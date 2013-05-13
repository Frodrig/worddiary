//
//  WDWordRepresentationViewDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 13/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWordRepresentationView;

@protocol WDWordRepresentationViewDelegate <NSObject>

- (void)       wordContentUpdatedFlagCheckedByWordRepresentationView:(WDWordRepresentationView *)wordRepresentation;

@end
