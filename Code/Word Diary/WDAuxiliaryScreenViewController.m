//
//  WDAuxiliaryScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDAuxiliaryScreenViewController.h"
#import "WDUtils.h"
#import "WDBackgroundDefs.h"
#import <QuartzCore/QuartzCore.h>

@interface WDAuxiliaryScreenViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)showScreenInView:(UIView *)view withDuration:(CGFloat)duration;

@end

@implementation WDAuxiliaryScreenViewController

@synthesize delegate   = delegate_;
@synthesize titleLabel = titleLabel_;

#pragma mark - Properties

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.view.layer.cornerRadius = [WDUtils viewsCornerRadius];
    self.view.backgroundColor = [WDUtils schemeBackgroundColor:CS_DARK];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliares

- (void)showScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    CGPoint originalAuxiliaryScreenCenter = self.view.center;
    self.view.center = CGPointMake(self.view.center.x, (view.frame.origin.y + view.frame.size.height) * 1.5);
    [view addSubview:self.view];
    self.view.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        self.view.center = originalAuxiliaryScreenCenter;
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        // ...
    }];
}


#pragma mark - Acciones

- (void)showSupportScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    self.titleLabel.text = NSLocalizedString(@"TAG_AUXILIARYSCREEN_SUPPORTTITLE", @"");
    [self showScreenInView:view withDuration:duration];
}

- (void)showAboutScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    self.titleLabel.text = NSLocalizedString(@"TAG_AUXILIARYSCREEN_ABOUTTITLE", @"");
    [self showScreenInView:view withDuration:duration];
}

- (void)showSettingsScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    self.titleLabel.text = NSLocalizedString(@"TAG_AUXILIARYSCREEN_SETTINGSTITLE", @"");
    [self showScreenInView:view withDuration:duration];
}

- (void)showTipsScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    self.titleLabel.text = NSLocalizedString(@"TAG_AUXILIARYSCREEN_TIPSTITLE", @"");
    [self showScreenInView:view withDuration:duration];
}

- (void)hideWithDuration:(CGFloat)duration
{
    CGPoint originalAuxiliaryScreenCenter = self.view.center;
    [UIView animateWithDuration:duration animations:^{
        self.view.alpha = 0.0;
        self.view.center = CGPointMake(self.view.center.x, (self.view.superview.frame.origin.y + self.view.superview.frame.size.height) * 1.5);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        self.view.alpha = 1.0;
        self.view.center = originalAuxiliaryScreenCenter;
    }];
    
    [self.delegate auxiliaryScreenViewWillHide:self];
}

#pragma mark - Controls

- (IBAction)backButtonPressed:(id)sender
{
    [self.delegate auxiliaryScreenViewBackButtonPressed:self];
}

#pragma mark - Preguntas

- (BOOL)isShowed
{
    return self.view.superview != nil;
}


@end
