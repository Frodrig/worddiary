//
//  WDColorMenuSelectorViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 01/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDColorMenuSelectorViewController.h"
#import "WDWordDiary.h"

@interface WDColorMenuSelectorViewController ()

- (void) prepareColorButtons;

@end

@implementation WDColorMenuSelectorViewController

#pragma mark - Delegate

@synthesize delegate = delegate_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Prepara botones
    [self prepareColorButtons];   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary Methods

- (void)prepareColorButtons
{
    NSArray *colors = [WDWordDiary sharedWordDiary].colors;
    for (NSUInteger colorIt = 0; colorIt < colors.count; ++colorIt) {
        UIButton *button = (UIButton *)[self.view viewWithTag:200+colorIt];
        [button addTarget:self action:@selector(colorSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - UIControls Events

- (void)colorSelected:(UIButton *)sender
{
    NSArray *colors = [WDWordDiary sharedWordDiary].colors;
    WDColor *color = [colors objectAtIndex:(sender.tag - 200)];
    
    [self.delegate colorMenuSelector:self selectedColor:color];
}

@end
