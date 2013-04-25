//
//  WDHelpScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDHelpScreenViewController.h"

@interface WDHelpScreenViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView  *scrollView;
@property (weak, nonatomic) IBOutlet UILabel       *infoLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (void) setInfolabelTextForCurrentPage;

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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    [self setInfolabelTextForCurrentPage];
    
    if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate reachLastPageFromHelpScreenViewController:self];
        }];
    }
}

@end
