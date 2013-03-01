//
//  WDReturnToAllWordsScreenMenuViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 01/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDEditingWordMenuDelegate.h"

@interface WDReturnToAllWordsScreenMenuViewController : UIViewController

@property (nonatomic, weak) id<WDEditingWordMenuDelegate> delegate;

@end
