//
//  WDSettingsScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 24/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSettingsScreenViewController.h"
#import "WDWordDiary.h"

const NSUInteger REMOVEDAYWITHOUTWORDS_OPTIONTAG                 = 1;
const NSUInteger REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG            = 10;
const NSUInteger BLOCKPREVIOUSDAYEDIT_OPTIONTAG                  = 2;
const NSUInteger BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG             = 20;
const NSUInteger BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG              = 21;
const NSUInteger CREATENEWENTRYEACHDAY_OPTIONTAG                 = 3;
const NSUInteger CREATENEWENTRYEACHDAY_YES_BUTTONTAG             = 30;
const NSUInteger CREATENEWENTRYEACHDAY_NO_BUTTONTAG              = 31;
const NSUInteger ACTIVATEBACKGROUNDGRADIENTANIM_OPTIONTAG      = 4;
const NSUInteger ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG  = 40;
const NSUInteger ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG   = 41;

@interface WDSettingsScreenViewController ()

- (void) activeStateOfYesNoButton:(UIButton *)button;

- (void) buttonYesNoPressed:(UIButton *)sender;
- (void) buttonNowPressed:(UIButton *)sender;

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
    
    // Targets
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG]) addTarget:self action:@selector(buttonNowPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Labels
    ((UILabel *)[self.view viewWithTag:REMOVEDAYWITHOUTWORDS_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_REMOVEDAYWITHOUTWORDS", @"");
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NOW", @"") forState:UIControlStateNormal];
    ((UILabel *)[self.view viewWithTag:BLOCKPREVIOUSDAYEDIT_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_BLOCKPREVIOUSDAYEDIT", @"");
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
    ((UILabel *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_CREATENEWENTRYEACHDAY", @"");
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
    ((UILabel *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_DEACTIVATEBACKGROUNDGRADIENTANIM", @"");
    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
    
    // Settings
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG]) setTitleColor:[[WDWordDiary sharedWordDiary] findAllDaysIndexWithoutWord].count > 0 ? [UIColor whiteColor] : [UIColor darkGrayColor] forState:UIControlStateNormal];
    [self activeStateOfYesNoButton:[[NSUserDefaults standardUserDefaults] boolForKey:@"BLOCK_PREVIOUS_DAYS_EDIT"] ? (UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG] : (UIButton *)[self.view viewWithTag:BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG]];
    [self activeStateOfYesNoButton:[[NSUserDefaults standardUserDefaults] boolForKey:@"CREATE_NEW_ENTRY_EACHDAY"] ? (UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_YES_BUTTONTAG] : (UIButton *)[self.view viewWithTag:CREATENEWENTRYEACHDAY_NO_BUTTONTAG]];
    [self activeStateOfYesNoButton:[[NSUserDefaults standardUserDefaults] boolForKey:@"SETTINGS_SCREEN_ACTIVATEBACKGROUNDGRADIENTANIM"] ? (UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG] : (UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG]];
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

- (void)buttonNowPressed:(UIButton *)sender
{
    // Limpieza si procede
    NSArray *indexWords = [[WDWordDiary sharedWordDiary] removeAllDaysWithoutWord];
    [self.delegate wordWithIndex:indexWords removedFromSettingsScreenViewControllerRemoveAllEmptyWordDays:self];
    
    [sender setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [sender removeTarget:self action:@selector(buttonNowPressed:) forControlEvents:UIControlEventAllEvents];
}

- (void)buttonYesNoPressed:(UIButton *)sender
{
    [self activeStateOfYesNoButton:sender];

   if (sender.tag == BLOCKPREVIOUSDAYSEDIT_YES_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BLOCK_PREVIOUS_DAYS_EDIT"];
    } else if (sender.tag == BLOCKPREVIOUSDAYSEDIT_NO_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"BLOCK_PREVIOUS_DAYS_EDIT"];
    } else if (sender.tag == CREATENEWENTRYEACHDAY_YES_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CREATE_NEW_ENTRY_EACHDAY"];
    } else if (sender.tag == CREATENEWENTRYEACHDAY_NO_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"CREATE_NEW_ENTRY_EACHDAY"];
    } else if (sender.tag == ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SETTINGS_SCREEN_ACTIVATEBACKGROUNDGRADIENTANIM"];
        [self.delegate backgroundAnimationGradientSettingsUpdateFromSettingsScreenViewController:self];
    } else if (sender.tag == ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SETTINGS_SCREEN_ACTIVATEBACKGROUNDGRADIENTANIM"];
        [self.delegate backgroundAnimationGradientSettingsUpdateFromSettingsScreenViewController:self];
    }
}

@end
