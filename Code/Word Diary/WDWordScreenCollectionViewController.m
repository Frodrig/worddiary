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
#import "WDWordCharacterCounterView.h"
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger MAX_WORD_LENGHT = 20;

@interface WDWordScreenCollectionViewController ()

@property (nonatomic, strong) WDWordCharacterCounterView *wordCharacterCounterView;
@property (nonatomic, strong) NSTimer                    *fadeDecoratorTextTimer;
@property (nonatomic, strong) UITapGestureRecognizer     *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer     *panGestureRecognizer;
@property (nonatomic, strong) UIView                     *styleMenuView;
@property (nonatomic, strong) NSTimer                    *cursorColorTimer;
@property (nonatomic, strong) UIColor                    *cursorColor;

- (NSUInteger)                       convertIndexPathToWordIndexContainer:(NSIndexPath *)indexPath;
- (NSIndexPath *)                    converWordIndexContainerToIndexPath:(NSUInteger)index;

- (void)                             launchFadeDateAndDayTextTimer;
- (void)                             endFadeDateAndDayTextTimer;
- (void)                             fadeInDateAndDayTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
- (void)                             fadeDateAndDayTextTimerHandle:(NSTimer *)timer;

- (void)                             tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture;
- (void)                             panGestureRecognizerHandle:(UIPanGestureRecognizer *)gesture;

- (WDWordScreenCollectionViewCell *) findSelectedCell;
- (WDWord *)                         findSelectedWord;
- (WDWord *)                         findSelectedWordAtSectionIndex:(NSUInteger)sectionIndex;
- (NSIndexPath *)                    indexPathForLastWord;

- (void)                             launchCursorColorTimer;
- (void)                             endCursorColorTimer;
- (void)                             cursorColorTimerHandle:(NSTimer *)timer;

- (void)                             styleButtonPressed:(UIButton *)button;

@end

@implementation WDWordScreenCollectionViewController

#pragma mark - Synthesize

@synthesize wordCharacterCounterView = wordCharacterCounterView_;
@synthesize fadeDecoratorTextTimer   = fadeDecoratorTextTimer_;
@synthesize tapGestureRecognizer     = tapGestureRecognizer_;
@synthesize panGestureRecognizer     = panGestureRecognizer_;
@synthesize cursorColorTimer         = cursorColorTimer_;
@synthesize cursorColor              = cursorColor_;
@synthesize styleMenuView            = styleMenuView_;

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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.

    // Gestures
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandle:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.panGestureRecognizer];
    
    // Collection
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"WDWordScreenCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"WordScreenCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // Counter
    self.wordCharacterCounterView = [[WDWordCharacterCounterView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 88.0)];
    self.wordCharacterCounterView.dataSource = self;
    self.wordCharacterCounterView.delegate = self;
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
    
    // StyleMenu
    self.styleMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 54.0)];
    NSArray *styles = [WDWordDiary sharedWordDiary].styles;
    const CGFloat areaPerButton = self.styleMenuView.bounds.size.width / styles.count;
    for (NSUInteger styleIt = 0; styleIt < styles.count; styleIt++) {
        UIButton *styleButtonIt = [UIButton buttonWithType:UIButtonTypeCustom];
        styleButtonIt.frame = CGRectMake(areaPerButton * styleIt, 0.0, areaPerButton, self.styleMenuView.bounds.size.height);
        [styleButtonIt setTitle:[NSString stringWithFormat:@"%d", styleIt] forState:UIControlStateNormal];
        styleButtonIt.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.2];
        styleButtonIt.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        // Nota: Incremento en 1 en el tag debido a que no se permite guardar tags con valor 0
        styleButtonIt.tag = styleIt + 1;
        styleButtonIt.alpha = 0.0;
        [styleButtonIt addTarget:self action:@selector(styleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.styleMenuView addSubview:styleButtonIt];
    }
    
    // Scroll a la ultima palabra
    [self.collectionView scrollToItemAtIndexPath:[self indexPathForLastWord] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    // Timers
    [self launchFadeDateAndDayTextTimer];
    [self launchCursorColorTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (void)styleButtonPressed:(UIButton *)button
{
    WDWord *word = [self findSelectedWord];
    WDStyle *newStyle = [[WDWordDiary sharedWordDiary].styles objectAtIndex:button.tag - 1];
    if (newStyle != word.style) {
        word.style = newStyle;
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        [cell.wordRepresentationView setNeedsDisplay];
    }
}

- (void) fadeInDateAndDayTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
{
    if (nil == self.fadeDecoratorTextTimer) {
        [cell fadeInDataAndDayText];
    }
    
    if (infiniteDuration) {
        [self.fadeDecoratorTextTimer invalidate];
        self.fadeDecoratorTextTimer = nil;
    } else {
        [self launchFadeDateAndDayTextTimer];
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

- (void)launchFadeDateAndDayTextTimer
{
    [self.fadeDecoratorTextTimer invalidate];
    self.fadeDecoratorTextTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(fadeDateAndDayTextTimerHandle:) userInfo:nil repeats:NO];
}

- (void) endFadeDateAndDayTextTimer
{
    [self.fadeDecoratorTextTimer invalidate];
    self.fadeDecoratorTextTimer = nil;
}

- (void)fadeDateAndDayTextTimerHandle:(NSTimer *)timer
{
    WDWordScreenCollectionViewCell * visibleCell = [self.collectionView.visibleCells objectAtIndex:0];
    [visibleCell fadeOutDataAndDayText];
    
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
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            
            // Scroll
            self.collectionView.scrollEnabled = NO;
            
            // Date and Day
            [self endFadeDateAndDayTextTimer];
            
            // Wordcharacter counter
            self.wordCharacterCounterView.frame = CGRectMake((self.view.bounds.size.width - self.wordCharacterCounterView.bounds.size.width) / 2, -self.wordCharacterCounterView.bounds.size.height, self.wordCharacterCounterView.bounds.size.width, self.wordCharacterCounterView.bounds.size.height);
            [self.view addSubview:self.wordCharacterCounterView];
            
            // Wordrepresentation - WordCharacterCounter animation
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:0.5 animations:^{
                cell.wordRepresentationContainerView.center = CGPointMake(cell.wordRepresentationContainerView.center.x, cell.wordRepresentationContainerView.center.y - 0.30 * cell.wordRepresentationContainerView.bounds.size.height);
                cell.dateContainerView.alpha = 0.0;
                cell.dayDiaryContainerView.alpha = 0.0;
                self.wordCharacterCounterView.frame = CGRectMake(self.wordCharacterCounterView.frame.origin.x, 0.0, self.wordCharacterCounterView.bounds.size.width, self.wordCharacterCounterView.bounds.size.height);
            } completion:^(BOOL finished) {
                [self becomeFirstResponder];
            }];
            
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordWillEnterInEditMode" object:nil]];
        } else {
            [self fadeInDateAndDayTextOnCell:cell withInfiniteDuration:NO];
        }
    }
}

- (void)panGestureRecognizerHandle:(UIPanGestureRecognizer *)gesture
{
    if (!self.isFirstResponder) {
        WDPalette *nextPalette = nil;
        
        if (gesture == self.panGestureRecognizer) {
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                case UIGestureRecognizerStateChanged: {
                    CGPoint translation = [gesture translationInView:self.view];
                    if (![WDUtils is:translation.y equalsTo:0.0]) {
                        const CGFloat minimumDistance = 25.0;
                        WDWord *word = [self findSelectedWord];
                        if (translation.y < 0.0 && abs(translation.y) > minimumDistance) {
                            nextPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:word.palette];
                        } else if (translation.y > 0.0 && translation.y > minimumDistance) {
                            nextPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:word.palette];
                        }
                    }
                    
                } break;
                    
                default:
                    break;
            }
        }
        
        if (nextPalette) {
            WDWord *word = [self findSelectedWord];
            word.palette = nextPalette;
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            cell.contentView.backgroundColor = [UIColor colorWithHexadecimalValue:nextPalette.lightBackground withAlphaComponent:NO skipInitialCharacter:NO];
            [gesture setTranslation:CGPointZero inView:self.view];
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

- (void) deleteBackward
{
    WDWord *selectedWord = [self findSelectedWord];
    if (selectedWord.word.length > 0) {
        selectedWord.word = [selectedWord.word substringWithRange:NSMakeRange(0, selectedWord.word.length - 1)];
        
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        [cell.wordRepresentationView setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordInEditModeRemoveLastCharacter" object:nil]];
    }
}

- (BOOL) hasText
{
    WDWord *selectedWord = [self findSelectedWord];
    return selectedWord.word.length > 0;
}

- (void) insertText:(NSString *)text
{
    WDWord *selectedWord = [self findSelectedWord];
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]].length == 0) {
        [self resignFirstResponder];
    } else if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        if (selectedWord.word.length < MAX_WORD_LENGHT) {
            selectedWord.word = [selectedWord.word stringByAppendingString:text];
            
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            [cell.wordRepresentationView setNeedsDisplay];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordInEditModeAddedNewCharacter" object:nil]];
        }
    }
}

#pragma mark KeyboardNotification

- (void) keyboardWillShowNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
 
    // Efecto fantasma
    [cell.wordRepresentationView generateGosthWordRepresentation];
    cell.wordRepresentationView.keyboardMode = YES;
    cell.wordRepresentationView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        cell.wordRepresentationView.alpha = 1.0;
    }];
    [cell.wordRepresentationView setNeedsDisplay];
    
    // Style Menu
    CGRect endFrameKeyboard = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.styleMenuView.frame = CGRectMake(0.0, endFrameKeyboard.origin.y - self.styleMenuView.bounds.size.height, self.styleMenuView.bounds.size.width, self.styleMenuView.bounds.size.height);
    [self.view addSubview:self.styleMenuView];
    NSNumber *keybAnimationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; styleIt++) {
        CGFloat animationDuration = (keybAnimationDuration.floatValue + styleIt) * 0.25;
        [UIView animateWithDuration:animationDuration animations:^{
            [self.styleMenuView viewWithTag:styleIt + 1].alpha = 1.0;
        }];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
    
    // Wordrepresentation
    [cell.wordRepresentationView generateGosthWordRepresentation];
    cell.wordRepresentationView.keyboardMode = NO;
    cell.wordRepresentationView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        cell.wordRepresentationView.alpha = 1.0;
    }];
    [cell.wordRepresentationView setNeedsDisplay];
    
    // Stylemenu
    NSNumber *keybAnimationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; styleIt++) {
        CGFloat animationDuration = (keybAnimationDuration.floatValue + styleIt) * 0.25;
        NSUInteger buttonIndexToChange = [WDWordDiary sharedWordDiary].styles.count - styleIt - 1;
        if (buttonIndexToChange == 0) {
            [UIView animateWithDuration:animationDuration animations:^{
                [self.styleMenuView viewWithTag:buttonIndexToChange + 1].alpha = 0.0;
            } completion:^(BOOL finished) {
                if (!self.isFirstResponder) {
                    [self.styleMenuView removeFromSuperview];
                }
                // Wordrepresentation & Wordcharacter
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView animateWithDuration:0.5 animations:^{
                    cell.wordRepresentationContainerView.center = CGPointMake(cell.wordRepresentationContainerView.center.x, cell.wordRepresentationContainerView.center.y + 0.30 * cell.wordRepresentationContainerView.bounds.size.height);
                    self.wordCharacterCounterView.frame = CGRectMake(self.wordCharacterCounterView.frame.origin.x, -self.wordCharacterCounterView.bounds.size.height, self.wordCharacterCounterView.bounds.size.width, self.wordCharacterCounterView.bounds.size.height);
                } completion:^(BOOL finished) {
                    [self fadeInDateAndDayTextOnCell:cell withInfiniteDuration:NO];
                    [self.wordCharacterCounterView removeFromSuperview];
                }];
            }];
        } else {
            [UIView animateWithDuration:animationDuration animations:^{
                [self.styleMenuView viewWithTag:buttonIndexToChange + 1].alpha = 0.0;
            }];
        }
    }
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    self.collectionView.scrollEnabled = YES;
}

#pragma mark - WDWordCharacterCounterViewDataSource

- (NSUInteger) numberOfFreeCharactersOfEditWordForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    WDWord *selectedWord = [self findSelectedWord];
    return MAX_WORD_LENGHT - selectedWord.word.length;
}

#pragma mark - WDWordCharacterCounterViewDelegate

- (void) redrawNeededForWordForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    [self.wordCharacterCounterView setNeedsDisplay];
}

@end
