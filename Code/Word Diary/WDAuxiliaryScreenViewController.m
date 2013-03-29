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
#import "WDAuxiliaryScreenHelpPanelView.h"
#import "UIView+UIViewNibLoad.h"
#import "UILabel+TopAlign.h"
#import <QuartzCore/QuartzCore.h>

@interface WDAuxiliaryScreenViewController ()

@property (weak, nonatomic) IBOutlet UIView                     *backgroundHeaderView;
@property (weak, nonatomic) IBOutlet UILabel                    *titleLabel;
@property (nonatomic, strong) WDAuxiliaryScreenAboutPanelView   *aboutPanel;
@property (nonatomic, strong) WDAuxiliaryScreenSupportPanelView *supportPanel;
@property (nonatomic, strong) WDAuxiliaryScreenHelpPanelView    *helpPanel;
@property (nonatomic) CGPoint                                   centerPositionForAuxiliaryPanels;
@property (nonatomic, strong) MFMailComposeViewController       *mailComposerViewController;

- (void)showScreenInView:(UIView *)view withDuration:(CGFloat)duration;

- (void)aboutPanelWordDiaryURLButtonPressed:(UIControl *)sender;
- (void)aboutPanelTwitterURLButton:(UIControl *)sender;

- (void)supportPanelEmailButtonPressed:(UIControl *)sender;

- (void)insertPanel:(UIView *)view;

@end

@implementation WDAuxiliaryScreenViewController

@synthesize backgroundHeaderView       = backgroundHeaderView_;
@synthesize delegate                   = delegate_;
@synthesize titleLabel                 = titleLabel_;
@synthesize aboutPanel                 = aboutPanel_;
@synthesize mailComposerViewController = mailComposerViewController_;
@synthesize helpPanel                  = helpPanel_;

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
    self.view.backgroundColor = [WDUtils schemeBackgroundColor:CS_LIGHT];
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

- (void)insertPanel:(UIView *)view
{
    [self.view addSubview:view];
    view.center = CGPointMake(self.view.bounds.size.width / 2, self.view.center.y);;
}


#pragma mark - Acciones

- (void)showSupportScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    self.titleLabel.text = NSLocalizedString(@"TAG_AUXILIARYSCREEN_SUPPORTTITLE", @"");
    
    self.supportPanel = (WDAuxiliaryScreenSupportPanelView *)[WDAuxiliaryScreenSupportPanelView createFromNib];
    
    self.supportPanel.descriptionSupportLabel.text = NSLocalizedString(@"TAG_AUXILIARYSUPPORTPANEL_DESCRIPTION", @"");
    [self.supportPanel.emailDescriptionSupportButton setTitle:NSLocalizedString(@"TAG_AUXILIARYSUPPORTPANEL_EMAILDESCRIPTION", @"") forState:UIControlStateNormal];
    [self.supportPanel.emailDescriptionSupportButton addTarget:self action:@selector(supportPanelEmailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self insertPanel:self.supportPanel];

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
    
    [self insertPanel:self.aboutPanel];
    
    [self showScreenInView:view withDuration:duration];
}

- (void)showHelpScreenInView:(UIView *)view withDuration:(CGFloat)duration
{
    self.titleLabel.text = NSLocalizedString(@"TAG_AUXILIARYSCREEN_TIPSTITLE", @"");
    
    self.helpPanel = (WDAuxiliaryScreenHelpPanelView *)[WDAuxiliaryScreenHelpPanelView createFromNib];
    
    NSArray *helpTips = [NSArray arrayWithObjects:NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_1", @""),
                                                  NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_2", @""),
                                                  NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_3", @""),
                                                  NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_4", @""),
                                                  NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_5", @""),
                                                  NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_6", @""),
                                                  NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_7", @""),
                                                  NSLocalizedString(@"TAG_AUXILIARYHELPPANEL_8", @""),
                                                  nil];
    
    self.helpPanel.helpContainerScrollView.contentSize = CGSizeMake(self.helpPanel.helpContainerScrollView.bounds.size.width * helpTips.count, self.helpPanel.helpContainerScrollView.bounds.size.height);
    for (NSUInteger tipIt = 0; tipIt < helpTips.count; tipIt++) {
        NSString *helpTipString = [helpTips objectAtIndex:tipIt];
        
        CGRect labelFrameIt = CGRectMake(self.helpPanel.helpContainerScrollView.frame.size.width * tipIt,
                                         0,
                                         self.helpPanel.helpContainerScrollView.frame.size.width,
                                         self.helpPanel.helpContainerScrollView.frame.size.height);
        NSLog(@"%@", NSStringFromCGRect(labelFrameIt));
        UILabel *labelIt = [[UILabel alloc] initWithFrame:labelFrameIt];
        labelIt.text = helpTipString;
        labelIt.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:33];
        labelIt.textColor = [UIColor blackColor];
        labelIt.textAlignment = NSTextAlignmentCenter;
        labelIt.numberOfLines = 0;
        labelIt.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.15];
        labelIt.shadowOffset = CGSizeMake(0.0, 1.0);
        labelIt.backgroundColor = [UIColor clearColor];
        
        [self.helpPanel.helpContainerScrollView addSubview:labelIt];
        
        [labelIt topAlign];
    }
    self.helpPanel.helpContainerScrollView.delegate = self;
    self.helpPanel.pageController.numberOfPages = helpTips.count;
    self.helpPanel.pageController.currentPage = 0;
    
    [self insertPanel:self.helpPanel];
    
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
        
        if (self.helpPanel) {
            [self.helpPanel removeFromSuperview];
            self.helpPanel = nil;
        }
    }];
    
    [self.delegate auxiliaryScreenViewWillHide:self];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.helpPanel.helpContainerScrollView) {
        self.helpPanel.pageController.currentPage = self.helpPanel.helpContainerScrollView.contentOffset.x / self.helpPanel.helpContainerScrollView.bounds.size.width;
    }
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
    self.mailComposerViewController = [[MFMailComposeViewController alloc] init];
    self.mailComposerViewController.mailComposeDelegate = self;
    [self.mailComposerViewController setSubject:NSLocalizedString(@"TAG_SUPPORTEMAIL_TEMPLATE_TITLE", @"")];
    [self.mailComposerViewController setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"TAG_SUPPORTEMAIL_TEMPLATE_RECIPENT", @"")]];
    [self presentViewController:self.mailComposerViewController animated:YES completion:nil];
    
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

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.mailComposerViewController dismissViewControllerAnimated:YES completion:nil];
    self.mailComposerViewController = nil;
    
    [self.delegate auxiliarySupportScreenViewEmailWasSend:self];
}


@end
