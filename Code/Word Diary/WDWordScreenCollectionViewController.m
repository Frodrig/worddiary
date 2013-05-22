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
#import "WDDashBoardViewController.h"
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat    MIN_HIDDEN_CELL_ALPHA_VALUE = 0.5;
static const NSUInteger MAX_WORD_LENGHT             = 20;

@interface WDWordScreenCollectionViewController ()

@property (nonatomic, strong) WDWordCharacterCounterView    *wordCharacterCounterView;
@property (nonatomic, strong) NSTimer                       *fadeDecoratorTextTimer;
@property (nonatomic, strong) UITapGestureRecognizer        *tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer        *dobleTapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGestureRecognizer;
//@property (nonatomic, strong) UILongPressGestureRecognizer  *longPressGestureRecognizer;
@property (nonatomic, strong) UIView                        *styleMenuView;
@property (nonatomic, strong) NSTimer                       *cursorColorTimer;
@property (nonatomic, strong) UIColor                       *cursorColor;
@property (nonatomic, strong) UIView                        *pannelBackgroundView;
@property (nonatomic, strong) NSIndexPath                   *indexPathForWordWhenAppear;
@property (nonatomic) BOOL                                  otherViewControllerInDismissMode;
@property (nonatomic) BOOL                                  editWordModeActive;
@property (nonatomic) BOOL                                  inPanModeForChangeBackgroundColor;
@property (nonatomic) BOOL                                  wordContentUpdatedInEditMode;
@property (nonatomic) BOOL                                  keyboardInTransitionMode;
@property (nonatomic, strong) UILabel                       *spaceTipInEditModeLabel;

- (NSUInteger)                       convertIndexPathToWordIndexContainer:(NSIndexPath *)indexPath;
- (NSIndexPath *)                    convertWordIndexContainerToIndexPath:(NSUInteger)index;

- (void)                             launchFadeDateAndDayTextTimer;
- (void)                             endFadeDateAndDayTextTimer;
- (void)                             fadeInDateAndDayTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
- (void)                             fadeDateAndDayTextTimerHandle:(NSTimer *)timer;

- (void)                             tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture;
- (void)                             panGestureRecognizerHandle:(UIPanGestureRecognizer *)gesture;
//- (void)                             longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)gesture;
- (void)                             dobleTapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture;

- (WDWordScreenCollectionViewCell *) findSelectedCell;
- (WDWord *)                         findSelectedWord;
- (WDWord *)                         findSelectedWordAtSectionIndex:(NSUInteger)sectionIndex;

- (NSIndexPath *)                    indexPathForLastWord;
- (NSIndexPath *)                    indexPathForWord:(WDWord *)word;

- (void)                             launchCursorColorTimer;
- (void)                             endCursorColorTimer;
- (void)                             cursorColorTimerHandle:(NSTimer *)timer;

- (void)                             styleButtonPressed:(UIButton *)button;

- (void)                             fixCellWithTagsStartingAt:(NSIndexPath *)startIndexPath;

- (void)                             pauseAll;
- (void)                             resumeAll;

- (void)                             updateDateInfoOfSensibleCells;

- (void)                             performScrollToIndexPathForWordWhenAppear;

- (void)                             keyboardWillShowNotification:(NSNotification *)notification;
- (void)                             keyboardWillHideNotification:(NSNotification *)notification;
- (void)                             keyboardDidHideNotification:(NSNotification *)notification;

- (void)                             applicationWillResignActive:(NSNotification *)notification;
- (void)                             applicationDidEnterBackground:(NSNotification *)notification;
- (void)                             applicationWillEnterForeground:(NSNotification *)notification;
- (void)                             applicationDidBecomeActive:(NSNotification *)notification;
- (void)                             applicationWillTerminate:(NSNotification *)notification;

- (void)                             significatTimeChange:(NSNotification *)notification;

- (void)                             showSpaceTip;
- (void)                             hideSpaceTip;
- (void)                             inmediateHideSpaceTipAfterInsertText;

@end

@implementation WDWordScreenCollectionViewController

#pragma mark - Synthesize

@synthesize wordCharacterCounterView           = wordCharacterCounterView_;
@synthesize fadeDecoratorTextTimer             = fadeDecoratorTextTimer_;
@synthesize tapGestureRecognizer               = tapGestureRecognizer_;
@synthesize dobleTapGestureRecognizer          = dobleTapGestureRecognizer_;
@synthesize panGestureRecognizer               = panGestureRecognizer_;
@synthesize cursorColorTimer                   = cursorColorTimer_;
@synthesize cursorColor                        = cursorColor_;
@synthesize styleMenuView                      = styleMenuView_;
@synthesize pannelBackgroundView               = pannelBackgroundView_;
@synthesize indexPathForWordWhenAppear         = indexPathForWordWhenAppear_;
@synthesize otherViewControllerInDismissMode   = otherWordViewControllerInDismissMode_;
@synthesize editWordModeActive                 = editWordModeActive_;
@synthesize inPanModeForChangeBackgroundColor  = inPanModeForChangeBackgroundColor_;
@synthesize wordContentUpdatedInEditMode       = wordContentUpdatedInEditMode_;
@synthesize spaceTipInEditModeLabel            = spaceTipInEditModeLabel_;
@synthesize keyboardInTransitionMode           = keyboardInTransitionMode_;

#pragma mark - Properties

- (UILabel *)spaceTipInEditModeLabel
{
    if (nil == spaceTipInEditModeLabel_) {
        spaceTipInEditModeLabel_= [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, self.view.frame.size.width - 10.0, 44.0)];
        spaceTipInEditModeLabel_.attributedText = [[NSAttributedString alloc]
                                                   initWithString:NSLocalizedString(@"TAG_NOSPACE_TIP", @"")
                                                   attributes:@{
                                                   NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:17.0],
                                                   NSForegroundColorAttributeName: [[self findSelectedWord].palette makeWordColorObject],
                                                   NSKernAttributeName: @2.0F
                                                   }];
        spaceTipInEditModeLabel_.backgroundColor = [UIColor clearColor];
        spaceTipInEditModeLabel_.numberOfLines = 2.0;
        spaceTipInEditModeLabel_.textAlignment = NSTextAlignmentCenter;
        spaceTipInEditModeLabel_.alpha = 0.0;
    }
    
    return spaceTipInEditModeLabel_;
}

- (UIView *)pannelBackgroundView {
    if (nil == pannelBackgroundView_) {
        pannelBackgroundView_ = [[UIView alloc] initWithFrame:self.view.frame];
        pannelBackgroundView_.backgroundColor = [UIColor blackColor];
    }
    return pannelBackgroundView_;
}

#pragma mark - Init

- (id)init
{
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        // Teclado
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        // Siempe aparece por un presentViewController
        otherWordViewControllerInDismissMode_ = YES;
        wordContentUpdatedInEditMode_ = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significatTimeChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
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
    [self endCursorColorTimer];
    [self endFadeDateAndDayTextTimer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.

    // Gesture
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandle:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];

    self.dobleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dobleTapGestureRecognizerHandle:)];
    self.dobleTapGestureRecognizer.numberOfTapsRequired = 2;
    self.dobleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:self.dobleTapGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.dobleTapGestureRecognizer];

    // Collection
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"WDWordScreenCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"WordScreenCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // StyleMenu
    self.styleMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    NSArray *styles = [WDWordDiary sharedWordDiary].styles;
    
    const CGFloat areaPerButton = self.styleMenuView.bounds.size.width / styles.count;
    for (NSUInteger styleIt = 0; styleIt < styles.count; styleIt++) {
        WDStyle *style = [[WDWordDiary sharedWordDiary].styles objectAtIndex:styleIt];
        NSString *backgroundImageForIcon = [style.familyFont stringByAppendingString:@"_style_icon"];
        backgroundImageForIcon = [backgroundImageForIcon lowercaseString];
        
        UIButton *styleButtonIt = [UIButton buttonWithType:UIButtonTypeCustom];
        styleButtonIt.frame = CGRectMake(areaPerButton * styleIt, 0.0, areaPerButton, self.styleMenuView.bounds.size.height);
        [styleButtonIt setImage:[UIImage imageNamed:backgroundImageForIcon] forState:UIControlStateNormal];
        styleButtonIt.adjustsImageWhenHighlighted = NO;
        styleButtonIt.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        // Nota: Incremento en 1 en el tag debido a que no se permite guardar tags con valor 0
        styleButtonIt.tag = styleIt + 1;
        styleButtonIt.alpha = 0.0;
        [styleButtonIt addTarget:self action:@selector(styleButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self.styleMenuView addSubview:styleButtonIt];
    }
    
    // Counter
    self.wordCharacterCounterView = [[WDWordCharacterCounterView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 88.0) andDataSource:self];
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
       
    // Scroll a la ultima palabra
    [self performScrollToIndexPathForWordWhenAppear];

    // Timers
    [self launchFadeDateAndDayTextTimer];
    [self launchCursorColorTimer];
    
    // Transicion incial
    self.view.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Cell
    WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
    [actualCell resumeBackgroundColorAnimation];
    
    self.otherViewControllerInDismissMode = NO;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:1.0 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (void)showSpaceTip
{
    if (self.spaceTipInEditModeLabel.superview == nil) {
        [self.view addSubview:self.spaceTipInEditModeLabel];
        [UIView animateWithDuration: 0.45 animations:^{
            self.wordCharacterCounterView.alpha = 0.0;
            self.spaceTipInEditModeLabel.alpha = 1.0;
        } completion:^(BOOL finished){
            NSNumber *spaceTipShowed = [[NSUserDefaults standardUserDefaults] valueForKey:@"SPACE_TIP_SHOWED"];
            [self performSelector:@selector(hideSpaceTip) withObject:nil afterDelay:[spaceTipShowed boolValue] ? 1.0 : 4.0];
            if (![spaceTipShowed boolValue]) {
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SPACE_TIP_SHOWED"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
    }
}

- (void)hideSpaceTip
{
    if (self.spaceTipInEditModeLabel.superview) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:1.5 animations:^{
            self.wordCharacterCounterView.alpha = 1.0;
            self.spaceTipInEditModeLabel.alpha = 0.0;
        } completion:^(BOOL finished){
            [self.spaceTipInEditModeLabel removeFromSuperview];
            self.spaceTipInEditModeLabel = nil;
        }];
    }
}

- (void)inmediateHideSpaceTipAfterInsertText
{
    if ([self.spaceTipInEditModeLabel.layer animationKeys].count == 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSpaceTip) object:nil];
        [self hideSpaceTip];
    }
}

- (void)performScrollToIndexPathForWordWhenAppear
{
    [self.collectionView scrollToItemAtIndexPath:self.indexPathForWordWhenAppear == nil ? [self indexPathForLastWord] : self.indexPathForWordWhenAppear atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    self.indexPathForWordWhenAppear = nil;
}

- (void)updateDateInfoOfSensibleCells
{
    // Solo las celdas asociadas a hoy y ayer, cuando hay cambio de dia, se ven afectadas
    // Las celdas de ayer y hoy, de existir, seran la ultima y antepenultima
    [(WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.collectionView.numberOfSections - 2]] updateDateInfo];
    [(WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.collectionView.numberOfSections - 1]] updateDateInfo];
}

-(void)fixCellWithTagsStartingAt:(NSIndexPath *)startIndexPath
{
    NSIndexPath *indexPathIt = [startIndexPath copy];
    while (indexPathIt.section < self.collectionView.numberOfSections) {
        WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPathIt];
        if (cell.wordRepresentationView.tag != indexPathIt.section) {
            cell.wordRepresentationView.tag = indexPathIt.section;
            indexPathIt = [NSIndexPath indexPathForRow:indexPathIt.row inSection:indexPathIt.section + 1];
        } else {
            break;
        }
    }
}

- (void)styleButtonPressed:(UIButton *)button
{
    WDWord *word = [self findSelectedWord];
    WDStyle *newStyle = [[WDWordDiary sharedWordDiary].styles objectAtIndex:button.tag - 1];
    if (newStyle != word.style) {
        [UIView animateWithDuration:0.25 animations:^{
            button.alpha = 1.0;
            [self.styleMenuView viewWithTag:[[WDWordDiary sharedWordDiary] findIndexPositionForStyle:word.style] + 1].alpha = 0.5;
        }];
        word.style = newStyle;
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        [cell.wordRepresentationView setNeedsDisplay];
    }
}

- (void)fadeInDateAndDayTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
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

- (NSIndexPath *)convertWordIndexContainerToIndexPath:(NSUInteger)index
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

- (NSIndexPath *)indexPathForWord:(WDWord *)word
{
    NSUInteger indexOfWord = [[WDWordDiary sharedWordDiary].words indexOfObject:word];
    NSIndexPath *indexPathOfWord = [self convertWordIndexContainerToIndexPath:indexOfWord];
    
    return indexPathOfWord;
}

- (WDWordScreenCollectionViewCell *) findSelectedCell
{
    NSUInteger sectionIndex = (self.collectionView.contentOffset.x / self.collectionView.bounds.size.width) + 0.5;
    WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    
    return cell;
}

- (void)pauseAll
{
    if (!self.editWordModeActive) {
        [self endFadeDateAndDayTextTimer];
    }
    [self endCursorColorTimer];
    WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
    [actualCell pauseBackgroundColorAnimation];
}

- (void)resumeAll
{
    WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
    if (!self.editWordModeActive) {
        [actualCell fadeInDataAndDayTextInmediate];
        [self launchFadeDateAndDayTextTimer];
    }
    [self launchCursorColorTimer];
    [actualCell resumeBackgroundColorAnimation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.width > 0) {        
        [self endFadeDateAndDayTextTimer];
        WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
        [actualCell fadeInDataAndDayTextInmediate];
        
        const CGFloat cellIndexWithOffset = scrollView.contentOffset.x / (scrollView.contentSize.width / [WDWordDiary sharedWordDiary].words.count);
        const CGFloat indexRight = ceilf(cellIndexWithOffset);
        const CGFloat indexLeft = floorf(cellIndexWithOffset);
        if (indexLeft != indexRight) {
            WDWordScreenCollectionViewCell *cellAtLeft = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0.0 inSection:indexLeft]];
            cellAtLeft.alpha = MAX(MIN_HIDDEN_CELL_ALPHA_VALUE, 1 - (cellIndexWithOffset - indexLeft));
            WDWordScreenCollectionViewCell *cellAtRight = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0.0 inSection:indexRight]];
            cellAtRight.alpha = MAX(MIN_HIDDEN_CELL_ALPHA_VALUE, 1 - (indexRight - cellIndexWithOffset));
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
    actualCell.alpha = 1.0;
    
    [self launchFadeDateAndDayTextTimer];
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Nota IMPORTANTE: En el tag del wordRepresentation guardamos la seccion del indexPath
    WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WordScreenCell" forIndexPath:indexPath];
    cell.wordRepresentationView.dataSource = self;
    cell.wordRepresentationView.delegate = self;
    cell.wordRepresentationView.clearsContextBeforeDrawing = YES;
    cell.wordRepresentationView.tag = indexPath.section;
    cell.alpha = MIN_HIDDEN_CELL_ALPHA_VALUE;
    
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
    self.fadeDecoratorTextTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(fadeDateAndDayTextTimerHandle:) userInfo:nil repeats:NO];
}

- (void) endFadeDateAndDayTextTimer
{
    [self.fadeDecoratorTextTimer invalidate];
    self.fadeDecoratorTextTimer = nil;
}

- (void)fadeDateAndDayTextTimerHandle:(NSTimer *)timer
{
    if (self.collectionView.visibleCells.count > 0) {
        WDWordScreenCollectionViewCell * visibleCell = [self.collectionView.visibleCells objectAtIndex:0];
        [visibleCell fadeOutDataAndDayText];
        self.fadeDecoratorTextTimer = nil;
    }
}

- (void)launchCursorColorTimer
{
    [self.cursorColorTimer invalidate];
    self.cursorColorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(cursorColorTimerHandle:) userInfo:nil repeats:YES];
}

- (void)endCursorColorTimer
{
    [self.cursorColorTimer invalidate];
    self.cursorColorTimer = nil;
}

- (void)cursorColorTimerHandle:(NSTimer *)timer
{
    BOOL setOriginalCursorColor = YES;
    if ([self findSelectedWord].word.length == 0 || [self isFirstResponder]) {
        WDWord *selectedWord = [self findSelectedWord];
        if  (nil == self.cursorColor) {
            CGFloat colorComponents[] = {0.0, 0.0, 0.0, 0.0};
            self.cursorColor = [selectedWord.palette makeWordColorObject];
            [self.cursorColor getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
            self.cursorColor = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:0.3];
            setOriginalCursorColor = NO;
        }
        
        WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
        [actualCell.wordRepresentationView setNeedsDisplay];
    }
    
    // Si no hay que mostrar cursor SIEMPRE lo setearemos al valor solido original
    if (setOriginalCursorColor) {
        CGFloat colorComponents[] = {0.0, 0.0, 0.0, 0.0};
        [self.cursorColor getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
        colorComponents[3] = colorComponents[3] < 1.0 ? 1.0 : 0.3;
        self.cursorColor = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:colorComponents[3]];
    }
}

#pragma mark - Gesture Recognizer

- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture
{
    if (gesture == self.tapGestureRecognizer) {
        if (!self.editWordModeActive) {
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
                
                self.editWordModeActive = YES;
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordWillEnterInEditMode" object:nil]];
            } else {
                [self fadeInDateAndDayTextOnCell:cell withInfiniteDuration:NO];
            }
        }
    }
}

- (void)panGestureRecognizerHandle:(UIPanGestureRecognizer *)gesture
{
    if (!self.isFirstResponder) {
        BOOL checkForUpdateGesture = NO;
        if (gesture == self.panGestureRecognizer) {
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan: {
                    checkForUpdateGesture = YES;
                } break;
                case UIGestureRecognizerStateChanged: {
                    checkForUpdateGesture = YES;
                } break;
                                       
                case UIGestureRecognizerStateEnded: {
                    checkForUpdateGesture = NO;
                    [[WDWordDiary sharedWordDiary] saveAll];
                } break;
                    
                default:
                    break;
            }
        }
        
        WDPalette *newPalette = nil;
        if (checkForUpdateGesture) {
            CGPoint translation = [gesture translationInView:self.view];
            if (![WDUtils is:translation.y equalsTo:0.0]) {
                if (abs(translation.y) > abs(translation.x)) {
                    const CGFloat minimumDistance = 15.0;
                    WDWord *word = [self findSelectedWord];
                    if (translation.y < 0.0 && abs(translation.y) > minimumDistance) {
                        newPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:word.palette];
                    } else if (translation.y > 0.0 && translation.y > minimumDistance) {
                        newPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:word.palette];
                    }
                    if (newPalette != nil && !self.inPanModeForChangeBackgroundColor) {
                    }
                } else {
                    [gesture setTranslation:CGPointZero inView:self.view];
                }
                
            }
        }
        
        const BOOL fadeOutText = gesture.state == UIGestureRecognizerStateBegan;
        const BOOL fadeInText = gesture.state == UIGestureRecognizerStateEnded && self.inPanModeForChangeBackgroundColor;
        
        if (fadeInText || fadeOutText) {
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            
            if (fadeOutText) {
                [self endFadeDateAndDayTextTimer];
                [cell pauseBackgroundColorAnimation];
                self.inPanModeForChangeBackgroundColor = YES;
                self.collectionView.scrollEnabled = NO;
            } else if (fadeInText) {
                self.inPanModeForChangeBackgroundColor = NO;
            }
            
            const CGFloat alphaValue = fadeInText ? 1.0 : 0.0;
            const CGFloat animationTime = fadeInText ? 0.35 : 0.25;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:animationTime animations:^{
                cell.dateContainerView.alpha = alphaValue;
                cell.wordRepresentationContainerView.alpha = alphaValue;
                cell.dayDiaryContainerView.alpha = alphaValue;
            } completion:^(BOOL finished) {
                if (fadeInText) {
                    [self launchFadeDateAndDayTextTimer];
                    [cell resumeBackgroundColorAnimation];
                    self.collectionView.scrollEnabled = YES;
                }
            }];
        }
        
        if (newPalette) {
            WDWord *word = [self findSelectedWord];
            word.palette = newPalette;
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            [cell refreshBackgroundColorOfWord:word];
            [gesture setTranslation:CGPointZero inView:self.view];
            //NSLog(@"index palette %d", [[WDWordDiary sharedWordDiary].palettes indexOfObject:newPalette]);
        }
    }

}

- (void)dobleTapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture
{
    if (!self.editWordModeActive) {
        WDDashBoardViewController *dashBoardViewController = [[WDDashBoardViewController alloc] initWithNibName:nil bundle:nil];
        dashBoardViewController.delegate = self;
        dashBoardViewController.dataSource = self;
        [self presentViewController:dashBoardViewController animated:YES completion:^{
            [self pauseAll];
            [self fadeInDateAndDayTextOnCell:[self findSelectedCell] withInfiniteDuration:YES];
        }];
    }
}

#pragma mark - WDWordRepresentationViewDelegate

- (void)wordContentUpdatedFlagCheckedByWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    self.wordContentUpdatedInEditMode = NO;
}

#pragma mark - WDWordRepresentatonViewDataSource

- (BOOL)isWordContentUpdatedForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    return self.wordContentUpdatedInEditMode;
}

- (NSString *)selectedWordTextForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:wordRepresentation.tag];
    return selectedWord.word;
}

- (UIColor *)selectedWordColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *word = [self findSelectedWord];
    return [word.palette makeWordColorObject];
}

- (NSString *) selectedWordTextFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:wordRepresentation.tag];
    return selectedWord.style.familyFont;
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

#pragma mark - UIView sobrecarga

- (BOOL)canResignFirstResponder
{
    return !self.keyboardInTransitionMode;
}

- (BOOL)canBecomeFirstResponder
{
    // Solo en caso de que no se este volviendo de la pantalla de añadir fecha
    return !self.otherViewControllerInDismissMode;
}

#pragma mark - UIKeyInput

- (void)deleteBackward
{
    WDWord *selectedWord = [self findSelectedWord];
    if (selectedWord.word.length > 0) {
        self.wordContentUpdatedInEditMode = YES;
        selectedWord.word = [selectedWord.word substringWithRange:NSMakeRange(0, selectedWord.word.length - 1)];
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        [cell.wordRepresentationView setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordInEditModeRemoveLastCharacter" object:nil]];
        [self inmediateHideSpaceTipAfterInsertText];
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
        if (selectedWord.word.length < MAX_WORD_LENGHT) {
            self.wordContentUpdatedInEditMode = YES;
            selectedWord.word = [selectedWord.word stringByAppendingString:text];
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            [cell.wordRepresentationView setNeedsDisplay];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordInEditModeAddedNewCharacter" object:nil]];
            [self inmediateHideSpaceTipAfterInsertText];
        }
    } else {
        [self showSpaceTip];
    }
}

- (UITextAutocapitalizationType)autocapitalizationType
{
    return UITextAutocapitalizationTypeWords;
}

- (UITextSpellCheckingType)spellCheckingType
{
    return UITextSpellCheckingTypeNo;
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeDefault;
}

- (UIReturnKeyType)returnKeyType
{
    return UIReturnKeyDefault;
}

- (UIKeyboardAppearance)keyboardAppearance
{
    return UIKeyboardAppearanceDefault;
}

- (UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeYes;
}

- (BOOL)enablesReturnKeyAutomatically
{
    return NO;
}

- (BOOL)secureTextEntry
{
    return NO;
}

#pragma mark KeyboardNotification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    self.keyboardInTransitionMode = YES;
    
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
    self.styleMenuView.frame = CGRectMake(0.0,
                                          endFrameKeyboard.origin.y - self.styleMenuView.bounds.size.height,
                                          self.styleMenuView.bounds.size.width,
                                          self.styleMenuView.bounds.size.height);
    [self.view addSubview:self.styleMenuView];
    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; styleIt++) {
        [UIView animateWithDuration:0.25 delay:0.1 + 0.04 * styleIt options:UIViewAnimationOptionCurveLinear animations:^{
            [self.styleMenuView viewWithTag:styleIt + 1].alpha = 1.0;
        } completion:^(BOOL finished) {
            if (styleIt == [WDWordDiary sharedWordDiary].styles.count - 1) {
                WDWord *selectedWord = [self findSelectedWord];
                NSUInteger selectedIndexOfWordStyle = [[WDWordDiary sharedWordDiary] findIndexPositionForStyle:selectedWord.style];
                for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; styleIt++) {
                    if (styleIt != selectedIndexOfWordStyle) {
                        [UIView animateWithDuration:0.55 animations:^{
                            [self.styleMenuView viewWithTag:styleIt + 1].alpha = 0.55;
                        } completion:^(BOOL finished) {
                            if (styleIt == [WDWordDiary sharedWordDiary].styles.count - 1) {
                                self.keyboardInTransitionMode = NO;
                            }
                        }];
                    }
                }
            }
        }];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    self.keyboardInTransitionMode = YES;
    
    [[WDWordDiary sharedWordDiary] saveAll];
    
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
                // Wordrepresentation & Wordcharacter & Space Tip
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSpaceTip) object:nil];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView animateWithDuration:0.5 animations:^{
                    self.spaceTipInEditModeLabel.alpha = 0.0;
                    cell.wordRepresentationContainerView.center = CGPointMake(cell.wordRepresentationContainerView.center.x, cell.wordRepresentationContainerView.center.y + 0.30 * cell.wordRepresentationContainerView.bounds.size.height);
                    self.wordCharacterCounterView.frame = CGRectMake(self.wordCharacterCounterView.frame.origin.x, -self.wordCharacterCounterView.bounds.size.height, self.wordCharacterCounterView.bounds.size.width, self.wordCharacterCounterView.bounds.size.height);
                } completion:^(BOOL finished) {
                    [self.spaceTipInEditModeLabel removeFromSuperview];
                    self.spaceTipInEditModeLabel = nil;
                    self.wordCharacterCounterView.alpha = 1.0;
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
    self.editWordModeActive = NO;
    self.keyboardInTransitionMode = NO;
}

#pragma mark - Application Notifications

- (void)applicationWillResignActive:(NSNotification *)notification
{
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self pauseAll];
    
    if (self.editWordModeActive) {
        [self resignFirstResponder];
    }
    
    if (nil == self.presentedViewController) {
        WDWord *actualSelectedWord = [self findSelectedWord];
        if (actualSelectedWord.word.length > 0) {
            self.indexPathForWordWhenAppear = [self indexPathForWord:actualSelectedWord];
        }
    }
    
    NSDateComponents *lastDayDateComponents = [[WDWordDiary sharedWordDiary] findLastCreatedWord].dateComponents;
    [[NSUserDefaults standardUserDefaults] setInteger:lastDayDateComponents.year forKey:@"LAST_WORD_YEAR_BEFORE_ENTER_BACKGROUND"];
    [[NSUserDefaults standardUserDefaults] setInteger:lastDayDateComponents.month forKey:@"LAST_WORD_MONTH_BEFORE_ENTER_BACKGROUND"];
    [[NSUserDefaults standardUserDefaults] setInteger:lastDayDateComponents.day forKey:@"LAST_WORD_DAY_BEFORE_ENTER_BACKGROUND"];
    
    self.view.alpha = 0.0;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self resumeAll];
    [self.collectionView reloadData];
    /*
    NSInteger lastWordYearBeforeEnterBackground = [[NSUserDefaults standardUserDefaults] integerForKey:@"LAST_WORD_YEAR_BEFORE_ENTER_BACKGROUND"];
    NSInteger lastWordMontBeforeEnterBackground = [[NSUserDefaults standardUserDefaults] integerForKey:@"LAST_WORD_MONTH_BEFORE_ENTER_BACKGROUND"];
    NSInteger lastWordDayBeforeEnterBackground = [[NSUserDefaults standardUserDefaults] integerForKey:@"LAST_WORD_DAY_BEFORE_ENTER_BACKGROUND"];
    WDWord *newPosibleLastWord = [[WDWordDiary sharedWordDiary] findLastCreatedWord];
    
    BOOL goToLastPositionBecouseOneOrMoreDaysHavePassed = lastWordYearBeforeEnterBackground != newPosibleLastWord.dateComponents.year;
    if (!goToLastPositionBecouseOneOrMoreDaysHavePassed) {
        goToLastPositionBecouseOneOrMoreDaysHavePassed = lastWordMontBeforeEnterBackground != newPosibleLastWord.dateComponents.month;
    }
    if (!goToLastPositionBecouseOneOrMoreDaysHavePassed) {
        goToLastPositionBecouseOneOrMoreDaysHavePassed = lastWordDayBeforeEnterBackground != newPosibleLastWord.dateComponents.day;
    }
    
    if (goToLastPositionBecouseOneOrMoreDaysHavePassed) {
        self.indexPathForWordWhenAppear = nil;
    }
    */
    self.indexPathForWordWhenAppear = nil;
    [self performScrollToIndexPathForWordWhenAppear];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:1.0 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self resumeAll];
    
    [self updateDateInfoOfSensibleCells];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
}

#pragma mark - SignificatTimeChangeNotification

- (void)significatTimeChange:(NSNotification *)notification
{
    [self updateDateInfoOfSensibleCells];
}

#pragma mark - WDWordCharacterCounterViewDataSource

- (NSUInteger)numberOfFreeCharactersOfEditWordForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    WDWord *selectedWord = [self findSelectedWord];
    return MAX_WORD_LENGHT - selectedWord.word.length;
}

- (UIColor *)colorForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    WDWord *selectedWord = [self findSelectedWord];
    return [selectedWord.palette makeWordColorObject];
}

#pragma mark - WDWordCharacterCounterViewDelegate

- (void)redrawNeededForWordForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    [self.wordCharacterCounterView setNeedsDisplay];
}

#pragma mark - WDDashBoardViewControllerDelegate

- (void)dashBoardViewController:(WDDashBoardViewController *)dashBoardViewController createdNewWord:(WDWord *)word;
{
    [self.collectionView reloadData];
}

- (void)dashBoardViewController:(WDDashBoardViewController *)dashBoardViewController selectRemoveWord:(WDWord *)word
{
    NSIndexPath *selectedWordIndexPath = [self indexPathForWord:word];
    [[WDWordDiary sharedWordDiary] removeWord:word];
    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:selectedWordIndexPath.section]];
    [self fixCellWithTagsStartingAt:selectedWordIndexPath];
}

- (void)dashBoardViewController:(WDDashBoardViewController *)dashBoardViewController willDismissWithSelectedWord:(WDWord *)word
{
    self.indexPathForWordWhenAppear = [self indexPathForWord:word];
    self.otherViewControllerInDismissMode = YES;
}

- (void)dashBoardViewControllerDidDismiss:(WDDashBoardViewController *)dashBoardViewController
{
    self.otherViewControllerInDismissMode = NO;
}

- (void)removeSectionsWithEmptyWordsFromDashBoardViewController:(WDDashBoardViewController *)dashBoardViewController
{
    [self.collectionView reloadData];
}

- (void)backgroundAnimationGradientSettingsUpdateFromDashBoardViewController:(WDDashBoardViewController *)dashBoardViewController;
{
    [self.collectionView reloadData];
}

#pragma mark - WDDashBoardViewControllerDataSource

- (NSDateComponents *)dateComponentsFromWordDaySelectedForDashBoardViewController:(WDDashBoardViewController *)dashBoardViewController
{
    WDWord *selectedWord = [self findSelectedWord];
    NSDateComponents *dateComponents = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit fromDate:[NSDate dateWithTimeIntervalSince1970:selectedWord.timeInterval]];

    return dateComponents;
}

- (WDWord *)selectedWordForDashBoardViewController:(WDDashBoardViewController *)dashBoardViewController
{
    return [self findSelectedWord];
}

@end
    