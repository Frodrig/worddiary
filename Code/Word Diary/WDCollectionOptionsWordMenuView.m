//
//  WDCollectionOptionsWordMenuView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 11/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDCollectionOptionsWordMenuView.h"

@interface WDCollectionOptionsWordMenuView()

@property (nonatomic, strong)  NSArray      *titles;
@property (nonatomic, strong)  NSArray      *titlesFonts;
@property (nonatomic, strong)  NSArray      *images;
@property (nonatomic, strong)  UIButton     *backButton;
@property (nonatomic, weak)    UIScrollView *optionsScrollView;
@property (nonatomic, weak)    UIButton     *actualSelectedOption;
@property (nonatomic,readonly) NSUInteger   numOptions;

- (void)       createCollectionOfOptionsWithOptionSelectedAtIndex:(NSUInteger)selectedOptionIndex andNumberOfVisibleOptions:(CGFloat)numVisibleOptions;

- (void)       optionSelected:(UIButton *)option;

- (void)       highlightOption:(UIButton *)option;

@end

@implementation WDCollectionOptionsWordMenuView

#pragma mark - Synthesize

@synthesize delegate             = delegate_;
@synthesize titles               = titles_;
@synthesize titlesFonts          = titlesFonts_;
@synthesize images               = images_;
@synthesize optionsScrollView    = optionsScrollView_;
@synthesize actualSelectedOption = actualSelectedOption_;
@synthesize buttonOptions        = buttonOptions_;
@synthesize numOptions           = numOptions_;
@synthesize backButton           = backButton_;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
       optionTitles:(NSArray *)titles
     fontsForTitles:(NSArray *)titlesFonts
       optionImages:(NSArray *)images
     visibleOptions:(CGFloat)numVisibleOptions
  andSelectedOption:(NSUInteger)selectedOption;
{
    NSAssert(titles != nil && images != nil ? titles.count == images.count : YES, @"El array de titulos e imagenes han de tener el mismo tamaño");
    NSAssert(titles != nil ? titlesFonts != nil && titlesFonts.count == titles.count : YES, @"Si hay titulos, el array de fuentes tiene que existir y ser coincidente en tamaño");
    NSAssert(titles != nil || images != nil ? selectedOption != NSNotFound : YES, @"El indice a la opcion seleccionada no tiene un valor valido");
    
    self = [super initWithFrame:frame];
    if (self) {
        titles_ = titles ? [NSArray arrayWithArray:titles] : nil;
        titlesFonts_ = titlesFonts ? [NSArray arrayWithArray:titlesFonts] : nil;
        images_ = images ? [NSArray arrayWithArray:images] : nil;
        if (numOptions_ == 0) {
            numOptions_ = titles_ ? titles_.count : images_.count;
        }
        
        [self createCollectionOfOptionsWithOptionSelectedAtIndex:selectedOption andNumberOfVisibleOptions:numVisibleOptions];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame notConfiguredOptions:(NSUInteger)numNotConfiguredOptions visibleOptions:(CGFloat)numVisibleOptions andSelectedOption:(NSUInteger)selectedOption
{
    NSAssert(numNotConfiguredOptions > 0, @"Al menos ha de existir una opcion aun no configurada");
    
    numOptions_ = numNotConfiguredOptions;
    return [self initWithFrame:frame optionTitles:nil fontsForTitles:nil optionImages:nil visibleOptions:numVisibleOptions andSelectedOption:selectedOption];
}

- (void)createCollectionOfOptionsWithOptionSelectedAtIndex:(NSUInteger)selectedOptionIndex andNumberOfVisibleOptions:(CGFloat)numVisibleOptions;
{
    // Backbutton
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"39-back-dark"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0.0, 0.0, 44.0, self.bounds.size.height);
    [self.backButton addTarget:self action:@selector(backButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.backButton];
    
    // Scroll view
    const CGPoint scrollViewStartPosition = CGPointMake(self.backButton.frame.origin.x + self.backButton.bounds.size.width, 0.0);
    const CGFloat scrollViewWidth = self.bounds.size.width - self.backButton.bounds.size.width;
    const NSUInteger buttonOptionsWidth = scrollViewWidth / numVisibleOptions;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollViewStartPosition.x, scrollViewStartPosition.y, scrollViewWidth, self.bounds.size.height)];
    scrollView.contentSize = CGSizeMake(buttonOptionsWidth * self.numOptions, self.bounds.size.height);
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.contentInset = UIEdgeInsetsMake(0, 5.0, 0, 5.0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.directionalLockEnabled = NO;
    [scrollView scrollRectToVisible:CGRectMake(buttonOptionsWidth * selectedOptionIndex, 10.0, scrollView.bounds.size.width, scrollView.bounds.size.height - 20.0) animated:NO];
    self.optionsScrollView = scrollView;
    [self addSubview:scrollView];
    
    // Opciones de coleccion
    NSMutableArray *optionsContainer = [NSMutableArray arrayWithCapacity:self.numOptions];
    for (NSUInteger optionIt = 0; optionIt < self.numOptions; ++optionIt) {
        NSString *title = [self.titles objectAtIndex:optionIt];
        NSString *titleFont = [self.titlesFonts objectAtIndex:optionIt];
        NSString *image = [self.images objectAtIndex:optionIt];
        
        UIButton *option = [UIButton buttonWithType:UIButtonTypeCustom];
        option.frame = CGRectMake(optionIt * buttonOptionsWidth, 10.0, buttonOptionsWidth, scrollView.bounds.size.height - 20.0);
        if (title) {
            [option setTitle:title forState:UIControlStateNormal];
            option.titleLabel.font = [UIFont fontWithName:titleFont size:98.0];
            [option setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [option setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        }
        if (image) {
            [option setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        }
        option.adjustsImageWhenHighlighted = NO;
        //option.backgroundColor = optionIt % 2 == 0 ? [UIColor blackColor] : [UIColor redColor];
        option.tag = optionIt;
        
        if (optionIt == selectedOptionIndex) {
            [self highlightOption:option];
        }
        
        [option addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchDown];
        
        [scrollView addSubview:option];
        [optionsContainer addObject:option];
    }
    
    [scrollView scrollRectToVisible:CGRectNull animated:NO];
    
    buttonOptions_ = [NSArray arrayWithArray:optionsContainer];
}

#pragma mark - Auxiliary 

- (void)highlightOption:(UIButton *)option
{
    [self.actualSelectedOption setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [option setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.actualSelectedOption = option;
}

#pragma mark - Eventos de opciones

- (void)optionSelected:(UIButton *)option
{
    if (option != self.actualSelectedOption) {
        [self highlightOption:option];

        [self.delegate collectionOptionsMenu:self optionSelected:option.tag];
    }
}

- (void)backButtonSelected:(UIButton *)option
{
    [self.delegate collectionOptionsMenuBackOptionSelected:self];
}



@end
