//
//  WDEditingActualWordMenuViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDEditingWordMenuDelegate.h"

@class WDWord;

@interface WDEditingActualWordMenuViewController : UIViewController

@property (nonatomic, weak) WDWord                        *selectedWord;
@property (nonatomic, weak) id<WDEditingWordMenuDelegate> delegate;

@end
