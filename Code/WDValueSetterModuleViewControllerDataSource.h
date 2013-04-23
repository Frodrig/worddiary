//
//  WDValueSetterModuleViewControllerDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 22/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDValueSetterModuleViewController;

@protocol WDValueSetterModuleViewControllerDataSource <NSObject>

- (NSString *)initialDataValueTextForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController;
- (NSString *)actualDataValueTextForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController;

- (NSString *)valueAfterPlusButtonPressedForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController;
- (NSString *)valueAfterMinusButtonPressedForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController;

@end
