//
//  SHStripeMenuExecuter.m
//  SHStripeMenu
//
//  Created by Narasimharaj on 08/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import "SHStripeMenuExecuter.h"
#import "SHStripeMenuViewController.h"
#import "SHLineView.h"
#import "UIApplication+AppDimensions.h"

#define STRIPE_WIDTH 10

@interface SHStripeMenuExecuter () <UIGestureRecognizerDelegate, SHStripeMenuDelegate>

@property (nonatomic, strong) SHStripeMenuViewController					*stripeMenuViewController;
@property (nonatomic, strong) UIViewController                              *rootViewController;
@property (nonatomic, strong) UIView										*lineView;
@property (nonatomic, assign) BOOL											showingStripeMenu;
@property (nonatomic, strong) NSArray                                       *menuArray;

@end

@implementation SHStripeMenuExecuter

+ (instancetype) createInstance:(UIViewController *)rootViewController filePath:(NSString *)filePath
{
    SHStripeMenuExecuter *menu = [[SHStripeMenuExecuter alloc] initWithController:rootViewController filePath:filePath];
    
    return menu;
}

- (id)initWithController:(UIViewController *)rootViewController filePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        // Custom initialization
        //NSString	*filePath		= [[NSBundle mainBundle] pathForResource:@"menu_info" ofType:@"plist"];
        _menuArray		= [[NSArray alloc] initWithContentsOfFile:filePath];
        _rootViewController = rootViewController;
        if ([rootViewController conformsToProtocol:@protocol(SHStripeMenuActionDelegate)]) {
            
            _delegate = (id<SHStripeMenuActionDelegate>)rootViewController;
        }
        [self setStripes];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)setStripes
{
	[self createMenuView];
    [self setStripesView];
}

- (void)setStripesView
{
	NSInteger	numberOfItems	= [self.menuArray count];

	if (_lineView == nil)
	{
		_lineView = [[SHLineView alloc] initWithFrame:CGRectMake(0, ([UIApplication currentSize].height - ROW_HEIGHT * numberOfItems) / 2, STRIPE_WIDTH, ROW_HEIGHT * numberOfItems)];
		[_rootViewController.view addSubview:_lineView];
		_lineView.backgroundColor = [UIColor clearColor];

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stripesTapped:)];
        [tapRecognizer setDelegate:self];
        [_lineView addGestureRecognizer:tapRecognizer];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(stripesSwiped:)];
        [panRecognizer setDelegate:self];
        [_lineView addGestureRecognizer:panRecognizer];
    
    
    }
	else
		_lineView.frame = CGRectMake(0, ([UIApplication currentSize].height - ROW_HEIGHT * numberOfItems) / 2, STRIPE_WIDTH, ROW_HEIGHT * numberOfItems);
    
	[_rootViewController.view bringSubviewToFront:_lineView];

}

- (void)stripesTapped:(id)sender
{
	[self showStripeMenu];
}

- (void)stripesSwiped:(id)sender
{
	// Show menu only when swiped to right
	CGPoint velocity = [(UIPanGestureRecognizer *) sender velocityInView:[sender view]];

	if ([(UIPanGestureRecognizer *) sender state] == UIGestureRecognizerStateEnded)
		if (velocity.x > 0)
			[self showStripeMenu];
	// gesture went right
}

- (void)createMenuView
{
	if (_stripeMenuViewController == nil)
	{
		self.stripeMenuViewController			= [[SHStripeMenuViewController alloc] initWithNibName:@"SHStripeMenuViewController" bundle:nil];
		self.stripeMenuViewController.delegate	= self;
		[_rootViewController.view addSubview:self.stripeMenuViewController.view];
		[_stripeMenuViewController didMoveToParentViewController:_rootViewController];
		_stripeMenuViewController.view.frame = CGRectMake(-_rootViewController.view.frame.size.width, 0, _rootViewController.view.frame.size.width, _rootViewController.view.frame.size.height);
	}
}

- (UIView *)getMenuView
{
	[self createMenuView];
	// set up view shadows
	UIView *view = self.stripeMenuViewController.view;

	return view;
}

- (void)hideStripeMenu
{
	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
			_stripeMenuViewController.view.frame = CGRectMake (-_stripeMenuViewController.view.frame.size.width, 0, _stripeMenuViewController.view.frame.size.width, _stripeMenuViewController.view.frame.size.height);
		}
			completion			:^(BOOL finished) {
			if (finished)
			{
				self.showingStripeMenu = FALSE;
			}
		}
	];
	// show stripes
	[self setStripesView];
	CGRect lineViewFrame = _lineView.frame;

	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
			_lineView.frame = CGRectMake (0, lineViewFrame.origin.y, lineViewFrame.size.width, lineViewFrame.size.height);
		}
			completion			:^(BOOL finished) {
			if (finished)
			{}
		}
	];
}

- (void)showStripeMenu
{
	UIView *childView = [self getMenuView];

	[_rootViewController.view bringSubviewToFront:childView];
	// show menu
	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
                _stripeMenuViewController.view.frame = CGRectMake (0, 0, [UIApplication currentSize].width, [UIApplication currentSize].height);
            }
			completion			:^(BOOL finished) {
                if (finished)
                {
                    self.showingStripeMenu = TRUE;
                }
            }
	];
	// hide stripes
	[self setStripesView];
	CGRect lineViewFrame = _lineView.frame;

	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
			_lineView.frame = CGRectMake (-STRIPE_WIDTH, lineViewFrame.origin.y, lineViewFrame.size.width, lineViewFrame.size.height);
		}
			completion			:^(BOOL finished) {
			if (finished)
			{}
		}
	];
}

- (void)hideMenu
{
	[self hideStripeMenu];
}

- (void)didRotate:(NSNotification *)notification
{
	if (!self.showingStripeMenu)
		[self setStripesView];
	[_stripeMenuViewController setTableView];
}

#pragma mark - SHStripeMenuActionDelegate.h implementation

- (void)itemSelected:(SHMenuItem *)item
{
    if (self.delegate) {
        [self.delegate stripeMenuItemSelected:item.name];
    }
    [self setStripesView];
}


@end