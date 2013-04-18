//
//  WDWordScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordScreenViewController.h"
#import "WDWordScreenCollectionViewController.h"
#import "WDWord.h"
#import "WDWordDiary.h"

@interface WDWordScreenViewController ()

#pragma mark - Properties

@property(nonatomic, strong) WDWordScreenCollectionViewController *collectionViewController;
@property(nonatomic, weak) WDWord                                 *selectedWord;

- (WDWord *) prepareSelectedWordAtLaunchOrResume;

@end

@implementation WDWordScreenViewController

#pragma mark - Synthesize

@synthesize collectionViewController = collectionViewController_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self prepareSelectedWordAtLaunchOrResume];
        
        collectionViewController_ = [[WDWordScreenCollectionViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    collectionViewController_.view.frame = self.view.bounds;
    [self.view addSubview:collectionViewController_.view];
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
        selectedWordCandidate = [[WDWordDiary sharedWordDiary] createWord:@"Hola Mundo" inTimeInterval:[todayDate timeIntervalSince1970]];
    }
    
    return selectedWordCandidate;
}

@end
