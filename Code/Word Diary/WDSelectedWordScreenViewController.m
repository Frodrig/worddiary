//
//  WDSelectedWordScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordScreenViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WDSelectedWordEditMenuViewController.h"
#import "WDWord.h"
#import "WDStyle.h"
#import "WDWordDiary.h"
#import "WDUtils.h"
#import "WDWordRepresentationView.h"
#import "UIView+UIViewNibLoad.h"
#import "WDDayChecker.h"
#import "WDGradientBackground.h"
#import "WDAuxiliaryScreenViewController.h"
#import "WDEmotion.h"
#import "WDPalette.h"
#import "UIColor+hexColorCreation.h"

const static CGFloat ANIMATION_TIME_CURSOR = 0.75;
const static CGFloat ANIMATION_TIME_CURSORMODE = 0.5;
const static CGFloat ANIMATION_TIME_WITHOUTCURSORMODE = 1.15;

@interface WDSelectedWordScreenViewController ()

@property (nonatomic, weak)          WDWord                               *selectedWord;
@property (nonatomic, strong)        WDSelectedWordEditMenuViewController *editMenuViewController;
@property (weak, nonatomic) IBOutlet UILabel                              *yearDateTopInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel                              *dayMonthDateTopInfoLabel;
@property (weak, nonatomic) IBOutlet UIView                               *yearDateAndDayMonthContainerView;
@property (nonatomic, strong)        UITapGestureRecognizer               *doubleTapGestureRecognizer;
@property (nonatomic, strong)        UITapGestureRecognizer               *tapKeyboardGesture;
@property (nonatomic, strong)        UITapGestureRecognizer               *tapEmotionGesture;
@property (nonatomic, strong)        UISwipeGestureRecognizer             *leftSwipeGesture;
@property (nonatomic, strong)        UISwipeGestureRecognizer             *rightSwipeGesture;
@property (nonatomic, strong)        UILongPressGestureRecognizer         *longPressGestureRecognizer;
@property (nonatomic, strong)        NSTimer                              *longPressGestureRecognizerTimer;
@property (nonatomic)                CGPoint                              originalCenterPositionYearDateAndMonthContainerView;
@property (nonatomic)                CGPoint                              originalCenterPositionOfSelectedWord;
@property (nonatomic)                CGPoint                              originalCenterPositionOfEmotionLabel;
@property (nonatomic, strong)        NSTimer                              *animateStartEndPointOfGradientTimer;
@property (nonatomic)                BOOL                                 keyboardActive;
@property (nonatomic, strong)        WDWordRepresentationView             *wordDiaryRepresentation;
@property (nonatomic, weak) IBOutlet UILabel                              *dayDiaryLabel;
@property (nonatomic, weak) IBOutlet UILabel                              *dayOfTheWeekLabel;
@property (weak, nonatomic) IBOutlet UIView                               *dayDiaryAndDayOfWeekContainerView;
@property (weak, nonatomic) IBOutlet UIView                               *emotionLabelContainerView;
@property (nonatomic, strong)        UILabel                              *emotionLabel;
@property (nonatomic, strong)        UIView                               *styleMenuView;
@property (nonatomic, strong)        UIView                               *emotionMenuView;
@property (nonatomic, strong)        NSTimer                              *cursorUpdateTimer;
@property (nonatomic, strong)        WDDayChecker                         *dayChecker;
@property (nonatomic)                BOOL                                 dayChangePendingToResolve;
@property (nonatomic, strong)        NSTimer                              *backgroundTimer;
@property (nonatomic, strong)        NSMutableArray                       *pendingBackgroundChanges;
@property (nonatomic, strong)        WDGradientBackground                 *actualGradientBackground;
@property (nonatomic, strong)        WDGradientBackground                 *nextGradientBackground;
@property (nonatomic, strong)        UIView                               *backgroundSwipeView;
@property (nonatomic)                BOOL                                 hideKeyboardWithTap;
@property (nonatomic)                BOOL                                 appWasResigned;
@property (nonatomic)                BOOL                                 emotionMenuVisible;
@property (nonatomic, strong)        WDAuxiliaryScreenViewController      *auxiliarySreenViewController;

- (WDWord *)   selectWordOfWordDiaryAtLaunchOrResume;
- (void)       updateByDayChange;

- (void)       tapHandle:(UIGestureRecognizer *)gestureRecognizer;
- (void)       doubleTapHandle:(UIGestureRecognizer *)gestureRecognizer;
- (void)       swipeHandle:(UIGestureRecognizer *)gestureRecognizer;
- (void)       longPressureHandle:(UIGestureRecognizer *)gestureRecognizer;
- (void)       changeSelectedWordInSwipeDirection:(UISwipeGestureRecognizerDirection)direction;

- (void)       keyboardWillShowNotification:(NSNotification *)notification;
- (void)       keyboardWillHideNotification:(NSNotification *)notification;

- (void)       animateStartEndPointOfGradient:(NSTimer *)timer;
- (CGPoint)    incGradientLayerPoint:(CGPoint)point;

- (NSString *) stringTopNavigationInfoMenuDateOfSelectedWord;

- (void)       configureColorScheme:(WDColorScheme)scheme;

- (void)       updateColorScheme:(WDColorScheme)scheme;

- (void)       wordDiaryRepresentationAnimateUpWithDuration:(CGFloat)duration;
- (void)       wordDiaryRepresentationAnimateDownWithDuration:(CGFloat)duration;

- (void)       setDateInfo;

- (void)       configureViewForSelectedWord:(BOOL)updateBackground;

- (void)       updateCursorAnimation:(NSTimer *)timer;

- (void)       startCursorUpdateTimer;
- (void)       endCursorUpdateTimer;

- (void)       startBackgroundTimerWithColor:(UIColor *)color duration:(CGFloat)duration andDirection:(UISwipeGestureRecognizerDirection)direction;
- (void)       startInvalidBackgroundTimer:(UISwipeGestureRecognizerDirection)direction;
- (void)       startBackgroundTimer:( UISwipeGestureRecognizerDirection)direction;
- (void)       endBackgroundTimer;
- (void)       backgroundTimerEnd:(NSTimer *)timer;

- (void)       changeToEmotionIndex:(NSUInteger)index withDuration:(CGFloat)duration;
- (void)       styleButtonPressed:(UIButton *)button;

- (void)       showMainMenu;
- (void)       hideMainMenu;
- (void)       hideMainMenuInmediate;
- (void)       hideAuxiliaryScreen;

- (void)       updateLongPressSwipe:(NSTimer *)timer;

- (void)       prepareViewToShowAuxiliaryScreen;

- (void)       showEmotionMenu;
- (void)       hideEmotionMenu;

@end

@implementation WDSelectedWordScreenViewController

#pragma mark Synthesize

@synthesize selectedWord                                         = selectedWord_;
@synthesize editMenuViewController                               = editMenuViewController_;
@synthesize yearDateTopInfoLabel                                 = yearDateTopInfoLabel_;
@synthesize dayMonthDateTopInfoLabel                             = dayMonthDateTopInfoLabel_;
@synthesize yearDateAndDayMonthContainerView                     = yearDateAndDayMonthContainerView_;
@synthesize doubleTapGestureRecognizer                           = doubleTapGestureRecognizer_;
@synthesize tapKeyboardGesture                                   = tapKeyboardGesture_;
@synthesize tapEmotionGesture                                    = tapEmotionGesture_;
@synthesize leftSwipeGesture                                     = leftSwipeGesture_;
@synthesize rightSwipeGesture                                    = rightSwipeGesture_;
@synthesize longPressGestureRecognizer                           = longPressGestureRecognizer_;
@synthesize longPressGestureRecognizerTimer                      = longPressGestureRecognizerTimer_;
@synthesize originalCenterPositionYearDateAndMonthContainerView  = originalCenterPositionYearDateAndMonthContainerView_;
@synthesize originalCenterPositionOfEmotionLabel                 = originalCenterPositionOfEmotionLabel_;
@synthesize originalCenterPositionOfSelectedWord                 = originalCenterPositionOfSelectedWord_;
@synthesize animateStartEndPointOfGradientTimer                  = animateStartEndPointOfGradientTimer_;
@synthesize delegate                                             = delegate_;
@synthesize keyboardActive                                       = keyboardActive_;
@synthesize wordDiaryRepresentation                              = wordDiaryRepresentation_;
@synthesize dayDiaryLabel                                        = dayDiaryLabel_;
@synthesize dayOfTheWeekLabel                                    = dayOfTheWeekLabel_;
@synthesize emotionLabel                                         = emotionLabel_;
@synthesize styleMenuView                                        = styleMenuView_;
@synthesize emotionMenuView                                      = emotionMenuView_;
@synthesize cursorUpdateTimer                                    = cursorUpdateTimer_;
@synthesize dayChecker                                           = dayChecker_;
@synthesize dayChangePendingToResolve                            = dayChangePendingToResolve_;
@synthesize backgroundTimer                                      = backgroundTimer_;
@synthesize pendingBackgroundChanges                             = pendingBackgroundChanges_;
@synthesize actualGradientBackground                             = actualGradientBackground_;
@synthesize nextGradientBackground                               = nextGradientBackground_;
@synthesize backgroundSwipeView                                  = whiteBackgroundSwipeView_;
@synthesize hideKeyboardWithTap                                  = hideKeyboardWithTap_;
@synthesize appWasResigned                                       = appWasResigned_;
@synthesize auxiliarySreenViewController                         = auxiliaryScreenViewController_;
@synthesize dayDiaryAndDayOfWeekContainerView                    = dayDiaryAndDayOfWeekContainerView_;
@synthesize emotionLabelContainerView                            = emotionLabelContainerView_;
@synthesize emotionMenuVisible                                   = emotionMenuVisible_;

#pragma mark Init

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Selected word
        selectedWord_ = [self selectWordOfWordDiaryAtLaunchOrResume];
        dayChecker_  = [[WDDayChecker alloc] init];
        dayChecker_.delegate = self;
        keyboardActive_ = NO;
        
        // Views fuera del xib propio
        wordDiaryRepresentation_ = (WDWordRepresentationView *)[WDWordRepresentationView createFromNib];
        wordDiaryRepresentation_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        auxiliaryScreenViewController_ = [[WDAuxiliaryScreenViewController alloc] initWithNibName:nil bundle:nil];
        
        // Style Menu View
        styleMenuView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 54.0)];
        NSArray *styles = [WDWordDiary sharedWordDiary].styles;
        CGFloat areaPerButton = styleMenuView_.bounds.size.width / styles.count;
        for (NSUInteger styleIt = 0; styleIt < styles.count; ++styleIt) {
            UIButton *styleButtonIt = [UIButton buttonWithType:UIButtonTypeCustom];
            styleButtonIt.frame = CGRectMake(areaPerButton * styleIt, 0.0, areaPerButton, self.styleMenuView.bounds.size.height);
            [styleButtonIt setTitle:[NSString stringWithFormat:@"%d", styleIt] forState:UIControlStateNormal];
            styleButtonIt.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.2];
            styleButtonIt.tag = styleIt;
            [styleButtonIt addTarget:self action:@selector(styleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [styleMenuView_ addSubview:styleButtonIt];
        }
        
        // Emotion Menu View
        emotionMenuView_ = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0 * 3)];
        emotionMenuView_.backgroundColor = [UIColor clearColor];
        NSArray *emotions = [WDWordDiary sharedWordDiary].emotions;
        for (NSUInteger emotionIt = 0, itemIt = 0, columnIt = 0; emotionIt < emotions.count; ++emotionIt) {
            WDEmotion *emotion = [emotions objectAtIndex:emotionIt];
            if (emotion != selectedWord_.emotion) {
                UIButton *emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
                CGFloat emotionButtonWidth = emotionMenuView_.bounds.size.width / 2;
                emotionButton.frame = CGRectMake(emotionButtonWidth * columnIt, 44.0 * (itemIt / 2), emotionButtonWidth, 44.0);
                emotionButton.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.1/* + (itemIt / 2) * 0.1*/];
                emotionButton.tag = emotionIt;
                NSLog(@"%@ - %@", NSLocalizedString(emotion.name, @""), NSStringFromCGRect(emotionButton.frame));
                [emotionButton setTitle:NSLocalizedString(emotion.name, @"") forState:UIControlStateNormal];
                [emotionMenuView_ addSubview:emotionButton];
                columnIt++;
                if (columnIt == 2) {
                    columnIt = 0;
                }
                ++itemIt;
            }
        }
        
        // Gesture Recognizer
        doubleTapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandle:)];

        doubleTapGestureRecognizer_.numberOfTapsRequired = 2;
        doubleTapGestureRecognizer_.numberOfTouchesRequired = 1;
        doubleTapGestureRecognizer_.delegate = self;
        [self.view addGestureRecognizer:doubleTapGestureRecognizer_];
        
        tapKeyboardGesture_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        tapKeyboardGesture_.numberOfTapsRequired = 1;
        tapKeyboardGesture_.numberOfTouchesRequired = 1;
        tapKeyboardGesture_.delegate = self;
        [self.wordDiaryRepresentation addGestureRecognizer:tapKeyboardGesture_];
        [tapKeyboardGesture_ requireGestureRecognizerToFail:doubleTapGestureRecognizer_];
        
        tapEmotionGesture_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        tapEmotionGesture_.numberOfTapsRequired = 1;
        tapEmotionGesture_.numberOfTouchesRequired = 1;
        tapEmotionGesture_.delegate = self;
        [self.emotionLabelContainerView addGestureRecognizer:self.tapEmotionGesture];
        [self.tapEmotionGesture requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];

        longPressGestureRecognizer_ = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressureHandle:)];
        longPressGestureRecognizer_.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:longPressGestureRecognizer_];

        rightSwipeGesture_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
        rightSwipeGesture_.direction = UISwipeGestureRecognizerDirectionRight;
        rightSwipeGesture_.numberOfTouchesRequired = 1;
        rightSwipeGesture_.delegate = self;
        [self.view addGestureRecognizer:rightSwipeGesture_];
        
        leftSwipeGesture_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
        leftSwipeGesture_.direction = UISwipeGestureRecognizerDirectionLeft;
        leftSwipeGesture_.numberOfTouchesRequired = 1;
        leftSwipeGesture_.delegate = self;
        [self.view addGestureRecognizer:leftSwipeGesture_];
        
        // Notificaciones keyboard
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // Palabra
    self.wordDiaryRepresentation.delegate = self;
    self.wordDiaryRepresentation.dataSource = self;
    [self.view addSubview:self.wordDiaryRepresentation];
    
    // Emotion
    self.emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.emotionLabelContainerView.bounds.size.width, self.emotionLabelContainerView.bounds.size.height)];
    self.emotionLabel.textAlignment = NSTextAlignmentCenter;
    self.emotionLabel.backgroundColor = [UIColor clearColor];
    [self.emotionLabelContainerView addSubview:self.emotionLabel];
    
    // Menu de edicion
    self.editMenuViewController = [[WDSelectedWordEditMenuViewController alloc] initWithSelectedWord:self.selectedWord];
    [self.view addSubview:self.editMenuViewController.view];
    self.editMenuViewController.view.hidden = YES;
    self.editMenuViewController.delegate = self;
    
    self.auxiliarySreenViewController.delegate = self;
    
    self.view.contentMode = UIViewContentModeCenter;
    
    [self configureViewForSelectedWord:YES];

    [self startCursorUpdateTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Representación de la palabra.
    self.wordDiaryRepresentation.frame = CGRectMake(0.0,
                                                    self.yearDateAndDayMonthContainerView.frame.origin.y + self.yearDateAndDayMonthContainerView.frame.size.height,
                                                    self.view.bounds.size.width,
                                                    self.dayDiaryAndDayOfWeekContainerView.frame.origin.y - (self.yearDateAndDayMonthContainerView.frame.origin.y + self.yearDateAndDayMonthContainerView.frame.size.height));
    
    // Se centran las views correctamente
    // Esto desaparecera....
    const CGFloat xMargin = (self.view.frame.size.width - self.editMenuViewController.view.frame.size.width) / 2.0;
    self.editMenuViewController.view.frame = CGRectMake(xMargin,
                                                        self.view.bounds.size.height - self.editMenuViewController.view.bounds.size.height - xMargin,
                                                        self.editMenuViewController.view.bounds.size.width,
                                                        self.editMenuViewController.view.bounds.size.height);
    self.auxiliarySreenViewController.view.frame = CGRectMake(self.view.frame.origin.x + xMargin, xMargin, self.view.bounds.size.width - xMargin * 2, self.view.bounds.size.height - xMargin * 2);
    
    if (self.selectedWord.word.length > 0) {
        [self.wordDiaryRepresentation setWithoutCursor:0.0];
    } else {
        [self.wordDiaryRepresentation setWithCursor:0.0];
    }
    
    self.originalCenterPositionYearDateAndMonthContainerView = self.yearDateAndDayMonthContainerView.center;
    self.originalCenterPositionOfSelectedWord = self.wordDiaryRepresentation.center;
    self.originalCenterPositionOfEmotionLabel = self.emotionLabelContainerView.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self endCursorUpdateTimer];
}

#pragma mark - WDGradientBackground

- (void)changeToEmotionIndex:(NSUInteger)index withDuration:(CGFloat)duration
{
    if (self.nextGradientBackground != nil) {
        [self.pendingBackgroundChanges addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:index], [NSNumber numberWithFloat:duration], nil]
                                                                             forKeys:[NSArray arrayWithObjects:@"emotionIndex", @"duration",  nil]]];
    } else {
        self.selectedWord.emotion = [[WDWordDiary sharedWordDiary].emotions objectAtIndex:index];
        WDPalette *palette = [[self.selectedWord.emotion.palette allObjects] objectAtIndex:0];
        self.selectedWord.paletteIdNameOfEmotion = palette.idName;
        self.nextGradientBackground = [[WDGradientBackground alloc] initWithFrame:self.actualGradientBackground.frame andHexColor:palette.backgroundColor];
        self.nextGradientBackground.alpha = 0.0;
        [self.view insertSubview:self.nextGradientBackground belowSubview:self.actualGradientBackground];
        
        [UIView animateWithDuration:duration animations:^{
            self.nextGradientBackground.alpha = 1.0;
            self.actualGradientBackground.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.actualGradientBackground removeFromSuperview];
            self.actualGradientBackground = self.nextGradientBackground;
            self.nextGradientBackground = nil;
            
            if (self.pendingBackgroundChanges.count > 0) {
                NSDictionary *pendingGradientBackground = [self.pendingBackgroundChanges objectAtIndex:0];
                NSNumber *pendingGradientColorIndex = [pendingGradientBackground objectForKey:@"emotionIndex"];
                NSNumber *pendingGradientDuration = [pendingGradientBackground objectForKey:@"duration"];
                [self.pendingBackgroundChanges removeObject:pendingGradientBackground];
                
                // Evitamos llamadas recursivas
                // OJO: Posible agujero si entre que se produce la llamada llega otra a changeToGradientBackground, haría que se colara frente a la que de verdad toca
                //      Debido a este agujero decido no activar la llamada a mainqueue y aguantar la recursiva.
                [self changeToEmotionIndex:pendingGradientColorIndex.unsignedIntegerValue withDuration:pendingGradientDuration.floatValue];
                /*
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self changeToGradientBackgroundOfColorIndex:pendingGradientColorIndex.unsignedIntegerValue withDuration:pendingGradientDuration.floatValue];
                }];
                */
            }
        }];
    }
}

#pragma mark - Auxiliary

- (void)prepareViewToShowAuxiliaryScreen
{
    [self.editMenuViewController hideMenu];
    [UIView animateWithDuration:0.75 animations:^{
        self.yearDateTopInfoLabel.alpha = 0.0;
        self.dayMonthDateTopInfoLabel.alpha = 0.0;
        self.wordDiaryRepresentation.alpha = 0.0;
        self.dayDiaryLabel.alpha = 1.0;
        self.dayOfTheWeekLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Quitamos este componente, que es el verdaderamente pesado
        [self.wordDiaryRepresentation removeFromSuperview];
    }];
}

- (void)startCursorUpdateTimer
{
    self.cursorUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_TIME_CURSOR target:self selector:@selector(updateCursorAnimation:) userInfo:nil repeats:YES];
}

- (void)endCursorUpdateTimer
{
    [self.cursorUpdateTimer invalidate];
    self.cursorUpdateTimer = nil;
}

- (WDWord *)selectWordOfWordDiaryAtLaunchOrResume
{
    NSDate *todayDate = [NSDate date];
    WDWord *lastCreatedWord = [[WDWordDiary sharedWordDiary] findLastCreatedWord];
    if (lastCreatedWord != nil) {
        if (![lastCreatedWord isTodayWord]) {
            if ([lastCreatedWord isEmpty]) {
                lastCreatedWord.timeInterval = [todayDate timeIntervalSince1970];
                lastCreatedWord.word = @"";
            } else {
                lastCreatedWord = nil;
            }
        }
    }
    
    if (nil == lastCreatedWord) {
        lastCreatedWord = [[WDWordDiary sharedWordDiary] createWord:@"" inTimeInterval:[todayDate timeIntervalSince1970]];
    }
    
    return lastCreatedWord;
}

- (void)updateByDayChange
{
    WDWord *newLastWord = [self selectWordOfWordDiaryAtLaunchOrResume];
    if (newLastWord != self.selectedWord) {
        self.selectedWord = newLastWord;
        [self startBackgroundTimer:0];
        [self configureViewForSelectedWord:YES];
    } else {
        [self configureViewForSelectedWord:NO];
    }
    
    self.dayChangePendingToResolve = NO;
 }

- (void)configureViewForSelectedWord:(BOOL)updateBackground
{
    self.editMenuViewController.selectedWord = self.selectedWord;
    
    WDPalette *palette = [self.selectedWord.emotion findPaletteOfIdName:self.selectedWord.paletteIdNameOfEmotion];

    // Emotion
    self.emotionLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(self.selectedWord.emotion.name, @"") uppercaseString]
                                                                       attributes:@{
                                                              NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:21.0],
                                                   NSForegroundColorAttributeName:  [UIColor colorWithHexadecimalValue:[self.selectedWord.emotion findPaletteOfIdName:self.selectedWord.paletteIdNameOfEmotion].wordColor withAlphaComponent:NO skipInitialCharacter:NO],
                                                              NSKernAttributeName: [NSNumber numberWithFloat:2]}];
    if (updateBackground && nil == self.backgroundTimer) {
        if (self.actualGradientBackground == nil) {
            // ToDo: Quitar el 0 y relacionar con la paleta de colores adecuada
            self.actualGradientBackground = [[WDGradientBackground alloc] initWithFrame:self.view.frame andHexColor:palette.backgroundColor];
            [self.view insertSubview:self.actualGradientBackground atIndex:0];
        } else if (0 != self.actualGradientBackground.gradientColorIndex) {
            [self changeToEmotionIndex:0 withDuration:0.75];
        }
        // self.editMenuViewController.backgroundColorScheme = background.uiOverlayColorScheme;
    }

    // Fecha
    UIColor *accessoriesColor = [UIColor colorWithHexadecimalValue:palette.accessoriesColor withAlphaComponent:NO skipInitialCharacter:NO];
    self.yearDateTopInfoLabel.textColor = [accessoriesColor copy];
    self.dayMonthDateTopInfoLabel.textColor = [accessoriesColor copy];
    self.dayOfTheWeekLabel.textColor = [accessoriesColor copy];
    
    [self setDateInfo];
    
    // Palabra
    //UIColor *wordColor = [UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
    self.dayDiaryLabel.textColor = [accessoriesColor copy];
    
    NSUInteger indexPositionOfSelectedWord = [[WDWordDiary sharedWordDiary] findIndexPositionForWord:self.selectedWord];
    NSString *dayIndexOfDiary = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithUnsignedInteger:indexPositionOfSelectedWord]];
    self.dayDiaryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TAG_DIARYDAY_LABEL", @""), dayIndexOfDiary];
    if ([self.selectedWord isEmpty]) {
        NSAssert([self.selectedWord isTodayWord], @"Solo PUEDE estar vacia la palabra del dia de hoy");
        [self.wordDiaryRepresentation setWithCursor:0];
    } else {
        [self.wordDiaryRepresentation setWithoutCursor:0];
    }

    [self.wordDiaryRepresentation setNeedsDisplay];
}

- (void)updateCursorAnimation:(NSTimer *)timer
{
    [self.wordDiaryRepresentation updateCursorAnimation];
    [self.wordDiaryRepresentation setNeedsDisplay];
}

- (void)setDateInfo
{
    static const CGFloat gosthEffectTime = 1.5;
    
    NSString *newYearDateText = [NSNumber numberWithUnsignedInteger:self.selectedWord.dateComponents.year].stringValue;
    if ([newYearDateText compare:self.yearDateTopInfoLabel.text] != NSOrderedSame) {
        if (self.yearDateTopInfoLabel.text.length > 0) {
            [WDUtils destroyViewGosthEffect:self.yearDateTopInfoLabel withDuration:gosthEffectTime andDisplacement:0];
        }
        self.yearDateTopInfoLabel.text = newYearDateText;
    }
    
    NSString *dayMonthDateText = nil;
    if ([self.selectedWord isTodayWord]) {
        dayMonthDateText = [NSString stringWithFormat:@"%@", NSLocalizedString(@"TAG_TODAYSECTION", @"")];
    } else {
        NSString *dayString = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithInteger:self.selectedWord.dateComponents.day]];
        if ([WDUtils englishIsTheCurrentAppLanguage]) {
            dayMonthDateText = [NSString stringWithFormat:@"%@, %@", [WDUtils abreviateMonthString:self.selectedWord.dateComponents.month], dayString];
        } else {
            dayMonthDateText = [NSString stringWithFormat:@"%@, %@", dayString, [WDUtils abreviateMonthString:self.selectedWord.dateComponents.month]];
        }
    }
    
    if ([dayMonthDateText compare:self.dayMonthDateTopInfoLabel.text] != NSOrderedSame) {
        if (self.dayMonthDateTopInfoLabel.text.length > 0) {
            [WDUtils destroyViewGosthEffect:self.dayMonthDateTopInfoLabel withDuration:gosthEffectTime andDisplacement:0];
        }
        self.dayMonthDateTopInfoLabel.text = dayMonthDateText;
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *dateFromWordTimeInterval = [NSDate dateWithTimeIntervalSince1970:self.selectedWord.timeInterval];
    NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:dateFromWordTimeInterval];
    NSString *dayOfTheWeekLabel = [[WDUtils stringFromWeekday:dateComponents.weekday] lowercaseStringWithLocale:[NSLocale currentLocale]];
    if ([dayMonthDateText compare:self.dayOfTheWeekLabel.text] != NSOrderedSame) {
        if (self.dayOfTheWeekLabel.text.length > 0) {
            [WDUtils destroyViewGosthEffect:self.dayOfTheWeekLabel withDuration:gosthEffectTime andDisplacement:0];
        }
        self.dayOfTheWeekLabel.text = dayOfTheWeekLabel;
    }

}

- (void)updateColorScheme:(WDColorScheme)scheme
{
    [self configureColorScheme:scheme];
    [self.editMenuViewController updateColorScheme:scheme];
}

- (void)configureColorScheme:(WDColorScheme)scheme
{
}

- (NSString *)stringTopNavigationInfoMenuDateOfSelectedWord
{
    NSString *retString = nil;
    if ([self.selectedWord isTodayWord]) {
        retString = NSLocalizedString(@"TAG_TODAYSECTION", @"");
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        dateFormatter.locale = [NSLocale currentLocale];
        
        retString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.selectedWord.timeInterval]];
    }
    
    return retString;
}

- (CGPoint)incGradientLayerPoint:(CGPoint)point
{
    // Nos desplazamos por los margenes del rectangulo de valores
    const CGFloat incValue = 0.05;
    CGPoint retPoint = point;
    if ([WDUtils is:retPoint.y equalsTo:0.0]) {
        if ([WDUtils is:retPoint.x equalsTo:1.0]) {
            retPoint.y += incValue;
        } else {
            retPoint.x += incValue;
        }
    } else if ([WDUtils is:retPoint.y equalsTo:1.0]) {
        if (retPoint.x == 1.0) {
            retPoint.x -= incValue;
        } else if ([WDUtils is:retPoint.x equalsTo:0.0]) {
            retPoint.y -= incValue;
        } else {
            retPoint.x -= incValue;
        }
    } else {
        if ([WDUtils is:retPoint.x equalsTo:0.0]) {
            retPoint.y -= incValue;
        } else if ([WDUtils is:retPoint.x equalsTo:1.0]) {
            retPoint.y += incValue;
        }
    }
    
    return retPoint;
}

- (void)animateStartEndPointOfGradient:(NSTimer *)timer
{
    CAGradientLayer *layer = [self.view.layer.sublayers objectAtIndex:0];
    layer.startPoint = [self incGradientLayerPoint:layer.startPoint];
    layer.endPoint = [self incGradientLayerPoint:layer.endPoint];
}

- (void)wordDiaryRepresentationAnimateUpWithDuration:(CGFloat)duration
{
    CGRect newArea = CGRectMake(0.0, 0.0, self.view.frame.size.width,  self.editMenuViewController.view.frame.origin.y);
    [UIView animateWithDuration:duration animations:^{
        BOOL isIPhone5Screen = [WDUtils isIPhone5Screen];
        //self.wordDiaryRepresentation.center = CGPointMake(self.wordDiaryRepresentation.center.x, (newArea.origin.y + newArea.size.height / (isIPhone5Screen ? 2 : 2.25)) * 0.90);
        if (isIPhone5Screen) {
            if (self.emotionLabel.center.y == self.originalCenterPositionOfEmotionLabel.y) {
                //self.emotionLabel.center = CGPointMake(self.emotionLabel.center.x, self.emotionLabel.center.y * 0.82);
            }
        } else {
            self.emotionLabel.alpha = 0.0;
        }
        self.dayDiaryLabel.alpha = 0.25;
        self.dayOfTheWeekLabel.alpha = 0.25;
        self.yearDateTopInfoLabel.alpha = 0.25;
        self.dayMonthDateTopInfoLabel.alpha = 0.25;
    }];
}

- (void)wordDiaryRepresentationAnimateDownWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        //self.wordDiaryRepresentation.center = self.originalCenterPositionOfSelectedWord;
        if ([WDUtils isIPhone5Screen]) {
            //self.emotionLabel.center = self.originalCenterPositionOfEmotionLabel;
        } else {
            self.emotionLabel.alpha = 1.0;
        }
        self.dayDiaryLabel.alpha = 1.0;
        self.dayOfTheWeekLabel.alpha = 1.0;
        self.wordDiaryRepresentation.alpha = 1.0;
        self.yearDateTopInfoLabel.alpha = 1.0;
        self.dayMonthDateTopInfoLabel.alpha = 1.0;
    }];
}

- (void)showMainMenu
{
    if ([self.selectedWord isTodayWord]) {
        [self.editMenuViewController showTodayWordMenu];
    } else {
        [self.editMenuViewController showPreviousWordMenu];
    }
    [self wordDiaryRepresentationAnimateUpWithDuration:0.5];
}

- (void)hideMainMenu
{
    [self wordDiaryRepresentationAnimateDownWithDuration:0.5];
    [self.editMenuViewController hideMenu];
}

- (void)hideMainMenuInmediate
{
    [self wordDiaryRepresentationAnimateDownWithDuration:0.0];
    [self.editMenuViewController hideMenuInmediate];
}

- (void)hideAuxiliaryScreen
{
    [self.view addSubview:self.wordDiaryRepresentation];
    self.wordDiaryRepresentation.center = self.originalCenterPositionOfSelectedWord;
    [UIView animateWithDuration:0.55 animations:^{
        self.yearDateTopInfoLabel.alpha = 1.0;
        self.dayMonthDateTopInfoLabel.alpha = 1.0;
        self.wordDiaryRepresentation.alpha = 1.0;
        self.dayDiaryLabel.alpha = 1.0;
        self.dayOfTheWeekLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [self.auxiliarySreenViewController hideWithDuration:0.55];
    self.view.backgroundColor = nil;
}

- (void)updateLongPressSwipe:(NSTimer *)timer
{
    NSNumber *userInfo = timer.userInfo;
    [self changeSelectedWordInSwipeDirection:userInfo.unsignedIntegerValue];
    
    if (timer.timeInterval > 0.25) {
        NSTimeInterval actualTimeInterval = timer.timeInterval;
        [self.longPressGestureRecognizerTimer invalidate];
        self.longPressGestureRecognizerTimer = [NSTimer scheduledTimerWithTimeInterval:actualTimeInterval - 0.45 target:self selector:@selector(updateLongPressSwipe:) userInfo:userInfo repeats:YES];
    }
}

- (void)styleButtonPressed:(UIButton *)button
{
    WDStyle *newStyle = [[WDWordDiary sharedWordDiary].styles objectAtIndex:button.tag];
    if (newStyle != self.selectedWord.style) {
        self.selectedWord.style = newStyle;
        [self.wordDiaryRepresentation familyFontOfSelectedWordChanged];
        [self.wordDiaryRepresentation setNeedsDisplay];
    }
}

- (void)showEmotionMenu
{
    self.emotionMenuView.frame = CGRectMake(self.emotionMenuView.frame.origin.x, self.view.bounds.size.height, self.emotionMenuView.frame.size.width, self.emotionMenuView.frame.size.height);
    [self.view addSubview:self.emotionMenuView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.dayDiaryAndDayOfWeekContainerView.alpha = 0;
        self.emotionLabelContainerView.center = self.dayDiaryAndDayOfWeekContainerView.center;
        self.emotionMenuView.frame = CGRectMake(self.emotionMenuView.frame.origin.x, self.view.bounds.size.height - self.emotionMenuView.frame.size.height, self.emotionMenuView.frame.size.width, self.emotionMenuView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    self.emotionMenuVisible = YES;
}

- (void)hideEmotionMenu
{
    [UIView animateWithDuration:0.5 animations:^{
        self.dayDiaryAndDayOfWeekContainerView.alpha = 1.0;
        self.emotionLabelContainerView.center = self.originalCenterPositionOfEmotionLabel;
         self.emotionMenuView.frame = CGRectMake(self.emotionMenuView.frame.origin.x, self.view.bounds.size.height, self.emotionMenuView.frame.size.width, self.emotionMenuView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.emotionMenuView removeFromSuperview];
    }];
    
    self.emotionMenuVisible = NO;
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL shouldReceive = YES;
    if (touch.view == self.editMenuViewController.view) {
        shouldReceive = self.editMenuViewController.view.hidden;
    }
        
    return shouldReceive;
}

#pragma mark - Tap Gesture Recognizer

- (void)tapHandle:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.tapKeyboardGesture) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (!self.keyboardActive && ![self.auxiliarySreenViewController isShowed]) {
                BOOL useAsTapGesture = self.editMenuViewController.view.hidden;
                if (!useAsTapGesture) {
                    CGPoint hitPoint = [gestureRecognizer locationInView:nil];
                    useAsTapGesture = !CGRectContainsPoint(self.editMenuViewController.view.frame, hitPoint);
                }
                if (useAsTapGesture) {
                    [self.wordDiaryRepresentation becomeFirstResponder];
                }
            } else {
                self.hideKeyboardWithTap = YES;
                [self.wordDiaryRepresentation resignFirstResponder];
            }
        }
    } else if (gestureRecognizer == self.tapEmotionGesture) {
        if (self.emotionMenuVisible) {
            [self hideEmotionMenu];
        } else {
            [self showEmotionMenu];
        }
    }
}

- (void)doubleTapHandle:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!self.keyboardActive && self.editMenuViewController.view.hidden && ![self.auxiliarySreenViewController isShowed]) {
            WDWord *lastWord = [[WDWordDiary sharedWordDiary] findLastCreatedWord];
            if (lastWord != self.selectedWord) {
                self.selectedWord = lastWord;
                [self startBackgroundTimer:0];
                [self configureViewForSelectedWord:YES];
            }
        }
    }
}

#pragma mark - LongPressureRecognizer

- (void)longPressureHandle:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL inLongPressSwipeMode = ![self.auxiliarySreenViewController isShowed];
    
    if (inLongPressSwipeMode) {
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
                inLongPressSwipeMode = YES;
                break;
            case UIGestureRecognizerStateChanged:
                inLongPressSwipeMode = YES;
                break;
            case UIGestureRecognizerStateEnded:
                inLongPressSwipeMode = NO;
                break;
                
            default:
                break;
        };
    }
    
    if (inLongPressSwipeMode) {
        if (nil == self.longPressGestureRecognizerTimer) {
            UISwipeGestureRecognizerDirection direction = UISwipeGestureRecognizerDirectionRight;
            CGPoint hitLocation = [self.longPressGestureRecognizer locationInView:self.view];
            if (hitLocation.x > self.view.frame.size.width / 2) {
                direction = UISwipeGestureRecognizerDirectionLeft;
            }
            self.longPressGestureRecognizerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLongPressSwipe:) userInfo:[NSNumber numberWithUnsignedInteger:direction] repeats:YES];

            [self changeSelectedWordInSwipeDirection:direction];
        }
    } else {
        [self.longPressGestureRecognizerTimer invalidate];
        self.longPressGestureRecognizerTimer = nil;
    }
}

#pragma mark - BackgroundTimer

- (void)startBackgroundTimerWithColor:(UIColor *)color duration:(CGFloat)duration andDirection:(UISwipeGestureRecognizerDirection)direction
{
    BOOL diferentBackgroundColor = self.backgroundSwipeView.backgroundColor.CGColor != color.CGColor;
    BOOL timerActive = self.backgroundTimer != nil;
    
    if (timerActive) {
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
    }
    
    if (!timerActive || diferentBackgroundColor) {
        if (self.backgroundSwipeView) {
            [self.backgroundSwipeView removeFromSuperview];
            self.backgroundSwipeView = nil;
        }
        self.backgroundSwipeView = [[UIView alloc] initWithFrame:self.actualGradientBackground.frame];
        self.backgroundSwipeView.backgroundColor = color;
        self.backgroundSwipeView.layer.cornerRadius = [WDUtils viewsCornerRadius];
        self.backgroundSwipeView.userInteractionEnabled = NO;
        [self.view insertSubview:self.backgroundSwipeView atIndex:0];
        
        [self.actualGradientBackground removeFromSuperview];
        [self.nextGradientBackground removeFromSuperview];
        self.nextGradientBackground = nil;
        [self.pendingBackgroundChanges removeAllObjects];
        
        [UIView animateWithDuration:duration animations:^{
            self.yearDateTopInfoLabel.alpha = 0.2;
            self.dayMonthDateTopInfoLabel.alpha = 0.2;
            self.wordDiaryRepresentation.alpha = 0.8;
            self.dayDiaryLabel.alpha = 0.4;
            self.dayOfTheWeekLabel.alpha = 0.2;
        }];
    }
    
    self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(backgroundTimerEnd:) userInfo:nil repeats:NO];
}

- (void)startInvalidBackgroundTimer:(UISwipeGestureRecognizerDirection)direction
{
    [self startBackgroundTimerWithColor:[UIColor colorWithWhite:0.70 alpha:1.0] duration:0 andDirection:direction];
    UIImageView *noIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37-circle-x"]];
    noIcon.frame = CGRectMake((self.view.frame.size.width - noIcon.frame.size.width) / 2, (self.view.frame.origin.y + self.view.frame.size.height) - 64.0, noIcon.frame.size.width, noIcon.frame.size.height);
    [self.backgroundSwipeView addSubview:noIcon];
}

- (void)startBackgroundTimer:(UISwipeGestureRecognizerDirection)direction
{
    [self startBackgroundTimerWithColor:[UIColor colorWithWhite:0.90 alpha:1.0] duration:0 andDirection:direction];
}

- (void)endBackgroundTimer
{
    [self.backgroundTimer invalidate];
    self.backgroundTimer = nil;
}

- (void)backgroundTimerEnd:(NSTimer *)timer
{    
    [self endBackgroundTimer];
    
    // ToDo: Quitar el 0 y relacionar con la paleta correcta de colores
    WDPalette *palette = [[WDWordDiary sharedWordDiary] findPaletteWithIdName:self.selectedWord.paletteIdNameOfEmotion];
    self.actualGradientBackground = [[WDGradientBackground alloc] initWithFrame:self.actualGradientBackground.frame andHexColor:palette.backgroundColor];
    [self.view insertSubview:self.actualGradientBackground belowSubview:self.backgroundSwipeView];
    self.backgroundSwipeView.userInteractionEnabled = NO;
    self.actualGradientBackground.alpha = 0.0;

    [UIView animateWithDuration:1.5 animations:^{
        self.backgroundSwipeView.alpha = 0.0;
        self.actualGradientBackground.alpha = 1.0;
        self.yearDateTopInfoLabel.alpha = 1.0;
        self.dayMonthDateTopInfoLabel.alpha = 1.0;
        self.dayDiaryLabel.alpha = 1.0;
        self.dayOfTheWeekLabel.alpha = 1.0;
        self.wordDiaryRepresentation.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.backgroundSwipeView removeFromSuperview];
            self.backgroundSwipeView = nil;
        }
      //
    }];
}

#pragma mark - Swipe Gesture Recognizer

- (void)changeSelectedWordInSwipeDirection:(UISwipeGestureRecognizerDirection)direction
{
    WDWord *newSelectedWord = nil;
    if (direction & UISwipeGestureRecognizerDirectionLeft) {
        newSelectedWord = [[WDWordDiary sharedWordDiary] findPreviousWordOf:self.selectedWord];
    } else if (direction & UISwipeGestureRecognizerDirectionRight) {
        newSelectedWord = [[WDWordDiary sharedWordDiary] findNextWordOf:self.selectedWord];
    }
        
    if (nil == newSelectedWord) {
        [self startInvalidBackgroundTimer:direction];
    } else {
        self.selectedWord = newSelectedWord;
        [self startBackgroundTimer:direction];
        [self configureViewForSelectedWord:YES];
    }
}

- (void)swipeHandle:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.editMenuViewController.view.hidden && !self.keyboardActive && ![self.auxiliarySreenViewController isShowed]) {
        UISwipeGestureRecognizerDirection swipeDirection = gestureRecognizer == self.leftSwipeGesture ? UISwipeGestureRecognizerDirectionLeft : UISwipeGestureRecognizerDirectionRight;
        
        [self changeSelectedWordInSwipeDirection:swipeDirection];
    }
}

#pragma mark KeyboardNotification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    self.keyboardActive = YES;
    
    CGRect endFrameKeyboard = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //self.styleMenuView.center = CGPointMake(-self.styleMenuView.bounds.size.width / 2.0, endFrameKeyboard.origin.y - 44.0);
    self.styleMenuView.frame = CGRectMake(0.0, endFrameKeyboard.origin.y - self.styleMenuView.bounds.size.height, self.styleMenuView.bounds.size.width, self.styleMenuView.bounds.size.height);
    
    CGPointMake(self.styleMenuView.bounds.size.width / 2.0, endFrameKeyboard.origin.y - 44.0);
    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; ++styleIt) {
        [self.styleMenuView viewWithTag:styleIt].alpha = 0;
    }
    [self.view addSubview:self.styleMenuView];
    
    NSNumber *keybAnimationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; ++styleIt) {
        CGFloat animationDuration = keybAnimationDuration.floatValue * (styleIt / ([WDWordDiary sharedWordDiary].styles.count - 1)) + 0.65;
        [UIView animateWithDuration:animationDuration animations:^{
            [self.styleMenuView viewWithTag:styleIt].alpha = 1.0;
        }];
    }
    
    [UIView animateWithDuration:keybAnimationDuration.floatValue animations:^{
        self.yearDateAndDayMonthContainerView.center = CGPointMake(self.yearDateAndDayMonthContainerView.center.x, self.yearDateAndDayMonthContainerView.center.y - self.yearDateAndDayMonthContainerView.bounds.size.height / 2.0);
        self.yearDateAndDayMonthContainerView.alpha = 0;
        self.wordDiaryRepresentation.center = CGPointMake(self.wordDiaryRepresentation.center.x, self.wordDiaryRepresentation.center.y - self.yearDateAndDayMonthContainerView.bounds.size.height / 3.0);
        self.dayDiaryAndDayOfWeekContainerView.alpha = 0.0;
        //self.styleMenuView.center = CGPointMake(self.styleMenuView.bounds.size.width / 2.0, self.styleMenuView.center.y);
    }];
    
    [self.wordDiaryRepresentation setWithCursor:ANIMATION_TIME_CURSORMODE];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    self.keyboardActive = NO;
    
    NSDictionary *userInfo = notification.userInfo;
    
    if (self.selectedWord.word.length == 0) {
        [self.wordDiaryRepresentation setWithCursor:ANIMATION_TIME_WITHOUTCURSORMODE];
    } else {
        [self.wordDiaryRepresentation setWithoutCursor:ANIMATION_TIME_WITHOUTCURSORMODE];
    }
    
    NSNumber *keybAnimationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];

    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; ++styleIt) {
        CGFloat animationDuration = keybAnimationDuration.floatValue * (styleIt / ([WDWordDiary sharedWordDiary].styles.count - 1)) + 0.65;
        NSUInteger buttonIndexToChange = [WDWordDiary sharedWordDiary].styles.count - styleIt - 1;
        if (buttonIndexToChange == 0) {
            [UIView animateWithDuration:animationDuration animations:^{
                [self.styleMenuView viewWithTag:buttonIndexToChange].alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.styleMenuView removeFromSuperview];
            }];
        } else {
            [UIView animateWithDuration:animationDuration animations:^{
                [self.styleMenuView viewWithTag:buttonIndexToChange].alpha = 0.0;
            }];
        }
    }
   
    [self wordDiaryRepresentationAnimateDownWithDuration:keybAnimationDuration.floatValue];
    [UIView animateWithDuration:keybAnimationDuration.doubleValue animations:^{
        self.yearDateAndDayMonthContainerView.center = self.originalCenterPositionYearDateAndMonthContainerView;
        self.wordDiaryRepresentation.center = self.originalCenterPositionOfSelectedWord;
        self.yearDateAndDayMonthContainerView.alpha = 1;
        self.dayDiaryAndDayOfWeekContainerView.alpha = 1.0;
        //self.styleMenuView.center = CGPointMake(-self.styleMenuView.bounds.size.width / 2.0, self.styleMenuView.center.y);
    } completion:^(BOOL finished) {
        // ...
    }];
    
    self.hideKeyboardWithTap = NO;
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    if (self.dayChangePendingToResolve) {
        [self updateByDayChange];
    }
}

#pragma mark - WDAuxiliaryScreenViewControllerDelegate

- (void)auxiliaryScreenViewBackButtonPressed:(WDAuxiliaryScreenViewController *)auxiliaryViewController
{
    [self hideAuxiliaryScreen];
}

- (void)auxiliaryScreenViewWillHide:(WDAuxiliaryScreenViewController *)auxiliaryViewController
{
    
}

- (void)auxiliarySupportScreenViewEmailPressedAndOpen:(WDAuxiliaryScreenViewController *)auxiliaryViewController
{
    // Escondemos el menu auxiliar cuando haya sido enviado el email
}

- (void)auxiliarySupportScreenViewEmailWasSend:(WDAuxiliaryScreenViewController *)auxiliaryViewController
{
    [self hideAuxiliaryScreen];
}

- (void)auxiliaryAboutScreenViewWordDiaryURLPressedAndOpen:(WDAuxiliaryScreenViewController *)auxiliaryViewController
{
    [self hideAuxiliaryScreen];
}

- (void)auxiliaryAboutScreenViewDeveloperTwitterURLPressedAndOpen:(WDAuxiliaryScreenViewController *)auxiliaryViewController
{
    [self hideAuxiliaryScreen];
}

#pragma mark - WDSelectedWordEditMenuDelegate

- (void)tipsOptionSelected
{
    [self prepareViewToShowAuxiliaryScreen];
    [self.auxiliarySreenViewController showHelpScreenInView:self.view withDuration:1];
}

- (void)infoOptionSelected
{
    [self prepareViewToShowAuxiliaryScreen];
    [self.auxiliarySreenViewController showAboutScreenInView:self.view withDuration:1];
}

- (void)supportOptionSelected
{
    [self prepareViewToShowAuxiliaryScreen];
    [self.auxiliarySreenViewController showSupportScreenInView:self.view withDuration:1];
}

- (void)writeSelectedWordOption
{
    [self.wordDiaryRepresentation becomeFirstResponder];
    self.editMenuViewController.view.hidden = YES;
}

- (void)clearTodaySelectedWordOption
{
    self.selectedWord.word = @"";
    self.editMenuViewController.view.hidden = YES;
    
    //[self.delegate selectedWordChanged];
}

- (void)cancelDeleteWordFromConfirmationMenu
{
    [self hideMainMenu];
}

- (void)acceptDeleteWordFromConfirmationMenu
{
    WDWord *newSelectedWord = [[WDWordDiary sharedWordDiary] findPreviousWordOf:self.selectedWord];
    NSAssert(newSelectedWord, @"Siempre tiene que existir una instancia de tipo palabra");

    [[WDWordDiary sharedWordDiary] removeWord:self.selectedWord];
    self.selectedWord = newSelectedWord;
    [self hideMainMenu];
    [self startBackgroundTimer:0];
    [self configureViewForSelectedWord:YES];
}

- (void)menuDidHide
{
    if (self.dayChangePendingToResolve) {
        [self updateByDayChange];
    }
}

- (void)changeToFontWithIndex:(NSUInteger)indexFont
{
    WDStyle *newStyle = [[WDWordDiary sharedWordDiary].styles objectAtIndex:indexFont];
    if (newStyle != self.selectedWord.style) {
        self.selectedWord.style = newStyle;
        [self.wordDiaryRepresentation familyFontOfSelectedWordChanged];
        [self.wordDiaryRepresentation setNeedsDisplay];
    }
    //NSLog(@"Family %@", self.selectedWord.font.family);
    /*NSLog(@"PointSize %f", self.wordDiaryRepresentation.wordTextField.font.pointSize);
    NSLog(@"Acender %f", self.wordDiaryRepresentation.wordTextField.font.ascender);
    NSLog(@"Descender %f", self.wordDiaryRepresentation.wordTextField.font.descender);
    NSLog(@"Cap Height %f", self.wordDiaryRepresentation.wordTextField.font.capHeight);
    NSLog(@"Line Height %f", self.wordDiaryRepresentation.wordTextField.font.lineHeight);
    NSLog(@"xHeight %f", self.wordDiaryRepresentation.wordTextField.font.xHeight);
    NSLog(@"Leading %f", self.wordDiaryRepresentation.wordTextField.font.leading);
    NSLog(@"\\\changeToFontWithIndex\\\\\\\\\\\\\\\\\\\");
     */
}

- (void)changeToEmotionIndex:(NSUInteger)indexEmotion
{
    // ToDo:Cambio del color de fondo
    [self changeToEmotionIndex:indexEmotion withDuration:1.5];
}

#pragma mark - WDWordRepresentationViewDelegate

- (void)deleteBackwardsOnWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    if (self.selectedWord.word.length > 0) {
        self.selectedWord.word = [self.selectedWord.word substringWithRange:NSMakeRange(0, self.selectedWord.word.length - 1)];
    }
    
    [self.wordDiaryRepresentation setNeedsDisplay];
}

- (void)wordRepresentationView:(WDWordRepresentationView *)wordRepresentationView insertText:(NSString *)text
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    static const NSUInteger MAX_LENGHT = 40;
    if (self.selectedWord.word.length < MAX_LENGHT) {
        self.selectedWord.word = [self.selectedWord.word stringByAppendingString:text];
    }
    
    [self.wordDiaryRepresentation setNeedsDisplay];
}

- (void)keyboardDoneOnWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    [self.wordDiaryRepresentation resignFirstResponder];
}

- (void)shakeOnWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    if (self.selectedWord.word.length > 0) {
        self.selectedWord.word = @"";
    }
}

#pragma mark - WDWordRepresentationViewDataSource

- (NSString *)actualTextValueForWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    return self.selectedWord.word;
}

- (NSString *)actualFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    return self.selectedWord.style.familyFont;
}

- (BOOL)isInWritingModeFoWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    return self.keyboardActive;
}

- (UIColor *)actualSelectedWordColorForWordRepresentation:(WDWordRepresentationView *)wordRepresentation
{
    WDPalette *palette = [self.selectedWord.emotion findPaletteOfIdName:self.selectedWord.paletteIdNameOfEmotion];
    return [UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
}

- (UIColor *)actualSelectedWordAccessoriesWordRepresentation:(WDWordRepresentationView *)wordRepresentation
{
    WDPalette *palette = [self.selectedWord.emotion findPaletteOfIdName:self.selectedWord.paletteIdNameOfEmotion];
    return [UIColor colorWithHexadecimalValue:palette.accessoriesColor withAlphaComponent:NO skipInitialCharacter:NO];
}

#pragma mark - App iOS events

- (void)resign
{
    [WDUtils pauseLayer:self.actualGradientBackground.layer];
    [WDUtils pauseLayer:self.nextGradientBackground.layer];
    
    self.dayChangePendingToResolve = NO;
    [self endCursorUpdateTimer];
    [self.dayChecker pause];
    [self.backgroundTimer fire];
    [self endBackgroundTimer];
    
    self.appWasResigned = YES;
}

- (void)didEnterBackground
{
    // Nota: Por algun extraño motivo, cuando se pasa todo a background se dispara antes el timer asociado a la transicion entre palabras
    // que los eventos resign o pause y no da lugar a controlar que hacer desde aqui por lo que al dispararse el timer se mandan ordenes para
    // activar las animaciones. Metemos este codigo controlado
    if (self.backgroundSwipeView) {
        [self.backgroundSwipeView.layer removeAllAnimations];
        [self.actualGradientBackground.layer removeAllAnimations];
        [self.dayMonthDateTopInfoLabel.layer removeAllAnimations];
        [self.wordDiaryRepresentation.layer removeAllAnimations];
    }

    [self hideMainMenuInmediate];
    [self.wordDiaryRepresentation resignFirstResponder];

    [[WDWordDiary sharedWordDiary] saveAll];
}

- (void)willEnterForeground
{
   // ...
}

- (void)didBecomeActive
{
    if (self.appWasResigned) {
        [WDUtils resumeLayer:self.actualGradientBackground.layer];
        [WDUtils resumeLayer:self.nextGradientBackground.layer];
        
        BOOL updateBackground = NO;
        if (nil == self.selectedWord || ![self.selectedWord isTodayWord]) {
            self.selectedWord = [self selectWordOfWordDiaryAtLaunchOrResume];
            [self startBackgroundTimer:0];
            updateBackground = YES;
        }
        [self startCursorUpdateTimer];
        [self.dayChecker resume];
        [self configureViewForSelectedWord:updateBackground];
        
        self.appWasResigned = NO;
    }
}

- (void)terminate
{
    [[WDWordDiary sharedWordDiary] saveAll];
}

#pragma mark - DayCheckerDelegate

- (void)dayCheckerOnNewDay:(WDDayChecker *)dayChecker
{
    if (!self.keyboardActive && self.editMenuViewController.view.hidden) {
        [self updateByDayChange];
    } else {
        self.dayChangePendingToResolve = YES;
    }
}

@end
