/**
	@file	BSDistributionViewController.m
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import "BSDistributionViewController.h"

@interface BSDistributionViewController ()

	@property (nonatomic, assign) CGRect frame;

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
		
		_imageViews = [[NSMutableArray alloc] init];
		_textFields = [[NSMutableArray alloc] init];
		_steppers = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - View Lifecycle

/** @brief Setup UI elements for viewing. */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.frame = self.frame;
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


#pragma mark - UI Setup


#pragma mark - UI Events


#pragma mark - Utility Functions


#pragma mark - Delegates


@end
