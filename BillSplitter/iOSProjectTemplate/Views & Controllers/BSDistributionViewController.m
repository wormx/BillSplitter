/**
	@file	BSDistributionViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDistributionViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CustomPageControl.h"

	#define TABLEVIEW_ROW_ID @"RowCell"

	#define ADD_BUTTON_SCALE_HOVER_OVER 1.2

	#define UI_SIZE_ITEM_HEADER (UI_SIZE_MIN_TOUCH * 2)

	#define UI_SIZE_PAGECONTROL_HEIGHT 24
	#define UI_SIZE_DINER_MARGIN 8
	#define UI_SIZE_MARGIN 16

	#define IMAGEVIEW_SCALE_SMALLDISH 0.7
	#define IMAGEVIEW_SCALE_MEDIUMDISH 0.8
	#define IMAGEVIEW_SCALE_LARGEDISH 1.0

	#define STEPPER_MIN_VALUE 0
	#define STEPPER_DEFAULT_VALUE 1
	#define STEPPER_DEFAULT_MAX_VALUE 2

	#define IMG_DINER @"man.png"
	#define IMG_DRINK @"drink.png"
	#define IMG_DISH @"plate.png"
	#define IMG_PLUS @"plus.png"

@interface BSDistributionViewController () <CustomPageControlDelegate>

	@property (nonatomic, assign) CGRect frame;

	/** For sideswipping between diners */
	@property (nonatomic, strong) UIScrollView *scrollView;
	@property (nonatomic, strong) CustomPageControl *pageControl;

@end


#pragma mark - Implementation

@implementation BSDistributionViewController

/** @brief Initialize data-related properties */
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
	{
		_frame = frame;
		
		_headCount = STEPPER_DEFAULT_MAX_VALUE;
		
		_addButton = [[UIButton alloc] init];
		
		_dishViews = [[NSMutableArray alloc] init];
		_buttons = [[NSMutableArray alloc] init];
		_textFields = [[NSMutableArray alloc] init];
		_steppers = [[NSMutableArray alloc] init];
		
		_descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.frame = self.frame;
	CGRect bounds = self.view.bounds;
	CGRect frame = CGRectZero;
	
	// UI Setup
	[self setupBackgroundView:bounds];
	[self setupDescriptionLabel:bounds];
	[self setupScrollView:bounds];
	[self setupPageControl:bounds];
	[self setupAddView:bounds];
	
	// Add first diner
	[self addDiner];
}

/** @brief Last-minute setup before view appears. */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

/** @brief Dispose of any resources that can be recreated. */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/** @brief Return supported orientations */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Class Functions

/** @brief Returns one of the steppers used */
- (RPVerticalStepper *)stepperForTextField:(UITextField *)textField
{
	int index = [self.textFields indexOfObject:textField];
	return (self.steppers.count && index != NSNotFound)
		? [self.steppers objectAtIndex:index] : nil;
}

/** @brief When setting the number of diners, also update steppers maxes */
- (void)setHeadCount:(int)headCount
{
	_headCount = headCount;
	
	// Update steppers
	[self updateSteppers];
}

/** @brief Current number of diner profiles set up */
- (int)profileCount
{
	return self.steppers.count;
}

/** @brief Current number of diners set up */
- (int)dinerCount
{
	int count = 0;
	for (RPVerticalStepper *stepper in self.steppers) {
		count += stepper.value;
	}
	return count;
}

/** @brief Updates all steppers with headCount as max */
- (void)updateSteppers
{
	for (RPVerticalStepper *stepper in self.steppers) {
		stepper.maximumValue = self.headCount;
	}
}

/** @brief Returns point offset for given page in scroll view */
- (CGFloat)offsetForPageInScrollView:(int)page
{
	return self.scrollView.bounds.size.width * page;
}

/** @brief Scrolls scrollview to page */
- (void)scrollToPage:(int)page
{
	[self.scrollView scrollRectToVisible:CGRectMake(
		[self offsetForPageInScrollView:page], 0,
		self.scrollView.bounds.size.width, self.scrollView.bounds.size.height
	) animated:true];
}

/** @brief Adds a new diner */
- (void)addDiner
{
	CGRect bounds = self.scrollView.bounds;
	CGRect frame = bounds;
	float itemSize = bounds.size.height - UI_SIZE_DINER_MARGIN * 2;
	
	// Container for elements
	frame.origin.x = [self offsetForPageInScrollView:[self profileCount]];
	frame.size.width -= UI_SIZE_MARGIN;
	UIView *containerView = [[UIView alloc] initWithFrame:frame];
	containerView.backgroundColor = [UIColor whiteColor];
	containerView.layer.shadowRadius = 4;
	containerView.layer.shadowOffset = CGSizeMake(0, 4);
	containerView.layer.shadowOpacity = 0.3;
	
	// Container for dishes
	UIView *dishView = [[UIView alloc] initWithFrame:CGRectMake(
		UI_SIZE_DINER_MARGIN, UI_SIZE_DINER_MARGIN, UI_SIZE_MIN_TOUCH, itemSize
	)];
	dishView.backgroundColor = [UIColor clearColor];
	[containerView addSubview:dishView];
	
	// Image button to drag items onto
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(
		UI_SIZE_DINER_MARGIN, UI_SIZE_DINER_MARGIN,
		bounds.size.width / 2, itemSize
	)];
	[button setImage:[UIImage imageNamed:IMG_DINER] forState:UIControlStateNormal];
	button.contentMode = UIViewContentModeScaleAspectFill;
	[button addTarget:self action:@selector(dinerItemDropped:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:self action:@selector(dinerItemHoveredOver:) forControlEvents:UIControlEventTouchDragEnter];
	[button addTarget:self action:@selector(dinerItemHoveredOut:) forControlEvents:UIControlEventTouchDragExit];
	[containerView addSubview:button];
	
	// Textfield for count of diners
	frame = button.frame;
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(
		frame.origin.x + frame.size.width, UI_SIZE_DINER_MARGIN,
		bounds.size.width / 4, itemSize / 2
	)];
	textField.font = [UIFont fontWithName:FONT_NAME_TEXTFIELD size:FONT_SIZE_HEADCOUNT];
	textField.textAlignment = NSTextAlignmentCenter;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.userInteractionEnabled = false;
	[containerView addSubview:textField];

	// Stepper for textfield
	frame = textField.frame;
	RPVerticalStepper *stepper = [[RPVerticalStepper alloc] init];
	stepper.frame = CGRectMake(
		containerView.bounds.size.width - stepper.frame.size.width - UI_SIZE_DINER_MARGIN,
		(frame.size.height - stepper.frame.size.height) / 2 + frame.origin.y,
		stepper.frame.size.width, stepper.frame.size.height
	);
	stepper.maximumValue = self.headCount;
	stepper.minimumValue = STEPPER_MIN_VALUE;
	stepper.value = ([self dinerCount] >= self.headCount)
		? 0 : STEPPER_DEFAULT_VALUE;
	stepper.delegate = self;
	textField.text = [NSString stringWithFormat:@"%i", (int)stepper.value];
	[containerView addSubview:stepper];
	
	// Keeping track of elements
	[self.textFields addObject:textField];
	[self.dishViews addObject:dishView];
	[self.buttons addObject:button];
	[self.steppers addObject:stepper];
	
	// Update page control & content size of scrollview
	self.pageControl.numberOfPages = [self profileCount];
	self.scrollView.contentSize = CGSizeMake(
		bounds.size.width * self.pageControl.numberOfPages, bounds.size.height);
	[self.scrollView addSubview:containerView];
}


#pragma mark - UI Setup

/** @brief Setup background view */
- (void)setupBackgroundView:(CGRect) bounds
{
	UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(
		0, UI_SIZE_ITEM_HEADER + bounds.size.height / 8,
		bounds.size.width, bounds.size.height * 1.15
	)];
	backgroundView.backgroundColor = UIColorFromHex(COLOR_HEX_ACCENT);
	[self.view addSubview:backgroundView];
}

/** @brief Setup description label */
- (void)setupDescriptionLabel:(CGRect) bounds
{
	self.descriptionLabel.text = NSLocalizedString(@"DISTRIBUTION_DESCRIPTION_TEXT", nil);
	self.descriptionLabel.numberOfLines = 0;
	self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.descriptionLabel.backgroundColor = [UIColor clearColor];
	self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
	self.descriptionLabel.textColor = [UIColor lightGrayColor];
	self.descriptionLabel.font = [UIFont fontWithName:FONT_NAME_COPY size:FONT_SIZE_COPY];
	self.descriptionLabel.frame = CGRectMake(
		UI_SIZE_MARGIN, UI_SIZE_ITEM_HEADER,
		bounds.size.width - UI_SIZE_MARGIN * 2, bounds.size.height / 8
	);
	
	[self.view addSubview:self.descriptionLabel];
}

/** @brief Setup scrollView */
- (void)setupScrollView:(CGRect)bounds
{
	CGRect frame = self.descriptionLabel.frame;
	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
		UI_SIZE_MARGIN,
		frame.origin.y + frame.size.height + UI_SIZE_PAGECONTROL_HEIGHT,
		bounds.size.width / 8 * 7 - UI_SIZE_MARGIN, bounds.size.height / 5 * 2
	)];
	self.scrollView.contentSize = CGSizeMake(bounds.size.width + 1, self.scrollView.bounds.size.height);
	self.scrollView.showsHorizontalScrollIndicator = false;
	self.scrollView.showsVerticalScrollIndicator = false;
	self.scrollView.directionalLockEnabled = true;
	self.scrollView.pagingEnabled = true;
	self.scrollView.clipsToBounds = false;
	self.scrollView.delegate = self;
	
	[self.view addSubview:self.scrollView];
}

/** @brief Setup page control */
- (void)setupPageControl:(CGRect)bounds
{
	CGRect frame = self.descriptionLabel.frame;
	self.pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(
		0, frame.origin.y + frame.size.height,
		bounds.size.width, UI_SIZE_PAGECONTROL_HEIGHT
	)];
	
	// Configure
	self.pageControl.delegate = self;
	self.pageControl.numberOfPages = 0;
	self.pageControl.currentPage = 0;
	self.pageControl.currentDotTintColor = UIColorFromHex(COLOR_HEX_COPY_DARK);
	self.pageControl.dotTintColor = UIColorFromHex(COLOR_HEX_BACKGROUND_LIGHT_TRANSLUCENT);
	
	// Set images
	
	[self.view addSubview:self.pageControl];
}

/** @brief Setup add view */
- (void)setupAddView:(CGRect)bounds
{
	self.addButton.frame = CGRectMake(
		bounds.size.width / 8 * 7, self.scrollView.frame.origin.y,
		bounds.size.width / 8, self.scrollView.bounds.size.height
	);
	[self.addButton setImage:[UIImage imageNamed:IMG_PLUS] forState:UIControlStateNormal];
	self.addButton.imageEdgeInsets = UIEdgeInsetsMake(
		UI_SIZE_DINER_MARGIN, UI_SIZE_DINER_MARGIN,
		UI_SIZE_DINER_MARGIN, UI_SIZE_DINER_MARGIN
	);
	self.addButton.layer.shadowRadius = 4;
	self.addButton.layer.shadowOffset = CGSizeMake(0, 4);
	self.addButton.layer.shadowOpacity = 0.3;
	self.addButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	// Gradient background
	CAGradientLayer *gradientBG = [CAGradientLayer layer];
	gradientBG.colors = [NSArray arrayWithObjects:
		(id)UIColorFromHex(0xFFFFFF11).CGColor,
		(id)UIColorFromHex(0xFFFFFFFF).CGColor,
		nil
	];
	gradientBG.transform = CATransform3DMakeRotation(
		degreesToRadians(-90), 0, 0, 1);
	gradientBG.frame = self.addButton.bounds;
	[self.addButton.layer insertSublayer:gradientBG atIndex:0];
//	self.addButton.backgroundColor = UIColorFromHex(COLOR_HEX_BACKGROUND_LIGHT_TRANSLUCENT);
	
	[self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.addButton addTarget:self action:@selector(addButtonHoverOver:) forControlEvents:UIControlEventTouchDragEnter];
	[self.addButton addTarget:self action:@selector(addButtonHoverOut:) forControlEvents:UIControlEventTouchDragExit];
	
	// Add gesture using swipe
	UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(addButtonSwiped:)];
	swipe.direction = UISwipeGestureRecognizerDirectionLeft;
	swipe.delaysTouchesBegan = false;
	swipe.delaysTouchesEnded = false;
	[self.addButton addGestureRecognizer:swipe];
	
	[self.view addSubview:self.addButton];
}


#pragma mark - UI Events

/** @brief Add button is not hovered over anymore */
- (void)addButtonHoverOut:(UIButton *)button
{
	[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
		options:UIViewAnimationOptionBeginFromCurrentState
			| UIViewAnimationOptionCurveEaseInOut
		animations:^{
			button.transform = CGAffineTransformIdentity;
		} completion:nil];
}

/** @brief Add button is hovered over */
- (void)addButtonHoverOver:(UIButton *)button
{
	[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
		options:UIViewAnimationOptionBeginFromCurrentState
			| UIViewAnimationOptionCurveEaseInOut
		animations:^{
			button.transform = CGAffineTransformMakeScale(ADD_BUTTON_SCALE_HOVER_OVER, ADD_BUTTON_SCALE_HOVER_OVER);
		} completion:nil];
}

/** @brief Add button is pressed / dropped */
- (void)addButtonPressed:(UIButton *)button
{
	[self addDiner];
	[self scrollToPage:[self profileCount] - 1];
}

/** @brief Add button is swiped on */
- (void)addButtonSwiped:(UISwipeGestureRecognizer *)gesture
{
	[self addDiner];
	[self scrollToPage:[self profileCount] - 1];
}

/** @brief Diner item not hovered */
- (void)dinerItemHoveredOut:(UIButton *)button
{
	[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
		options:UIViewAnimationOptionBeginFromCurrentState
			| UIViewAnimationOptionCurveEaseInOut
		animations:^{
			button.transform = CGAffineTransformIdentity;
		} completion:nil];
}

/** @brief Diner item hovered over */
- (void)dinerItemHoveredOver:(UIButton *)button
{
	[UIView animateWithDuration:ANIMATION_DURATION_FAST delay:0
		options:UIViewAnimationOptionBeginFromCurrentState
			| UIViewAnimationOptionCurveEaseInOut
		animations:^{
			button.transform = CGAffineTransformMakeScale(ADD_BUTTON_SCALE_HOVER_OVER, ADD_BUTTON_SCALE_HOVER_OVER);
		} completion:nil];
}

/** @brief Item dropped on diner */
- (void)dinerItemDropped:(UIButton *)button
{
	debugFunc(nil);
}


#pragma mark - Utility Functions


#pragma mark - Delegates
#pragma mark - CustomPageControlDelegate

- (void)pageControlPageDidChange:(CustomPageControl *)pageControl
{
	CGRect frame = self.scrollView.bounds;
	frame.origin.x = [self offsetForPageInScrollView:pageControl.currentPage];
	[self.scrollView scrollRectToVisible:frame animated:true];	
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Change page control accordingly:
	//	Update the page when more than 50% of the previous/next page is visible
    float pageSize = scrollView.bounds.size.width;
    int page = floor((scrollView.contentOffset.x - pageSize / 2) / pageSize) + 1;

	// Bound page limits
	if (page >= [self profileCount]) {
		page = [self profileCount] - 1;
	} else if (page < 0) {
		page = 0;
	}
		
    self.pageControl.currentPage = page;
}


#pragma mark - RPVerticalStepperDelegate

- (void)stepperValueDidChange:(RPVerticalStepper *)stepper
{
	int index = [self.steppers indexOfObject:stepper];
	[[self.textFields objectAtIndex:index] setText:[NSString
		stringWithFormat:@"%i", (int)stepper.value]];
}


@end
