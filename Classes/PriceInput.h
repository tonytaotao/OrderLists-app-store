//
//  PriceInput.h
//  TabNavi
//
//  Created by sat on 6/11/10.
//  Copyright 2010 Saturn. All rights reserved.
//

@class	PriceInput;

@interface PriceKeyboard : UIView 
{
	UILabel*			mLabel;	
}

@property	( nonatomic, retain )	IBOutlet	UILabel*	label;

-	(IBAction)Number0:(id)p;
-	(IBAction)Number1:(id)p;
-	(IBAction)Number2:(id)p;
-	(IBAction)Number3:(id)p;
-	(IBAction)Number4:(id)p;
-	(IBAction)Number5:(id)p;
-	(IBAction)Number6:(id)p;
-	(IBAction)Number7:(id)p;
-	(IBAction)Number8:(id)p;
-	(IBAction)Number9:(id)p;
-	(IBAction)Clear:(id)p;
-	(IBAction)backClear:(id)sender;
-	(IBAction)Comma:(id)p;

@end




@protocol  PriceInputDelegate;
@interface PriceInput : UIButton 
{
	PriceKeyboard*				mKeyboard;
	id<PriceInputDelegate>		delegate;
}
@property	( nonatomic, assign )	IBOutlet	id<PriceInputDelegate> delegate;
@property	( nonatomic, retain )	IBOutlet	PriceKeyboard*		keyboard;

-	(IBAction)Complete:(id)p;

@end



@protocol PriceInputDelegate
- (BOOL)priceInputClick:(PriceInput	*)prieInput;
- (void)priceInputDidClose:(PriceInput *)prieInput;
@end

