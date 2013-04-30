//
//  WDWordScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordScreenViewController.h"
#import "WDWordScreenCollectionViewController.h"
#import "WDHelpScreenViewController.h"
#import "WDWord.h"
#import "WDWordDiary.h"

@interface WDWordScreenViewController ()

#pragma mark - Properties

@property(nonatomic, weak) WDWord   *selectedWord;

- (WDWord *) prepareSelectedWordAtLaunchOrResume;

@end

@implementation WDWordScreenViewController

#pragma mark - Synthesize

@synthesize selectedWord             = selectedWord_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self prepareSelectedWordAtLaunchOrResume];
        
          }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HELP_SCREEN_HAVE_LAUCH_AT_INIT"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HELP_SCREEN_HAVE_LAUCH_AT_INIT"];
        WDHelpScreenViewController *helpScreenViewController = [[WDHelpScreenViewController alloc] initWithNibName:nil bundle:nil];
        helpScreenViewController.delegate = self;
        [self presentViewController:helpScreenViewController animated:YES completion:nil];
    } else {
        WDWordScreenCollectionViewController *collectionViewController = [[WDWordScreenCollectionViewController alloc] init];
        [self presentViewController:collectionViewController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (WDWord *) prepareSelectedWordAtLaunchOrResume
{
    NSDate *todayDate = [NSDate date];
    WDWord *selectedWordCandidate = [[WDWordDiary sharedWordDiary] findLastCreatedWord];
    if (selectedWordCandidate != nil) {
        if (![selectedWordCandidate isTodayWord]) {
            if ([selectedWordCandidate isEmpty]) {
                selectedWordCandidate.timeInterval = [todayDate timeIntervalSince1970];
                selectedWordCandidate.word = @"";
            } else {
                selectedWordCandidate = nil;
            }
        }
    }
    
    if (nil == selectedWordCandidate) {
        selectedWordCandidate = [[WDWordDiary sharedWordDiary] createWord:@"" inTimeInterval:[todayDate timeIntervalSince1970]];
    }
    
    return selectedWordCandidate;
}


#pragma mark - WDHelpScreenViewControllerDelegate

- (void)reachLastPageFromHelpScreenViewController:(WDHelpScreenViewController *)helpScreenViewController
{
    //self.collectionViewController = [[WDWordScreenCollectionViewController alloc] init];
    //[self presentViewController:self.collectionViewController animated:YES completion:nil];
}

@end
