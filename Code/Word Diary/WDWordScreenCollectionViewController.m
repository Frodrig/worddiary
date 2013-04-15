//
//  WDWordScreenCollectionViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordScreenCollectionViewController.h"
#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDPalette.h"
#import "WDStyle.h"
#import "WDUtils.h"
#import "WDWordScreenCollectionViewCell.h"
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>

@interface WDWordScreenCollectionViewController ()

@property (nonatomic, strong) NSTimer                 *fadeDecoratorTextTimer;
@property (nonatomic, strong) UITapGestureRecognizer  *tapGestureRecognizer;

- (NSUInteger)                       convertIndexPathToWordIndexContainer:(NSIndexPath *)indexPath;
- (NSIndexPath *)                    converWordIndexContainerToIndexPath:(NSUInteger)index;

- (void)                             fadeInDecoratorTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
- (void)                             fadeDecoratorTextTimerHandle:(NSTimer *)timer;

- (void)                             tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture;

- (WDWordScreenCollectionViewCell *) findSelectedCell;
- (WDWord *)                         findSelectedWord;
- (NSIndexPath *)                    indexPathForLastWord;

@end

@implementation WDWordScreenCollectionViewController

#pragma mark - Synthesize

@synthesize fadeDecoratorTextTimer = fadeDecoratorTextTimer_;
@synthesize tapGestureRecognizer   = tapGestureRecognizer_;

#pragma mark - Init

- (id)init
{
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        // Teclado
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    return [self init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"WDWordScreenCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"WordScreenCell"];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Cfg layout
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    const CGFloat edgeMargin = 3.0;
    flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width - edgeMargin * 2, self.view.bounds.size.height - edgeMargin * 2);
    flowLayout.sectionInset = UIEdgeInsetsMake(edgeMargin, edgeMargin, edgeMargin, edgeMargin);
    
    // Scroll a la ultima palabra
    [self.collectionView scrollToItemAtIndexPath:[self indexPathForLastWord] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    // Timer tap
    [self launchFadeDecoratorTextTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (void) fadeInDecoratorTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
{
    if (nil == self.fadeDecoratorTextTimer) {
        [cell fadeInDecoratorText];
    }
    
    if (infiniteDuration) {
        [self.fadeDecoratorTextTimer invalidate];
        self.fadeDecoratorTextTimer = nil;
    } else {
        [self launchFadeDecoratorTextTimer];
    }

}

- (NSUInteger) convertIndexPathToWordIndexContainer:(NSIndexPath *)indexPath
{
    NSUInteger retValue = [WDWordDiary sharedWordDiary].words.count - indexPath.section - 1;
    
    return retValue;
}

- (NSIndexPath *) converWordIndexContainerToIndexPath:(NSUInteger)index
{
    NSIndexPath *retIndexPath = [NSIndexPath indexPathForRow:0 inSection:[WDWordDiary sharedWordDiary].words.count - index - 1];
    
    return retIndexPath;
}

- (WDWord *) findSelectedWord
{
    UICollectionViewCell *visibleCell = [self.collectionView.visibleCells objectAtIndex:0];
    NSIndexPath *indexPathForVisibleCell = [self.collectionView indexPathForCell:visibleCell];
    NSUInteger wordIndexPath = [self convertIndexPathToWordIndexContainer:indexPathForVisibleCell];
    
    return [[WDWordDiary sharedWordDiary].words objectAtIndex:wordIndexPath];
}

- (NSIndexPath *) indexPathForLastWord
{
    return [NSIndexPath indexPathForRow:0 inSection:[WDWordDiary sharedWordDiary].words.count - 1];
}

- (WDWordScreenCollectionViewCell *) findSelectedCell
{
    return [self.collectionView.visibleCells objectAtIndex:0];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WordScreenCell" forIndexPath:indexPath];
    WDWord *word = [[WDWordDiary sharedWordDiary].words objectAtIndex:[self convertIndexPathToWordIndexContainer:indexPath]];
    [cell setWord:word];
        
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1.0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [WDWordDiary sharedWordDiary].words.count;
}

#pragma mark - Timers

- (void)launchFadeDecoratorTextTimer
{
    [self.fadeDecoratorTextTimer invalidate];
    self.fadeDecoratorTextTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(fadeDecoratorTextTimerHandle:) userInfo:nil repeats:NO];
}

- (void)fadeDecoratorTextTimerHandle:(NSTimer *)timer
{
    WDWordScreenCollectionViewCell * visibleCell = [self.collectionView.visibleCells objectAtIndex:0];
    [visibleCell fadeOutDecoratorText];
    
    self.fadeDecoratorTextTimer = nil;
}

#pragma mark - Gesture Recognizer

- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture
{
    if (gesture == self.tapGestureRecognizer) {
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        CGPoint hitPoint = [gesture locationInView:cell];
        if (CGRectContainsPoint(cell.wordRepresentationContainerView.frame, hitPoint)) {
            [self becomeFirstResponder];
        } else {
            [self fadeInDecoratorTextOnCell:cell withInfiniteDuration:NO];
        }
    }
}

#pragma mark - WDWordRepresentatonViewDataSource

- (NSString *)selectedWordTextForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWord];
    return selectedWord.word;
}

- (UIColor *)selectedWordColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWord];
    return [UIColor colorWithHexadecimalValue:selectedWord.palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
}

- (NSString *) selectedWordTextFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWord];
    return selectedWord.style.familyFont;
}

- (CGFloat) selectedWordFontStartSizeForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    const CGFloat startFontSize = 100.0;
    return [WDUtils isIPhone5Screen] ? startFontSize * 1.15 : startFontSize * 0.9;
}

- (BOOL)isKeyboardActiveForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    return [self isFirstResponder];
}

#pragma mark - Keyboard

#pragma mark - UIView sobrecarga

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIKeyInput

- (void)deleteBackward
{
    WDWord *selectedWord = [self findSelectedWord];
    if (selectedWord.word.length > 0) {
        selectedWord.word = [selectedWord.word substringWithRange:NSMakeRange(0, selectedWord.word.length - 1)];
    }
}

- (BOOL)hasText
{
    WDWord *selectedWord = [self findSelectedWord];
    return selectedWord.word.length > 0;
}

- (void)insertText:(NSString *)text
{
    WDWord *selectedWord = [self findSelectedWord];
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]].length == 0) {
        [self resignFirstResponder];
    } else if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        static const NSUInteger MAX_LENGHT = 40;
        if (selectedWord.word.length < MAX_LENGHT) {
            selectedWord.word = [selectedWord.word stringByAppendingString:text];
        }
    }
}

#pragma mark KeyboardNotification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
    [self fadeInDecoratorTextOnCell:cell withInfiniteDuration:YES];
    
    self.collectionView.scrollEnabled = NO;
    
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
    [self fadeInDecoratorTextOnCell:cell withInfiniteDuration:NO];
    
    self.collectionView.scrollEnabled = YES;
}

@end
