//
//  SHStripeMenuExecuter.h
//  SHStripeMenu
//
//  Created by Narasimharaj on 08/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHStripeMenuActionDelegate.h"

@interface SHStripeMenuExecuter : NSObject

@property (nonatomic,assign) id <SHStripeMenuActionDelegate> delegate;

@property (nonatomic, strong) UIView						*lineView;

@property (nonatomic, copy) void (^cellForMenuBackgroundView)(UIView *backgroundView); // INITIALIZE CELL FOR MENU BACKGROUND VIEW

- (id)initWithController:(UIViewController *)rootViewController filePath:(NSString *)filePath;


@end