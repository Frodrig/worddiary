//
//  WDIndexDiaryScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 10/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDIndexDiaryScreenViewController.h"
#import "WDIndexDiaryCollectionViewController.h"
#import "WDWord.h"
#import "WDEmotion.h"
#import "WDPalette.h"
#import "WDStyle.h"
#import "WDWordDiary.h"

@interface WDIndexDiaryScreenViewController ()

#pragma mark - Properties

@property(nonatomic, strong) UIView                                  *auxiliaryButtonsContainerView;
@property(nonatomic, strong) UIButton                                *settingsBtn;
@property(nonatomic, strong) UIButton                                *helpBtn;
@property(nonatomic, strong) UIButton                                *infoBtn;
@property(nonatomic, strong) WDIndexDiaryCollectionViewController    *indexDiaryCollectionViewController;

- (void)auxiliaryButtonPressed:(UIButton *)button;

#pragma mark - Methods definitions

- (void) createAuxiliaryButtons;
- (void) createIndexDiaryCollectionViewController;

@end

@implementation WDIndexDiaryScreenViewController

#pragma mark - Synthesize

@synthesize auxiliaryButtonsContainerView      = auxiliaryButtonsContainerView_;
@synthesize settingsBtn                        = settingsBtn_;
@synthesize helpBtn                            = helpBtn_;
@synthesize infoBtn                            = infoBtn_;
@synthesize indexDiaryCollectionViewController = indexDiaryCollectionViewController_;
@synthesize delegate                           = delegate_;
@synthesize dataSource                         = dataSource_;

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
	
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    // Auxiliary Buttons
    [self createAuxiliaryButtons];
    //[self.view addSubview:self.auxiliaryButtonsContainerView];
    
    // Collection View
    [self createIndexDiaryCollectionViewController];
    [self.view addSubview:self.indexDiaryCollectionViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary - Init

- (void)createAuxiliaryButtons
{
    settingsBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsBtn_.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
    [settingsBtn_ setImage:[UIImage imageNamed:@"19-gear"] forState:UIControlStateNormal];
    settingsBtn_.backgroundColor = [UIColor clearColor];
    [settingsBtn_ addTarget:self action:@selector(auxiliaryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    helpBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    helpBtn_.frame = CGRectMake(settingsBtn_.frame.origin.x + 44.0, 0.0, 44.0, 44.0);
    [helpBtn_ setImage:[UIImage imageNamed:@"441-help-symbol1"] forState:UIControlStateNormal];
    helpBtn_.backgroundColor = [UIColor clearColor];
    [helpBtn_ addTarget:self action:@selector(auxiliaryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    infoBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn_.frame = CGRectMake(helpBtn_.frame.origin.x + 44.0, 0.0, 44.0, 44.0);
    [infoBtn_ setImage:[UIImage imageNamed:@"442-information-symbol1"] forState:UIControlStateNormal];
    infoBtn_.backgroundColor = [UIColor clearColor];
    [infoBtn_ addTarget:self action:@selector(auxiliaryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect auxilaryButtonsContainerViewFrame = CGRectUnion(settingsBtn_.frame, helpBtn_.frame);
    auxilaryButtonsContainerViewFrame = CGRectUnion(auxilaryButtonsContainerViewFrame, infoBtn_.frame);
    auxilaryButtonsContainerViewFrame = CGRectMake(self.view.bounds.size.width - auxilaryButtonsContainerViewFrame.size.width, 20.0, auxilaryButtonsContainerViewFrame.size.width, auxilaryButtonsContainerViewFrame.size.height);
    auxiliaryButtonsContainerView_ = [[UIView alloc] initWithFrame:auxilaryButtonsContainerViewFrame];
    auxiliaryButtonsContainerView_.backgroundColor = [UIColor clearColor];
    [auxiliaryButtonsContainerView_ addSubview:settingsBtn_];
    [auxiliaryButtonsContainerView_ addSubview:helpBtn_];
    [auxiliaryButtonsContainerView_ addSubview:infoBtn_];
}

- (void)createIndexDiaryCollectionViewController
{
    indexDiaryCollectionViewController_ = [[WDIndexDiaryCollectionViewController alloc] init];
    indexDiaryCollectionViewController_.delegate = self;
    indexDiaryCollectionViewController_.dataSource = self;
    
    indexDiaryCollectionViewController_.view.frame = CGRectMake(0.0,
                                                                0.0,//auxiliaryButtonsContainerView_.frame.origin.y + auxiliaryButtonsContainerView_.frame.size.height,
                                                                self.view.bounds.size.width - 0.0,
                                                                self.view.bounds.size.height);//self.view.bounds.size.height - auxiliaryButtonsContainerView_.bounds.size.height - 0.0);
    indexDiaryCollectionViewController_.collectionView.backgroundColor = [UIColor clearColor];
    

}

#pragma mark - Controls Events

- (void)auxiliaryButtonPressed:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - WDIndexDiaryCollectionViewControllerDelegate

- (void)indexDiaryScreenViewController:(WDIndexDiaryCollectionViewController *)controller wordDoubleTapSelectedAtIndex:(NSUInteger)index
{
    [self.delegate indexDiaryScreenViewController:self wordDoubleTapSelectedAtIndex:index];
}

- (void)indexDiaryScreenViewController:(WDIndexDiaryCollectionViewController *)controller wordSingleTapSelectedAtIndex:(NSUInteger)index
{
    WDWord *word = [[WDWordDiary sharedWordDiary].words objectAtIndex:index];
    //WDPalette *palette = [word.emotion findPaletteOfIdName:word.paletteIdNameOfEmotion];
    
    UILabel *newWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 44.0, self.view.bounds.size.width - 10.0, 132.0)];
    newWordLabel.attributedText = [[NSAttributedString alloc] initWithString:word.word
                                                                  attributes:@{
                                                         NSFontAttributeName: [UIFont fontWithName:word.style.familyFont size:68.0],
                                                  NSForegroundColorAttributeName: [UIColor blackColor],
                                                             NSKernAttributeName: [NSNumber numberWithInt:3.0]}];
    newWordLabel.textAlignment = NSTextAlignmentCenter;
    newWordLabel.adjustsFontSizeToFitWidth = YES;
    newWordLabel.minimumScaleFactor = 0.1;
    newWordLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:newWordLabel];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:1.75 animations:^{
        newWordLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [newWordLabel removeFromSuperview];
    }];
}

#pragma mark - WDIndexDiaryCollectionViewDataSource

- (NSUInteger)selectedIndexWordForIndexDiaryCollectionViewController:(WDIndexDiaryCollectionViewController *)controller
{
    return [self.dataSource selectedIndexWordForIndexDiaryScreenViewController:self];
}

@end
