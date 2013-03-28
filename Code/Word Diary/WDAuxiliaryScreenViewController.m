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
#import "WDAuxiliaryScreenAboutPanelView.h"
#import "WDAuxiliaryScreenSupportPanelView.h"
#import "UIView+UIViewNibLoad.h"
#import <QuartzCore/QuartzCore.h>

@interface WDAuxiliaryScreenViewController ()

@property (weak, nonatomic) IBOutlet UIView                     *backgroundHeaderView;
@property (weak, nonatomic) IBOutlet UILabel                    *titleLabel;
@property (nonatomic, strong) WDAuxiliaryScreenAboutPanelView   *aboutPanel;
@property (nonatomic, strong) WDAuxiliaryScreenSupportPanelView *supportPanel;
@property (nonatomic) CGPoint                                   centerPositionForAuxiliaryPanels;

- (void)showScreenInView:(UIView *)view withDuration:(CGFloat)duration;

- (void)aboutPanelWordDiaryURLButtonPressed:(UIControl *)sender;
- (void)aboutPanelTwitterURLButton:(UIControl *)sender;

- (void)supportPanelEmailButtonPressed:(UIControl *)sender;

@end

@implementation WDAuxiliaryScreenViewController

@synthesize backgroundHeaderView = backgroundHeaderView_;
@synthesize delegate             = delegate_;
@synthesize titleLabel           = titleLabel_;
@synthesize aboutPanel           = aboutPanel_;

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
    self.view.clipsToBounds = YES;
    self.backgroundHeaderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
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
    
    self.supportPanel = (WDAuxiliaryScreenSupportPanelView *)[WDAuxiliaryScreenSupportPanelView createFromNib];
    
    self.supportPanel.descriptionSupportLabel.text = NSLocalizedString(@"TAG_AUXILIARYSUPPORTPANEL_DESCRIPTION", @"");
    [self.supportPanel.emailDescriptionSupportButton setTitle:NSLocalizedString(@"TAG_AUXILIARYSUPPORTPANEL_EMAILDESCRIPTION", @"") forState:UIControlStateNormal];
    [self.supportPanel.emailDescriptionSupportButton addTarget:self action:@selector(supportPanelEmailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.supportPanel];
    self.supportPanel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.center.y);;
    
    [self showScreenInView:view withDuration:duration];
}

- (void)showAboutScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    self.titleLabel.text = NSLocalizedString(@"TAG_AUXILIARYSCREEN_ABOUTTITLE", @"");
    
    self.aboutPanel = (WDAuxiliaryScreenAboutPanelView *)[WDAuxiliaryScreenAboutPanelView createFromNib];
    
    self.aboutPanel.wordDiaryTitleLabel.text = NSLocalizedString(@"TAG_AUXILIARYABOUTPANEL_WORDDIARYTITLE", @"");
    self.aboutPanel.designedAndDevelopedByLabel.text = NSLocalizedString(@"TAG_AUXILIARYABOUTPANEL_DESIGNEDDEVELOPEDTITLE", @"");
    self.aboutPanel.developerNameLabel.text = NSLocalizedString(@"TAG_AUXILIARYABOUTPANEL_DEVELOPERNAME", @"");
    self.aboutPanel.allRightReservedLabel.text = NSLocalizedString(@"TAG_AUXILIARYABOUTPANEL_ALLRIGHTRESERVED_TITLE", @"");
    [self.aboutPanel.wordDiaryURLButton setTitle:NSLocalizedString(@"TAG_AUXILIARYABOUTPANEL_WORDDIARYURL", @"") forState:UIControlStateNormal];
    [self.aboutPanel.twitterURLButton setTitle:NSLocalizedString(@"TAG_AUXILIARYABOUTPANEL_DEVELOPERTWITTER", @"") forState:UIControlStateNormal];
    [self.aboutPanel.wordDiaryURLButton addTarget:self action:@selector(aboutPanelWordDiaryURLButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.aboutPanel.twitterURLButton addTarget:self action:@selector(aboutPanelTwitterURLButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.aboutPanel];
    self.aboutPanel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.center.y);;
    
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
        self.view.alpha = 1.0;
        self.view.center = originalAuxiliaryScreenCenter;
        [self.view removeFromSuperview];
        
        if (self.aboutPanel) {
            [self.aboutPanel removeFromSuperview];
            self.aboutPanel = nil;
        }
        
        if (self.supportPanel) {
            [self.supportPanel removeFromSuperview];
            self.supportPanel = nil;
        }
    }];
    
    [self.delegate auxiliaryScreenViewWillHide:self];
}

#pragma mark - Controles About Panel

- (void)aboutPanelWordDiaryURLButtonPressed:(UIControl *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"TAG_WORDDIARY_URL", @"")]];
    
    [self.delegate auxiliaryAboutScreenViewWordDiaryURLPressedAndOpen:self];
}

- (void)aboutPanelTwitterURLButton:(UIControl *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"TAG_FRODRIGTWITTER_URL", @"")]];
    
    [self.delegate auxiliaryAboutScreenViewDeveloperTwitterURLPressedAndOpen:self];
}

#pragma mark - Controles Support Panel

- (void)supportPanelEmailButtonPressed:(UIControl *)sender
{
    // ToDo envío del email
    
    [self.delegate auxiliarySupportScreenViewEmailPressedAndOpen:self];
}


#pragma mark - Controles generales

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
