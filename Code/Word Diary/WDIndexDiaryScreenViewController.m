//
//  WDIndexDiaryScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 10/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDIndexDiaryScreenViewController.h"

@interface WDIndexDiaryScreenViewController ()

#pragma mark - Properties

@property(nonatomic, strong) UIView   *auxiliaryButtonsContainerView;
@property(nonatomic, strong) UIButton *settingsBtn;
@property(nonatomic, strong) UIButton *helpBtn;
@property(nonatomic, strong) UIButton *infoBtn;

- (void)auxiliaryButtonPressed:(UIButton *)button;

#pragma mark - Methods definitions

- (void) createAuxiliaryButtons;

@end

@implementation WDIndexDiaryScreenViewController

#pragma mark - Synthesize

@synthesize auxiliaryButtonsContainerView = auxiliaryButtonsContainerView_;
@synthesize settingsBtn                   = settingsBtn_;
@synthesize helpBtn                       = helpBtn_;
@synthesize infoBtn                       = infoBtn_;

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
    [self.view addSubview:self.auxiliaryButtonsContainerView];
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
    settingsBtn_.frame = CGRectMake(0.0, 20.0, 44.0, 44.0);
    [settingsBtn_ setTitle:@"1" forState:UIControlStateNormal];
    settingsBtn_.backgroundColor = [UIColor clearColor];
    [settingsBtn_ addTarget:self action:@selector(auxiliaryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    helpBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    helpBtn_.frame = CGRectMake(settingsBtn_.frame.origin.x + 44.0, 20.0, 44.0, 44.0);
    [helpBtn_ setTitle:@"2" forState:UIControlStateNormal];
    helpBtn_.backgroundColor = [UIColor clearColor];
    [helpBtn_ addTarget:self action:@selector(auxiliaryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    infoBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn_.frame = CGRectMake(helpBtn_.frame.origin.x + 44.0, 20.0, 44.0, 44.0);
    [infoBtn_ setTitle:@"3" forState:UIControlStateNormal];
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

#pragma mark - Controls Events

- (void)auxiliaryButtonPressed:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
