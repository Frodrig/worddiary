//
//  WDInfoScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 24/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDInfoScreenViewController.h"

@interface WDInfoScreenViewController ()

@property (weak, nonatomic) IBOutlet UILabel                    *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *feedbackInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton                   *feedbackEmailButton;
@property (weak, nonatomic) IBOutlet UILabel                    *developedByLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *versionLabel;
@property (nonatomic, strong) MFMailComposeViewController       *mailComposerViewController;

@end

@implementation WDInfoScreenViewController

#pragma mark - Synthesize

@synthesize titleLabel                 = titleLabel_;
@synthesize subTitleLabel              = subTitleLabel_;
@synthesize feedbackInfoLabel          = feedbackInfoLabel_;
@synthesize feedbackEmailButton        = feedbackEmailButton_;
@synthesize developedByLabel           = developedByLabel_;
@synthesize versionLabel               = versionLabel_;
@synthesize mailComposerViewController = mailComposerViewController_;

#pragma mark - Properties

- (MFMailComposeViewController *)mailComposerViewController
{
    if (nil == mailComposerViewController_) {
        mailComposerViewController_ = [[MFMailComposeViewController alloc] init];
        mailComposerViewController_.mailComposeDelegate = self;
    }                            
    
    return mailComposerViewController_;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLocalizedString(@"TAG_INFO_TITLE", @"");
    self.subTitleLabel.text = NSLocalizedString(@"TAG_INFO_SUBTITLE", @"");
    self.feedbackInfoLabel.text = NSLocalizedString(@"TAG_INFO_FEEDBACKINFO", @"");
    [self.feedbackEmailButton setTitle:NSLocalizedString(@"TAG_INFO_FEEDBACKEMAIL", @"") forState:UIControlStateNormal];
    self.developedByLabel.text = NSLocalizedString(@"TAG_INFO_DEVELOPEDBY", @"");
    self.versionLabel.text = NSLocalizedString(@"TAG_INFO_VERSION", @"");
    
    if (![MFMailComposeViewController canSendMail]) {
        self.feedbackEmailButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Control Events

- (IBAction)closeButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)emailButton:(id)sender
{
    NSString *subjectWithVersion = NSLocalizedString(@"TAG_SUPPORTEMAIL_TEMPLATE_TITLE", @"");
    subjectWithVersion = [subjectWithVersion stringByAppendingFormat:@" %@", NSLocalizedString(@"TAG_VERSION", @"")];
    [self.mailComposerViewController setSubject:subjectWithVersion];
    [self.mailComposerViewController setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"TAG_SUPPORTEMAIL_TEMPLATE_RECIPENT", @"")]];
    [self presentViewController:self.mailComposerViewController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.mailComposerViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
