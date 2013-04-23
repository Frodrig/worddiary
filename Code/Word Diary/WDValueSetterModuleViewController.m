//
//  WDValueSetterModuleViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 22/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDValueSetterModuleViewController.h"

@interface WDValueSetterModuleViewController ()

@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonTextDataValue;

@end

@implementation WDValueSetterModuleViewController

#pragma mark - Synthesize

@synthesize minusButton         = minusButton_;
@synthesize plusButton          = plusButton_;
@synthesize buttonTextDataValue = buttonTextDataValue_;
@synthesize delegate            = delegate_;
@synthesize dataSource          = dataSource_;
@synthesize enabled             = enabled_;

#pragma mark - Properties

-(void)setEnabled:(BOOL)enabled
{
    if (enabled_ != enabled) {
        self.minusButton.enabled = enabled;
        self.plusButton.enabled = enabled;
        self.buttonTextDataValue.enabled = enabled;
        enabled_ = enabled;
    }
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        enabled_ = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    NSString *initialValue = [self.dataSource initialDataValueTextForValueSetterModuleViewController:self];
    [self.buttonTextDataValue setTitle:initialValue forState:UIControlStateNormal];
    
    //self.minusButton.alpha = self.plusButton.alpha = 0.0;
    //self.minusButton.enabled = self.plusButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)refreshDataValue
{
    [self.buttonTextDataValue setTitle:[self.dataSource actualDataValueTextForValueSetterModuleViewController:self] forState:UIControlStateNormal];
}

#pragma mark - Controls Events

- (IBAction)minusButtonPressed:(id)sender
{
    NSString *newValue = [self.dataSource valueAfterMinusButtonPressedForValueSetterModuleViewController:self];
    [self.buttonTextDataValue setTitle:newValue forState:UIControlStateNormal];
}

- (IBAction)plusButtonPressed:(id)sender
{
    NSString *newValue = [self.dataSource valueAfterPlusButtonPressedForValueSetterModuleViewController:self];
    [self.buttonTextDataValue setTitle:newValue forState:UIControlStateNormal];
}

- (IBAction)valueButtonPressed:(id)sender
{
    [self.delegate dataValueButtonPressedForValueSetterModuleViewController:self];
}

@end
