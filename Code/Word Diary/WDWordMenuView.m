//
//  WDTodayWordMenuView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordMenuView.h"
#import "WDTodayWordMenuViewPage1.h"
#import "WDPreviousDayWordMenuViewPage1.h"
#import "WDWordMenuAuxiliaryViewPage2.h"
#import "UIView+UIViewNibLoad.h"

@implementation WDWordMenuView

#pragma mark - Synthesize

@synthesize page1TodayWord           = page1TodayWord_;
@synthesize page1PreviousDayWord     = page1PreviousDayWord_;
@synthesize page2                    = page2_;
@synthesize scrollView               = scrollView_;
@synthesize pageView                 = pageView_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        page1TodayWord_ = (WDTodayWordMenuViewPage1 *)[WDTodayWordMenuViewPage1 createFromNib];
        page1PreviousDayWord_ = (WDPreviousDayWordMenuViewPage1 *)[WDPreviousDayWordMenuViewPage1 createFromNib];
        page2_ = (WDWordMenuAuxiliaryViewPage2 *)[WDWordMenuAuxiliaryViewPage2 createFromNib];
    }
    
    return self;
}

@end
