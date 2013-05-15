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
#import "WDDashBoardViewController.h"
#import "WDWord.h"
#import "WDUtils.h"
#import "WDWordDiary.h"

@interface WDWordScreenViewController ()

#pragma mark - Properties

@property(nonatomic, weak)   WDWord                               *selectedWord;
@property(nonatomic, strong) UIImageView                          *launchTransitionImageView;
@property(nonatomic, strong) UIView                               *launchTransitionCursorView;
@property(nonatomic, strong) WDHelpScreenViewController           *helpScreenViewController;
@property(nonatomic, strong) WDWordScreenCollectionViewController *wordScreenCollectionViewController;
@property(nonatomic, strong) NSTimer                              *blinkCursorTimer;

- (WDWord *)            createFirstWord;

- (void)                showApropiateViewController;

- (void)                fadeOutLaunchImage;

- (void)                applicationWillResignActive:(NSNotification *)notification;
- (void)                applicationDidEnterBackground:(NSNotification *)notification;
- (void)                applicationWillEnterForeground:(NSNotification *)notification;
- (void)                applicationDidBecomeActive:(NSNotification *)notification;
- (void)                applicationWillTerminate:(NSNotification *)notification;

- (void)                doBlinkCursorLaunchScreenHandle:(NSTimer *)timer;

@end

@implementation WDWordScreenViewController

#pragma mark - Synthesize

@synthesize selectedWord                       = selectedWord_;
@synthesize launchTransitionImageView          = launchTransitionImageView_;
@synthesize helpScreenViewController           = helpScreenViewController_;
@synthesize wordScreenCollectionViewController = wordScreenCollectionViewController_;
@synthesize launchTransitionCursorView         = launchTransitionCursorView_;
@synthesize blinkCursorTimer                   = blinkCursorTimer_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
        [self createFirstWord];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    self.view.backgroundColor = [UIColor blackColor];
    self.view.opaque = NO;
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.autoresizesSubviews = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.launchTransitionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[WDUtils is568Screen] ? @"Default-568h" : @"Default"]];
    //self.launchTransitionCursorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10, 212.5)];
    //self.launchTransitionCursorView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    //[self.launchTransitionImageView addSubview:self.launchTransitionCursorView];
    //self.launchTransitionCursorView.center = [WDUtils isIPhone5Screen] ? CGPointMake(297, 163) : CGPointMake(297, 152);
    [self.view addSubview:self.launchTransitionImageView];
    
    //self.blinkCursorTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(doBlinkCursorLaunchScreenHandle:) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   // [self showApropiateViewController];
    [self performSelector:@selector(showApropiateViewController) withObject:nil afterDelay:1.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (void)doBlinkCursorLaunchScreenHandle:(NSTimer *)timer
{
    static bool alphaBlink = YES;
    self.launchTransitionCursorView.backgroundColor = alphaBlink ? [UIColor colorWithWhite:0.0 alpha:0.7] : [UIColor colorWithWhite:0.0 alpha:1.0];
    alphaBlink = !alphaBlink;
}

- (void)fadeOutLaunchImage
{
    const BOOL helpScreenHaveLaunchAtInit = [[NSUserDefaults standardUserDefaults] boolForKey:@"HELP_SCREEN_HAVE_LAUCH_AT_INIT"];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:helpScreenHaveLaunchAtInit ? 2.0 : 2.0 animations:^{
        self.launchTransitionImageView.alpha = 0.0;
        if (helpScreenHaveLaunchAtInit) {
            if (self.wordScreenCollectionViewController.presentedViewController != nil) {
                if (self.wordScreenCollectionViewController.presentedViewController.presentedViewController == nil) {
                    self.launchTransitionImageView.center = CGPointMake(self.launchTransitionImageView.center.x, self.launchTransitionImageView.center.y * - 1);
                }
            } else {
                self.launchTransitionImageView.center = CGPointMake(self.launchTransitionImageView.center.x * -1, self.launchTransitionImageView.center.y);
            }
        }
    } completion:^(BOOL finished) {
        [self.launchTransitionImageView removeFromSuperview];
        self.launchTransitionImageView = nil;
        //[self.blinkCursorTimer invalidate];
        //self.blinkCursorTimer = nil;
    }];
}

- (void)showApropiateViewController
{
    [self fadeOutLaunchImage];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HELP_SCREEN_HAVE_LAUCH_AT_INIT"]) {
        self.helpScreenViewController = [[WDHelpScreenViewController alloc] initWithNibName:nil bundle:nil];
        self.helpScreenViewController.delegate = self;
        self.helpScreenViewController.view.frame = self.view.frame;
        [self.view insertSubview:self.helpScreenViewController.view belowSubview:self.launchTransitionImageView];
    } else {
        self.wordScreenCollectionViewController = [[WDWordScreenCollectionViewController alloc] init];
        [self.view insertSubview:self.wordScreenCollectionViewController.view belowSubview:self.launchTransitionImageView];
    }
}

- (WDWord *)createFirstWord
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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FIRST_BACKGROUND_SETTING"]) {
        WDPalette *startingWordPalette = [[WDWordDiary sharedWordDiary].palettes objectAtIndex:1];
        selectedWordCandidate.palette = startingWordPalette;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FIRST_BACKGROUND_SETTING"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return selectedWordCandidate;
}

#pragma mark - WDHelpScreenViewControllerDelegate

- (void)willReachLastPageFromHelpScreenViewController:(WDHelpScreenViewController *)helpScreenViewController
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HELP_SCREEN_HAVE_LAUCH_AT_INIT"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReachLastPageFromHelpScreenViewController:(WDHelpScreenViewController *)helpScreenViewController
{
    [self.helpScreenViewController.view removeFromSuperview];
    self.helpScreenViewController = nil;
    
    self.wordScreenCollectionViewController = [[WDWordScreenCollectionViewController alloc] init];
    [self.view addSubview:self.wordScreenCollectionViewController.view];
}

#pragma mark - Application Notifications

- (void)applicationWillResignActive:(NSNotification *)notification
{
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [[WDWordDiary sharedWordDiary] cutWordsArrayAtPresentDay];
    
    BOOL createTodayWord = [WDWordDiary sharedWordDiary].words.count == 0;
    if (!createTodayWord) {
        createTodayWord = self.wordScreenCollectionViewController && self.wordScreenCollectionViewController.presentedViewController == nil;
    }
    if (createTodayWord) {
        [self createFirstWord];
    }
    
    if (!self.launchTransitionImageView) {
        self.launchTransitionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[WDUtils is568Screen] ? @"Default-568h" : @"Default"]];
        [self.view insertSubview:self.launchTransitionImageView aboveSubview:self.helpScreenViewController ? self.helpScreenViewController.view : self.wordScreenCollectionViewController.view];
        [self performSelector:@selector(fadeOutLaunchImage) withObject:nil afterDelay:0.5];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
}


@end
