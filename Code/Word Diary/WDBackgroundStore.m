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
#import "WDUtils.h"

@interface WDBackgroundStore()

@property NSUInteger           idCounter;
@property NSMutableDictionary *backgrounds;

- (CAGradientLayer *)    createGradientLayerOfCategory:(WDBackgroundCategory)category forView:(UIView *)view;
- (UIImageView *)        createImageBackgroundOfCategory:(WDBackgroundCategory)category forView:(UIView *)view;

- (NSString *)           makeFilenameChecking568ScreenSizeUsingFilename:(NSString *)filename;

- (WDColorScheme)        colorSchemeForBackgroundCategory:(WDBackgroundCategory)category;

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
    
    gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    NSArray *pickerColorArray = [WDUtils pickerColorArray];
    UIColor *colorOne = [pickerColorArray objectAtIndex:[WDUtils convertGradientBackgroundCategoryToPickerColorIndex:category]];
    UIColor *colorTwo = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(1.0, 1.0);
    gradient.cornerRadius = 10.0;
    gradient.masksToBounds = YES;
    
    [view.layer insertSublayer:gradient atIndex:0];
    
    CABasicAnimation *gradientAnimationStartPoint = [CABasicAnimation animationWithKeyPath:@"colors"];
    gradientAnimationStartPoint.fromValue = gradient.colors;//[NSValue valueWithCGPoint:gradient.startPoint];
    gradientAnimationStartPoint.toValue = [NSArray arrayWithObjects:(id)colorTwo.CGColor, (id)colorOne.CGColor, nil];
    gradientAnimationStartPoint.duration = 4.0;
    gradientAnimationStartPoint.removedOnCompletion = NO;
    gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    gradientAnimationStartPoint.repeatCount = HUGE_VALF;
    gradientAnimationStartPoint.autoreverses = YES;
    [gradient addAnimation:gradientAnimationStartPoint forKey:@"animateGradientChangeColors"];
    
    /*
     CABasicAnimation *gradientAnimationStartPoint = [CABasicAnimation animationWithKeyPath:@"startPoint"];
     gradientAnimationStartPoint.fromValue = [NSValue valueWithCGPoint:gradient.startPoint];
     gradientAnimationStartPoint.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 0.2)];
     gradientAnimationStartPoint.duration = 4.0;
     gradientAnimationStartPoint.removedOnCompletion = NO;
     gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     gradientAnimationStartPoint.repeatCount = HUGE_VALF;
     gradientAnimationStartPoint.autoreverses = YES;
     [gradient addAnimation:gradientAnimationStartPoint forKey:@"animateGradientStartPoint"];
     
     CABasicAnimation *gradientAnimationEndPoint = [CABasicAnimation animationWithKeyPath:@"endPoint"];
     gradientAnimationEndPoint.fromValue = [NSValue valueWithCGPoint:gradient.endPoint];
     gradientAnimationEndPoint.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.8)];
     gradientAnimationEndPoint.duration = 4.0;
     gradientAnimationEndPoint.removedOnCompletion = NO;
     gradientAnimationEndPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     gradientAnimationEndPoint.repeatCount = HUGE_VALF;
     gradientAnimationEndPoint.autoreverses = YES;
     [gradient addAnimation:gradientAnimationEndPoint forKey:@"animateGradientEndPoint"];
     */

    
    return gradient;
}

- (UIImageView *)createImageBackgroundOfCategory:(WDBackgroundCategory)category forView:(UIView *)view
{
    UIImageView *imageView = nil;
    
    switch (category) {
        case BC_BACKGROUNDIMAGE_TESTCELL: {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self makeFilenameChecking568ScreenSizeUsingFilename:@"testcell"]]];
        } break;
            
        case BC_BACKGROUNDIMAGE_TESTCREEN: {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self makeFilenameChecking568ScreenSizeUsingFilename:@"testscreen"]]];
        } break;
            
        default:
            break;
    };
    
    [view addSubview:imageView];
    
    return imageView;
}

- (NSString *)makeFilenameChecking568ScreenSizeUsingFilename:(NSString *)filename
{
    NSString *retFilename = nil;
    if ([WDUtils is568Screen]) {
        retFilename = [filename stringByAppendingString:@"-568h@2x"];
    } else {
        retFilename = [NSString stringWithString:filename];
    }
    
    return retFilename;
}


- (WDColorScheme)colorSchemeForBackgroundCategory:(WDBackgroundCategory)category
{
    WDColorScheme scheme = CS_LIGHT;
    if (category < BC_GRADIENT_4 || category > BC_GRADIENT_8) {
        scheme = CS_DARK;
    }
    return scheme;
}

#pragma mark - Creation & Destruction

- (NSNumber *)createBackgroundOfCategory:(WDBackgroundCategory)category forView:(UIView *)view
{
    WDBackground *background = [[WDBackground alloc] init];
    background.idBackground = [NSNumber numberWithUnsignedInteger:self.idCounter++];
    background.category = category;
    background.view = view;
    
    switch (category) {
        case BC_GRADIENT_0:
        case BC_GRADIENT_1:
        case BC_GRADIENT_2:
        case BC_GRADIENT_3:
        case BC_GRADIENT_4:
        case BC_GRADIENT_5:
        case BC_GRADIENT_6:
        case BC_GRADIENT_7:
        case BC_GRADIENT_8:
        case BC_GRADIENT_9:
        case BC_GRADIENT_10:
        case BC_GRADIENT_11:
            background.gradientLayer = [self createGradientLayerOfCategory:category forView:view];
            background.uiOverlayColorScheme = [self colorSchemeForBackgroundCategory:category];
            break;
            
        case BC_BACKGROUNDIMAGE_TESTCELL:
        case BC_BACKGROUNDIMAGE_TESTCREEN:
            background.imageView = [self createImageBackgroundOfCategory:category forView:view];
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
            case BC_GRADIENT_0:
            case BC_GRADIENT_1:
            case BC_GRADIENT_2:
            case BC_GRADIENT_3:
            case BC_GRADIENT_4:
            case BC_GRADIENT_5:
            case BC_GRADIENT_6:
            case BC_GRADIENT_7:
            case BC_GRADIENT_8:
            case BC_GRADIENT_9:
            case BC_GRADIENT_10:
            case BC_GRADIENT_11:
                [background.gradientLayer removeFromSuperlayer];
                break;
                
            case BC_BACKGROUNDIMAGE_TESTCELL:
            case BC_BACKGROUNDIMAGE_TESTCREEN: {
                [background.imageView removeFromSuperview];
            } break;
                
            default:
                break;
        };
        
        [self.backgrounds removeObjectForKey:idBackground];
    }
}

#pragma mark - Obtencion

- (WDBackground *)findBackgroundWithID:(NSNumber *)idBackground
{
    return [self.backgrounds objectForKey:idBackground];
}





@end
