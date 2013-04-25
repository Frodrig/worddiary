//
//  WDSettingsScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 24/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSettingsScreenViewController.h"
#import "WDWordDiary.h"
#import "WDInfoScreenViewController.h"
#import "WDHelpScreenViewController.h"

const NSUInteger REMOVEDAYWITHOUTWORDS_OPTIONTAG               = 30;
const NSUInteger REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG          = 31;
const NSUInteger SHOWHELPINTRO_OPTIONTAG                       = 20;
const NSUInteger SHOWHELPINTRO_NOW_BUTTONTAG                   = 21;
const NSUInteger ACTIVATEBACKGROUNDGRADIENTANIM_OPTIONTAG      = 10;
const NSUInteger ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG  = 11;
const NSUInteger ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG   = 12;

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
    [((UIButton *)[self.view viewWithTag:SHOWHELPINTRO_NOW_BUTTONTAG]) addTarget:self action:@selector(buttonNowPressed:) forControlEvents:UIControlEventTouchUpInside];

    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG]) addTarget:self action:@selector(buttonYesNoPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Labels
    ((UILabel *)[self.view viewWithTag:REMOVEDAYWITHOUTWORDS_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_REMOVEDAYWITHOUTWORDS", @"");
    [((UIButton *)[self.view viewWithTag:SHOWHELPINTRO_NOW_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NOW", @"") forState:UIControlStateNormal];
    
    ((UILabel *)[self.view viewWithTag:SHOWHELPINTRO_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_SHOWHELPINTRO", @"");
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NOW", @"") forState:UIControlStateNormal];
    
    ((UILabel *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_OPTIONTAG]).text = NSLocalizedString(@"SETTINGS_SCREEN_DEACTIVATEBACKGROUNDGRADIENTANIM", @"");
    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_YES", @"") forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG]) setTitle:NSLocalizedString(@"SETTINGS_SCREEN_NO", @"") forState:UIControlStateNormal];
    
    // Settings
    [((UIButton *)[self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG]) setTitleColor:[[WDWordDiary sharedWordDiary] findAllDaysIndexWithoutWord].count > 0 ? [UIColor whiteColor] : [UIColor darkGrayColor] forState:UIControlStateNormal];
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
    BOOL tagValueYes = button.tag % 2 == 0 ? NO : YES;
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
    WDInfoScreenViewController *infoScreenViewController = [[WDInfoScreenViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:infoScreenViewController animated:YES completion:nil];
}

- (void)buttonNowPressed:(UIButton *)sender
{
    if (sender == [self.view viewWithTag:REMOVEDAYSWITHOUTWORDS_NOW_BUTTONTAG]) {
        NSArray *indexWords = [[WDWordDiary sharedWordDiary] removeAllDaysWithoutWord];
        [self.delegate wordWithIndex:indexWords removedFromSettingsScreenViewControllerRemoveAllEmptyWordDays:self];
        
        [sender setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [sender removeTarget:self action:@selector(buttonNowPressed:) forControlEvents:UIControlEventAllEvents];
    } else if (sender == [self.view viewWithTag:SHOWHELPINTRO_NOW_BUTTONTAG]) {
        WDHelpScreenViewController *helpScreenController = [[WDHelpScreenViewController alloc] initWithNibName:nil bundle:nil];
        helpScreenController.delegate = self;
        [self presentViewController:helpScreenController animated:YES completion:nil];
    }
}

- (void)buttonYesNoPressed:(UIButton *)sender
{
    [self activeStateOfYesNoButton:sender];

    if (sender.tag == ACTIVATEBACKGROUNDGRADIENTANIM_YES_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SETTINGS_SCREEN_ACTIVATEBACKGROUNDGRADIENTANIM"];
        [self.delegate backgroundAnimationGradientSettingsUpdateFromSettingsScreenViewController:self];
    } else if (sender.tag == ACTIVATEBACKGROUNDGRADIENTANIM_NO_BUTTONTAG) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SETTINGS_SCREEN_ACTIVATEBACKGROUNDGRADIENTANIM"];
        [self.delegate backgroundAnimationGradientSettingsUpdateFromSettingsScreenViewController:self];
    }
}

#pragma mark - WDHelpScreenViewControllerDelegate

- (void) reachLastPageFromHelpScreenViewController:(WDHelpScreenViewController *)helpScreenViewController
{
    
}


@end
