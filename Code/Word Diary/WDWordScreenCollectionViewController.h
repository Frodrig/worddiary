//
//  WDWordScreenCollectionViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDWordRepresentationViewDataSource.h"
#import "WDWordCharacterCounterViewDataSource.h"
#import "WDWordCharacterCounterViewDelegate.h"
#import "WDMainMenuViewControllerDelegate.h"
#import "WDMainMenuViewControllerDataSource.h"

@interface WDWordScreenCollectionViewController : UICollectionViewController<WDWordRepresentationViewDataSource,
                                                                             WDWordCharacterCounterViewDataSource,
                                                                             WDWordCharacterCounterViewDelegate,
                                                                             WDMainMenuViewControllerDelegate,
                                                                             WDMainMenuViewControllerDataSource,
                                                                             UIKeyInput>

@end
