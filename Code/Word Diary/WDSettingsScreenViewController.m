//
//  WDSettingsScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 24/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSettingsScreenViewController.h"

const NSUInteger REMOVEDAYWITHOUTWORDS_OPTIONTAG                 = 1;
const NSUInteger REMOVEDAYSWITHOUTWORDS_YES_BUTTONTAG            = 10;
const NSUInteger REMOVEDAYSWITHOUTWORDS_NO_BUTTONTAG             = 11;
const NSUInteger BLOCKPREVIOUSDAYEDIT_OPTIONTAG                  = 2;
const NSUInteger BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG             = 20;
const NSUInteger BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG              = 21;
const NSUInteger CREATENEWENTRYEACHDAY_OPTIONTAG                 = 3;
const NSUInteger CREATENEWENTRYEACHDAY_YES_BUTTONTAG             = 30;
const NSUInteger CREATENEWENTRYEACHDAY_NO_BUTTONTAG              = 31;
const NSUInteger DEACTIVATEBACKGROUNDGRADIENTANIM_OPTIONTAG      = 4;
const NSUInteger DEACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG  = 40;
const NSUInteger DEACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG   = 41;

@interface WDSettingsScreenViewController ()

- (void) activeStateOfYesNoButton:(UIButton *)button;

- (void) buttonYesNoPressed:(UIButton *)sender;

@end

@implementation WDSettingsScreenViewController

#pragma mark - Synthesize

@synthesize delegate = delegate_;

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
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:DEACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:DEACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    ((UILabel *)[self.view viewWithTag:REMOVEDAYWITHOUTWORDS_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_REMOVEDAYWITHOUTWORDS", @"");
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
    ((UILabel *)[self.view viewWithTag:BLOCKPREVIOUSDAYEDIT_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_BLOCKPREVIOUSDAYEDIT", @"");
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
    ((UILabel *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_CREATENEWENTRYEACHDAY", @"");
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
    ((UILabel *)[self.view viewWithTag:DEACTIVATEBACKGROUNDGRADIENTANIM_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_DEACTIVATEBACKGROUNDGRADIENTANIM", @"");
    [((UIButton *)[self.view viewWithTag:DEACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:DEACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliar

- (void)activeStateOfYesNoButton:(UIButton *)button
{
    BOOL tagValueYes = button.tag % 2 == 0 ? YES : NO;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:tagValueYes ? button.tag + 1 : button.tag
                    - 1]) setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
}

#pragma mark - Control Events

- (IBAction)closeButtonPressed:(id)sender
{
    [self.delegate settingsScreenViewControllerWillDismiss:self];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate settingsScreenViewControllerDidDismiss:self];
    }];
}

- (IBAction)infoButtonPressed:(id)sender
{
}

- (void)buttonYesNoPressed:(UIButton *)sender
{
    [self activeStateOfYesNoButton:sender];

    if (sender.tag == REMOVEDAYSWITHOUTWORDS_YES_BUTTONTAG) {
    } else if (sender.tag == REMOVEDAYSWITHOUTWORDS_NO_BUTTONTAG) {
    } else if (sender.tag == BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG) {
    } else if (sender.tag == BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG) {
    } else if (sender.tag == CREATENEWENTRYEACHDAY_YES_BUTTONTAG) {
    } else if (sender.tag == CREATENEWENTRYEACHDAY_NO_BUTTONTAG) {
    } else if (sender.tag == DEACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG) {
    } else if (sender.tag == DEACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG) {
    }
}

@end
