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

@property (nonatomic) NSUInteger           idCounter;
@property (nonatomic, strong) NSMutableDictionary  *backgrounds;
@property (nonatomic, weak)   WDBackground         *animateBackground;
@property (nonatomic, strong) WDBackground         *backgroundChangingCategoryWithAnimation;
@property (nonatomic, strong) NSMutableArray       *gradientLayersWithAnimationPendingToAdd;

- (void)addAnimationsOfCategory:(WDBackgroundCategory)category toGradientLayer:(CAGradientLayer *)gradientLayer;

- (CAGradientLayer *)createGradientLayerOfCategory:(WDBackgroundCategory)category forView:(UIView *)view;
- (UIImageView *)createImageBackgroundOfCategory:(WDBackgroundCategory)category forView:(UIView *)view;

- (NSString *)makeFilenameChecking568ScreenSizeUsingFilename:(NSString *)filename;

- (WDColorScheme)colorSchemeForBackgroundCategory:(WDBackgroundCategory)category;

@end

@implementation WDBackgroundStore

#pragma mark - Synthesize

@synthesize backgrounds                                 = backgrounds_;
@synthesize idCounter                                   = idCounter_;
@synthesize backgroundChangingCategoryWithAnimation     = backgroundChangingCategoryWithAnimation;
@synthesize gradientLayersWithAnimationPendingToAdd     = gradientLayersWithAnimationPendingToAdd_;
@synthesize animateBackground                           = animateBackground_;
@synthesize swipeMode                                   = swipeMode_;

#pragma mark - Properties

- (NSMutableArray *)gradientLayersWithAnimationPendingToAdd
{
    if (nil == gradientLayersWithAnimationPendingToAdd_) {
        gradientLayersWithAnimationPendingToAdd_ = [NSMutableArray arrayWithCapacity:1];
    }
    
    return gradientLayersWithAnimationPendingToAdd_;
}

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

#pragma mark - Swipe Mode

- (void)enterSwipeMode:(NSNumber *)idBackground
{
    if (!self.swipeMode) {
        swipeMode_ = YES;
    }
}

- (void)exitSwipemode:(NSNumber *)idBackground
{
    if (self.swipeMode) {
        swipeMode_ = NO;
    }
}

#pragma mark - Auxiliary Methods

- (void)addAnimationsOfCategory:(WDBackgroundCategory)category toGradientLayer:(CAGradientLayer *)gradientLayer
{
    NSAssert(gradientLayer.animationKeys.count == 0, @"NO debería de haber ninguna animacion vinculada");
    
    UIColor *colorOne = (UIColor *)[gradientLayer.colors objectAtIndex:0];
    UIColor *colorTwo = (UIColor *)[gradientLayer.colors objectAtIndex:1];
    
    CABasicAnimation *gradientAnimationColors = [CABasicAnimation animationWithKeyPath:@"colors"];
    gradientAnimationColors.fromValue = gradientLayer.colors;
    gradientAnimationColors.toValue = [NSArray arrayWithObjects:(id)colorTwo, (id)colorOne, nil];
    gradientAnimationColors.duration = 5;
    gradientAnimationColors.removedOnCompletion = NO;
    gradientAnimationColors.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    gradientAnimationColors.repeatCount = HUGE_VALF;
    gradientAnimationColors.autoreverses = YES;
    [gradientLayer addAnimation:gradientAnimationColors forKey:@"animateGradientChangeColors"];
    
    CAKeyframeAnimation *gradientAnimationStartPoint = [CAKeyframeAnimation animationWithKeyPath:@"startPoint"];
    [gradientAnimationStartPoint setValues:[NSArray arrayWithObjects:
                                            [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)],
                                            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                            nil]];
    gradientAnimationStartPoint.duration = 5;
    gradientAnimationStartPoint.removedOnCompletion = NO;
    gradientAnimationStartPoint.calculationMode = kCAAnimationPaced;
    gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    gradientAnimationStartPoint.repeatCount = HUGE_VALF;
    gradientAnimationStartPoint.autoreverses = YES;
    [gradientLayer addAnimation:gradientAnimationStartPoint forKey:@"animateGradientChangeStartPoints"];
    
    CAKeyframeAnimation *gradientAnimationEndPoint = [CAKeyframeAnimation animationWithKeyPath:@"endPoint"];
    [gradientAnimationEndPoint setValues:[NSArray arrayWithObjects:
                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
                                          [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                          nil]];
    gradientAnimationEndPoint.duration = 5;
    gradientAnimationEndPoint.removedOnCompletion = NO;
    gradientAnimationEndPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    gradientAnimationEndPoint.calculationMode = kCAAnimationPaced;
    gradientAnimationEndPoint.repeatCount = HUGE_VALF;
    gradientAnimationEndPoint.autoreverses = YES;
    [gradientLayer addAnimation:gradientAnimationEndPoint forKey:@"animateGradientChangeEndPoints"];
}

- (CAGradientLayer *)createGradientLayerOfCategory:(WDBackgroundCategory)category forView:(UIView *)view
{
    CAGradientLayer* gradient = nil;
    gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    
    NSArray *pickerColorArray = [WDUtils pickerColorArray];
    UIColor *colorOne = [pickerColorArray objectAtIndex:[WDUtils convertGradientBackgroundCategoryToPickerColorIndex:category]];
    UIColor *colorTwo = [UIColor colorWithWhite:0.9 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(1.0, 1.0);
    gradient.cornerRadius = 10.0;
    gradient.masksToBounds = YES;
    [view.layer insertSublayer:gradient atIndex:0];

    [self addAnimationsOfCategory:category toGradientLayer:gradient];
        
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

#pragma mark - CABasicAnimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // Con este codigo ES FUNDAMENTAL que SIEMPRE llegue antes la animacion release que la add
    if (flag) {
        CAGradientLayer *layer = nil;
        
        BOOL isTheAddAnimation = self.gradientLayersWithAnimationPendingToAdd.count > 0;
        if (isTheAddAnimation) {
            layer = [self.gradientLayersWithAnimationPendingToAdd objectAtIndex:0];
            CAAnimation *addAnimation = [layer animationForKey:@"add"];
            isTheAddAnimation = addAnimation == anim;
            if (isTheAddAnimation) {
                [layer removeAnimationForKey:@"add"];
                [self.gradientLayersWithAnimationPendingToAdd removeObject:layer];
                self.animateBackground.gradientLayer = layer;
            }
        }
        
        if (!isTheAddAnimation) {
            layer = backgroundChangingCategoryWithAnimation.gradientLayer;
            CAAnimation *releaseAnimation = [layer animationForKey:@"release"];
            NSAssert(releaseAnimation == anim, @"Problema con la coherencia de animaciones y layers");
            [layer removeAnimationForKey:@"release"];
            [layer removeFromSuperlayer];
            self.backgroundChangingCategoryWithAnimation = nil;
        }
    }
}

#pragma mark - Creation & Destruction

- (void)changeBackground:(NSNumber *)idBackground toCategory:(WDBackgroundCategory)category withDuration:(CGFloat)time
{
    if (self.backgroundChangingCategoryWithAnimation == nil && self.gradientLayersWithAnimationPendingToAdd.count == 0) {
        WDBackground *backgroundToChange = [self findBackgroundWithID:idBackground];
        if (backgroundToChange) {
            self.animateBackground = backgroundToChange;
            backgroundToChange.gradientLayer.opacity = 0;
            
            CABasicAnimation *animationFadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animationFadeOut.fromValue = [NSNumber numberWithInt:1.0];
            animationFadeOut.toValue = [NSNumber numberWithInt:0.0];
            animationFadeOut.removedOnCompletion = NO;
            animationFadeOut.duration = time;
            animationFadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animationFadeOut.delegate = self;
            [backgroundToChange.gradientLayer addAnimation:animationFadeOut forKey:@"release"];
            self.backgroundChangingCategoryWithAnimation = backgroundToChange;
            
            CAGradientLayer *newLayer = [self createGradientLayerOfCategory:category forView:backgroundToChange.view];
            newLayer.opacity = 1;
            
            CABasicAnimation *animationFadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animationFadeIn.fromValue = [NSNumber numberWithInt:0.0];
            animationFadeIn.toValue = [NSNumber numberWithInt:1.0];
            animationFadeIn.removedOnCompletion = NO;
            animationFadeIn.duration = time;
            animationFadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animationFadeIn.delegate = self;
            [newLayer addAnimation:animationFadeIn forKey:@"add"];
            [self.gradientLayersWithAnimationPendingToAdd addObject:newLayer];
        }
    }
}

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
        case BC_SWIPE_GRADIENT:
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
            case BC_SWIPE_GRADIENT:
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
