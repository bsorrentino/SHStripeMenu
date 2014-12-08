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

- (id)initWithController:(UIViewController *)rootViewController filePath:(NSString *)filePath;

@end