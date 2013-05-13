//
//  WDWordRepresentationView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDWordRepresentationViewDataSource.h"
#import "WDWordRepresentationViewDelegate.h"

@interface WDWordRepresentationView : UIView

@property(nonatomic) BOOL                                        keyboardMode;
@property(nonatomic) BOOL                                        forceCursorHide;
@property(nonatomic, readonly) BOOL                              isGosthView;
@property(nonatomic, weak)id<WDWordRepresentationViewDataSource> dataSource;
@property(nonatomic, weak)id<WDWordRepresentationViewDelegate>   delegate;

- (void) generateGosthWordRepresentation;

@end
