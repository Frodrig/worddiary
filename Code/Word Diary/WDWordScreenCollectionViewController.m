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
@property (nonatomic, strong) NSTimer                 *cursorColorTimer;
@property (nonatomic, strong) UIColor                 *cursorColor;

- (NSUInteger)                       convertIndexPathToWordIndexContainer:(NSIndexPath *)indexPath;
- (NSIndexPath *)                    converWordIndexContainerToIndexPath:(NSUInteger)index;

- (void)                             launchFadeDecoratorTextTimer;
- (void)                             fadeInDecoratorTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
- (void)                             fadeDecoratorTextTimerHandle:(NSTimer *)timer;

- (void)                             tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture;

- (WDWordScreenCollectionViewCell *) findSelectedCell;
- (WDWord *)                         findSelectedWord;
- (WDWord *)                         findSelectedWordAtSectionIndex:(NSUInteger)sectionIndex;
- (NSIndexPath *)                    indexPathForLastWord;

- (void)                             launchCursorColorTimer;
- (void)                             endCursorColorTimer;
- (void)                             cursorColorTimerHandle:(NSTimer *)timer;

@end

@implementation WDWordScreenCollectionViewController

#pragma mark - Synthesize

@synthesize fadeDecoratorTextTimer = fadeDecoratorTextTimer_;
@synthesize tapGestureRecognizer   = tapGestureRecognizer_;
@synthesize cursorColorTimer       = cursorColorTimer_;
@synthesize cursorColor            = cursorColor_;

#pragma mark - Properties

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
    
    // Timers
    [self launchFadeDecoratorTextTimer];
    [self launchCursorColorTimer];
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

- (WDWord *) findSelectedWordAtSectionIndex:(NSUInteger)sectionIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:sectionIndex];
    NSUInteger wordIndexPath = [self convertIndexPathToWordIndexContainer:indexPath];
    
    return [[WDWordDiary sharedWordDiary].words objectAtIndex:wordIndexPath];
}

- (WDWord *) findSelectedWord
{
    WDWordScreenCollectionViewCell *selectedCell = [self findSelectedCell];
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:[self.collectionView indexPathForCell:selectedCell].section];
    
    return selectedWord;
}

- (NSIndexPath *) indexPathForLastWord
{
    return [NSIndexPath indexPathForRow:0 inSection:[WDWordDiary sharedWordDiary].words.count - 1];
}

- (WDWordScreenCollectionViewCell *) findSelectedCell
{
    NSUInteger sectionIndex = (self.collectionView.contentOffset.x / self.collectionView.bounds.size.width) + 0.5;
    WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Nota IMPORTANTE: En el tag del wordRepresentation guardamos la seccion del indexPath
    WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WordScreenCell" forIndexPath:indexPath];
    cell.wordRepresentationView.dataSource = self;
    cell.wordRepresentationView.clearsContextBeforeDrawing = YES;
    cell.wordRepresentationView.tag = indexPath.section;
    
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

- (void) launchCursorColorTimer
{
    [self.cursorColorTimer invalidate];
    self.cursorColorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(cursorColorTimerHandle:) userInfo:nil repeats:YES];
}

- (void) endCursorColorTimer
{
    [self.cursorColorTimer invalidate];
    self.cursorColorTimer = nil;
}

- (void)cursorColorTimerHandle:(NSTimer *)timer
{
    WDWord *selectedWord = [self findSelectedWord];
    if  (self.cursorColor) {
        CGFloat colorComponents[] = {0.0, 0.0, 0.0, 0.0};
        [self.cursorColor getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
        colorComponents[3] = colorComponents[3] < 1.0 ? 1.0 : 0.3;
        self.cursorColor = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:colorComponents[3]];
    } else {
        self.cursorColor = [UIColor colorWithHexadecimalValue:selectedWord.palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
    }
    
    WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
    [actualCell.wordRepresentationView setNeedsDisplay];
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
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:wordRepresentation.tag];
    return selectedWord.word;
}

- (UIColor *)selectedWordColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:wordRepresentation.tag];
    return [UIColor colorWithHexadecimalValue:selectedWord.palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
}

- (NSString *) selectedWordTextFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:wordRepresentation.tag];
    return selectedWord.style.familyFont;
}

- (CGFloat) selectedWordFontStartSizeForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    const CGFloat startFontSize = 100.0;
    return [WDUtils isIPhone5Screen] ? startFontSize * 1.15 : startFontSize * 0.9;
}

- (BOOL)isKeyboardActiveForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    BOOL firstResponder = [self isFirstResponder];
    return firstResponder;
}

- (UIColor *)selectedWordCursorColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    return self.cursorColor;
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
        
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        [cell.wordRepresentationView setNeedsDisplay];
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
            
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            [cell.wordRepresentationView setNeedsDisplay];
        }
    }
}

#pragma mark KeyboardNotification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    self.collectionView.scrollEnabled = NO;

    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
    [self fadeInDecoratorTextOnCell:cell withInfiniteDuration:YES];
    
    NSNumber *keyboardAnimationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:keyboardAnimationDuration.floatValue animations:^{
        cell.wordRepresentationView.center = CGPointMake(cell.wordRepresentationView.center.x, cell.wordRepresentationView.center.y - 0.30 * cell.wordRepresentationView.bounds.size.height);
        cell.dateContainerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        cell.wordRepresentationView.keyboardMode = YES;
        [cell.wordRepresentationView setNeedsDisplay];
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
    
    NSNumber *keyboardAnimationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:keyboardAnimationDuration.floatValue animations:^{
        cell.wordRepresentationView.center = CGPointMake(cell.wordRepresentationView.center.x, cell.wordRepresentationView.center.y + 0.30 * cell.wordRepresentationView.bounds.size.height);
        cell.dateContainerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        cell.wordRepresentationView.keyboardMode = NO;
        [cell.wordRepresentationView setNeedsDisplay];
    }];
    
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
    [self fadeInDecoratorTextOnCell:cell withInfiniteDuration:NO];
    
    self.collectionView.scrollEnabled = YES;
}

@end
