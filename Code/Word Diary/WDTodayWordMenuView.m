//
//  WDTodayWordMenuView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDTodayWordMenuView.h"
#import "WDTodayWordMenuViewPage1.h"
#import "WDTodayWordMenuViewPage2.h"
#import "UIView+UIViewNibLoad.h"

@implementation WDTodayWordMenuView

#pragma mark - Synthesize

@synthesize page1                    = page1_;
@synthesize page2                    = page2_;
@synthesize scrollView               = scrollView_;
@synthesize pageView                 = pageView_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        page1_ = (WDTodayWordMenuViewPage1 *)[WDTodayWordMenuViewPage1 createFromNib];
        page2_ = (WDTodayWordMenuViewPage2 *)[WDTodayWordMenuViewPage2 createFromNib];
    }
    
    return self;
}

@end
