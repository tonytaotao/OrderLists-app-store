//
//  SoapIPSet.h
//  OrderLists
//
//  Created by fly on 11/02/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SoapIPSet : UIViewController 
{
	IBOutlet UITextField *soapIPTextField;
}

@property(nonatomic,retain) UITextField *soapIPTextField;

-(IBAction)btnSet:(id)sender;
@end
