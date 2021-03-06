/**
	@file	BSHeadcountViewController.h
	@author	Carlin
	@date	8/21/13
	@brief	BillSplitter
*/
//  Copyright (c) 2013 Carlin. All rights reserved.


#import <UIKit/UIKit.h>

#import "UIVerticalStepper.h"

@interface BSHeadcountViewController : UIViewController <
	UIVerticalStepperDelegate
>

	@property (nonatomic, strong) UILabel *taglineLabel;
	@property (nonatomic, strong) UILabel *welcomeLabel;
	@property (strong, nonatomic) UIImageView *imageView;
	@property (strong, nonatomic) UITextField *textField;
	@property (nonatomic, strong) UIVerticalStepper *stepper;
       
    @property (nonatomic, strong) UIButton *instructionButton;

	/** @brief Init in screen frame */
	- (id)initWithFrame:(CGRect)frame;

@end
