//
//  UILabel+TopAlign.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UILabel+TopAlign.h"

@implementation UILabel (TopAlign)

- (void)topAlign
{
    CGRect frameBeforeSizeToFit = self.frame;
    
    [self sizeToFit];
    
    CGRect frameAfterSizeToFit = self.frame;
    
    self.frame = CGRectMake(frameAfterSizeToFit.origin.x, frameAfterSizeToFit.origin.y, frameBeforeSizeToFit.size.width, frameAfterSizeToFit.size.height);
}


@end
