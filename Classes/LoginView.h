//
//  LoginView.h
//  MasterDetail
//
//  Created by fly on 10/11/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewDelegate;

@interface LoginView : UIViewController {
	id<LoginViewDelegate> delegate;
	IBOutlet UITextField  *loginID;
	IBOutlet UITextField  *loginPwd;

}

@property(nonatomic,retain) UITextField *loginID;
@property(nonatomic,retain) UITextField *loginPwd;
@property(nonatomic,assign) id<LoginViewDelegate> delegate;

- (IBAction)Login:(id)sender;
- (BOOL) getShopIdByUserId:(NSString	*)UserId;
@end



@protocol LoginViewDelegate
- (void) addViewControllDidFinishConform:(LoginView *)controller;
@end