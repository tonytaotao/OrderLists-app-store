//
//  MasterDetailAppDelegate.h
//  MasterDetail
//
//  Created by Andreas Katzian on 15.05.10.
//  Copyright Blackwhale GmbH 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUISplitViewController.h"
#import "LoginView.h"

@interface MasterDetailAppDelegate : NSObject <UIApplicationDelegate,LoginViewDelegate> {
    UIWindow *window;
    CustomUISplitViewController *spViewController;
    LoginView *loginViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CustomUISplitViewController *spViewController;
@property (nonatomic,retain)  LoginView *loginViewController;
@end

