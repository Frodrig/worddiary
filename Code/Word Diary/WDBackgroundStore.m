//
//  WDBackgroundStore.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 06/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDBackgroundStore.h"
#import <QuartzCore/QuartzCore.h>
#import "WDBackground.h"

@interface WDBackgroundStore()

@property NSUInteger           idCounter;
@property NSMutableDictionary *backgrounds;

- (CAGradientLayer *) createGradientLayerOfCategory:(WDBackgroundCategory)category forView:(UIView *)view;

@end

@implementation WDBackgroundStore

#pragma mark - Synthesize

@synthesize backgrounds = backgrounds_;
@synthesize idCounter   = idCounter_;

#pragma mark - Singleton

+ (WDBackgroundStore *)sharedStore
{
    static WDBackgroundStore *backgroundStore = nil;
    if (nil == backgroundStore) {
        backgroundStore = [[super allocWithZone:nil] init];
    }
    
    return backgroundStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        idCounter_ = 0;
        backgrounds_ = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

#pragma mark - Auxiliary Methods

- (CAGradientLayer *)createGradientLayerOfCategory:(WDBackgroundCategory)category forView:(UIView *)view
{
    CAGradientLayer* gradient = nil;
    
    switch (category) {
        case BC_GRADIENT: {
            // Gradiente
            gradient = [CAGradientLayer layer];
            gradient.frame = view.bounds;
            UIColor *colorOne = [UIColor colorWithRed:0.9 green:0.9 blue:0.05 alpha:1.0];
            UIColor *colorTwo = [UIColor colorWithRed:0.0 green:102.0/255.0 blue:1.0 alpha:1.0];
            gradient.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
            gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
            gradient.startPoint = CGPointMake(0.5, 0.1);
            gradient.endPoint = CGPointMake(0.0, 1.0);
            gradient.cornerRadius = 10.0;
            gradient.masksToBounds = YES;
            [view.layer insertSublayer:gradient atIndex:0];
            
            CABasicAnimation *gradientAnimationStartPoint = [CABasicAnimation animationWithKeyPath:@"endPoint"];
            gradientAnimationStartPoint.fromValue = [NSValue valueWithCGPoint:gradient.endPoint];
            gradientAnimationStartPoint.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
            gradientAnimationStartPoint.duration = 8.0;
            gradientAnimationStartPoint.removedOnCompletion = NO;
            gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            gradientAnimationStartPoint.repeatCount = HUGE_VALF;
            gradientAnimationStartPoint.autoreverses = YES;
            [gradient addAnimation:gradientAnimationStartPoint forKey:@"animateGradientEndPoint"];
             
        } break;
            
        default:
            break;
    };
    
    return gradient;
}


#pragma mark - Creation & Destruction

- (NSNumber *)createBackgroundOfCategory:(WDBackgroundCategory)category forView:(UIView *)view
{
    WDBackground *background = [[WDBackground alloc] init];
    background.idBackground = [NSNumber numberWithUnsignedInteger:self.idCounter++];
    background.category = category;
    background.view = view;
    
    switch (category) {
        case BC_GRADIENT:
            background.gradientLayer = [self createGradientLayerOfCategory:category forView:view];
            break;
            
        default:
            NSAssert(0, @"Categoria de background no contemplada");
            break;
    };
    
    [self.backgrounds setObject:background forKey:background.idBackground];
    
    return background.idBackground;
}

- (NSNumber *)createBackgroundCopyOfBackgroundWithID:(NSNumber *)idBackground forView:(UIView *)view
{
    NSNumber *newIDBackground = nil;
    
    WDBackground *referenceBackground = [self.backgrounds objectForKey:idBackground];
    if (referenceBackground) {
        newIDBackground = [self createBackgroundOfCategory:referenceBackground.category forView:view];
    }
    
    return newIDBackground;
}

- (void)releaseBackgroundWithID:(NSNumber *)idBackground
{
    WDBackground *background = [self.backgrounds objectForKey:idBackground];
    if (background) {
        switch (background.category) {
            case BC_GRADIENT:
                [background.gradientLayer removeFromSuperlayer];
                break;
                
            default:
                break;
        };
        
        [self.backgrounds removeObjectForKey:idBackground];
    }
}



@end
