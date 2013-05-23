//
//  WDHelpScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDHelpScreenViewController.h"
#import "WDUtils.h"

@interface WDHelpScreenViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView  *scrollView;
@property (weak, nonatomic) IBOutlet UILabel       *infoLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (void)    setInfolabelTextForCurrentPage;

- (void)    createScreens;
- (void)    releaseScreens;

- (void)    prepareAlphasForAlphaAnimateInitTransition;
- (void)    alphaAnimateInitTransition;

- (void)    applicationWillResignActive:(NSNotification *)notification;
- (void)    applicationDidEnterBackground:(NSNotification *)notification;
- (void)    applicationWillEnterForeground:(NSNotification *)notification;
- (void)    applicationDidBecomeActive:(NSNotification *)notification;
- (void)    applicationWillTerminate:(NSNotification *)notification;

@end

@implementation WDHelpScreenViewController

#pragma mark - Synthesize

@synthesize scrollView  = scrollView_;
@synthesize infoLabel   = infoLabel_;
@synthesize pageControl = pageControl_;
@synthesize delegate    = delegate_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 6, self.scrollView.bounds.size.height);
    
    self.pageControl.currentPage = 0;
    
    [self setInfolabelTextForCurrentPage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view sizeToFit];
    
    [self prepareAlphasForAlphaAnimateInitTransition];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createScreens];
    [self alphaAnimateInitTransition];

    //NSLog(@"frame %@", NSStringFromCGRect(self.scrollView.bounds));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (void)setInfolabelTextForCurrentPage
{
    NSString *tagInfoHelp = @"TAG_HELP_INFOTEXT_PAGE_";
    tagInfoHelp = [tagInfoHelp stringByAppendingFormat:@"%d", self.pageControl.currentPage];
    self.infoLabel.text = NSLocalizedString(tagInfoHelp, @"");
}

- (void)createScreens
{    
    const NSUInteger maxScreens = 5;
    for (NSUInteger screenIt = 0; screenIt < maxScreens; screenIt++) {
        NSString *screenName = [NSString stringWithFormat:@"help_screen%d_%@", screenIt+1, NSLocalizedString(@"TAG_LANG", @"")];
        UIImageView *screen = [[UIImageView alloc] initWithFrame:self.scrollView.frame];
        screen.contentMode = UIViewContentModeScaleAspectFit;
        screen.image = [UIImage imageNamed:screenName];
        screen.frame = CGRectMake(screen.frame.size.width * screenIt, screen.frame.origin.y, screen.frame.size.width, screen.frame.size.height);
        if (screenIt == 1) {
            UIImageView *coachView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pointocoach"]];
            [screen addSubview:coachView];
            coachView.center = CGPointMake(100.0, screen.center.y * ([WDUtils is568Screen] ? 1.35 : 1.45));
        } else if (screenIt == 2) {
            UIImageView *coachView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"updowncoach"]];
            [screen addSubview:coachView];
            coachView.center = CGPointMake(screen.frame.size.width / 2.0, screen.frame.size.height / 2.0);
        } else if (screenIt == 3) {
            UIImageView *coachView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftrightcoach"]];
            [screen addSubview:coachView];
            coachView.center = CGPointMake([WDUtils is568Screen] ? screen.frame.size.width * 0.45 : screen.frame.size.width * 0.48, screen.frame.size.height / 1.55);
        }
        [self.scrollView addSubview:screen];
    }
}

- (void)alphaAnimateInitTransition
{
    [UIView animateWithDuration:1.5 animations:^{ self.scrollView.alpha = 1.0; }];
    [UIView animateWithDuration:2.0 animations:^{ self.infoLabel.alpha = 1.0; }];
    [UIView animateWithDuration:2.5 animations:^{ self.pageControl.alpha = 1.0; }];
}

- (void)prepareAlphasForAlphaAnimateInitTransition
{
    self.scrollView.alpha = 0.0;
    self.infoLabel.alpha = 0.0;
    self.pageControl.alpha = 0.0;
}

- (void)releaseScreens
{
    for (UIView *viewIt in self.scrollView.subviews) {
        if ([viewIt isKindOfClass:[UIImageView class]]) {
            [viewIt removeFromSuperview];
        }
    }
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = floor((self.scrollView.contentOffset.x / self.scrollView.bounds.size.width) + 0.5);
    [self setInfolabelTextForCurrentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
        [self.delegate willReachLastPageFromHelpScreenViewController:self];
        self.scrollView.scrollEnabled = NO;
        [UIView animateWithDuration:0.35 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.delegate didReachLastPageFromHelpScreenViewController:self];
        }];
    }
}

#pragma mark - UIApplicationNotification

- (void)applicationWillResignActive:(NSNotification *)notification
{
    
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self releaseScreens];
    [self prepareAlphasForAlphaAnimateInitTransition];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self createScreens];
    self.scrollView.contentOffset = CGPointMake(0.0, 0.0);
    self.pageControl.currentPage = 0;
    [self setInfolabelTextForCurrentPage];
    [self alphaAnimateInitTransition];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    
}


@end
