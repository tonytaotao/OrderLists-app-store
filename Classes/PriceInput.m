//
//  PriceInput.m
//  TabNavi
//
//  Created by sat on 6/11/10.
//  Copyright 2010 Saturn. All rights reserved.
//

#import "PriceInput.h"

void ShowRect( NSString* pTitle, CGRect p ) 
{
	NSLog( @"%@ x:%f y:%f w:%f H:%f", pTitle, p.origin.x, p.origin.y, p.size.width, p.size.height );
}

@implementation PriceInput
@synthesize	keyboard = mKeyboard;
@synthesize delegate;
static	UIButton*		s = nil;

- (void)ReceivedNotification:(NSNotification*)p 
{
	int	w = [ [ p.userInfo valueForKey:@"UIWindowNewOrientationUserInfoKey" ] intValue ];
	
	if ( s == nil ) return;
	
	mKeyboard.transform = CGAffineTransformMake( 1, 0, 0, 1, 0, 0 );
	switch ( w ) 
	{
//		case 	UIInterfaceOrientationPortrait:
//			mKeyboard.center = CGPointMake( 160, 480 - ( mKeyboard.frame.size.height / 2 ) );
//			break;
//		case	UIInterfaceOrientationPortraitUpsideDown:
//			mKeyboard.center = CGPointMake( 160, mKeyboard.frame.size.height / 2 );
//			mKeyboard.transform = CGAffineTransformRotate( mKeyboard.transform, M_PI );
//			break;
			
		case	UIInterfaceOrientationLandscapeLeft:
			mKeyboard.center = CGPointMake( 320 - ( mKeyboard.frame.size.height / 2 ), 240 );
			mKeyboard.transform = CGAffineTransformRotate( mKeyboard.transform, - M_PI / 2 );
			break;
			
//		case	UIInterfaceOrientationLandscapeRight:
//			mKeyboard.center = CGPointMake( mKeyboard.frame.size.height / 2, 240 );
//			mKeyboard.transform = CGAffineTransformRotate( mKeyboard.transform, M_PI / 2 );
//			break;
	}
}


-	(void)awakeFromNib {
	
	self.userInteractionEnabled = YES;
	
	[ [ NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(ReceivedNotification:) name:@"UIWindowWillAnimateRotationNotification" object:nil ];	
//	[ [ NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(Dismiss:) name:@"UIApplicationWillResignActiveNotification" object:nil ];	
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[ mKeyboard removeFromSuperview ];
	[ s removeFromSuperview ];
}

-	(IBAction)Dismiss:(id)p 
{
	NSInteger	srCount=[s	retainCount];
	if(srCount==0)
		return;

	[ UIView beginAnimations:nil context:nil ];
	[ UIView setAnimationDuration:.2 ];
	[ UIView setAnimationDelegate:self ];
	[ UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:) ];
	
	switch ( [ UIApplication sharedApplication ].statusBarOrientation ) 
	{
//		case 	UIInterfaceOrientationPortrait:
//			s.frame = CGRectMake( 0, 480, 320, 480 );
//			break;
//		case	UIInterfaceOrientationPortraitUpsideDown:
//			s.frame = CGRectMake( 0, -480, 320, 480 );
//			break;
		case	UIInterfaceOrientationLandscapeLeft:
			s.frame = CGRectMake( 768, 0, 768, 1024 );
			break;
//		case	UIInterfaceOrientationLandscapeRight:
//			s.frame = CGRectMake( -320, 0, 320, 480 );
//			break;
	}
	[ UIView commitAnimations ];
}

-	(IBAction)Complete:(id)p 
{
	self.titleLabel.text = mKeyboard.label.text;
	[ self setTitle:mKeyboard.label.text forState:UIControlStateNormal ];
	[ self Dismiss:p ];
	[delegate priceInputDidClose:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	[ super touchesEnded:touches withEvent:event ];

	s = [ [ [ UIButton alloc ] initWithFrame:self.window.frame ] autorelease ];
	[ s addTarget:self action:@selector(Dismiss:) forControlEvents:UIControlEventTouchUpInside ];
	
	s.backgroundColor = [ UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5 ];
	[ self.window addSubview:s ];
	
	[ [ NSBundle mainBundle ] loadNibNamed:@"PriceKeyboard" owner:self options:nil ];

//	mKeyboard.label.text = self.titleLabel.text;
	if ( mKeyboard.label.text == nil ) mKeyboard.label.text = @"";
	
//	if ( [ mKeyboard.label.text compare:@"" ] == 0 ) 
//	{
//		if ( [ delegate respondsToSelector:@selector(PriceInputDefaultValue:) ] ) 
//		{
//			mKeyboard.label.text = [ delegate PriceInputDefaultValue:self ];
//		}
//	}
	
//	mKeyboard.commaInputed = [ mKeyboard.label.text rangeOfString:@"." ].location != NSNotFound;
	
	[ s addSubview:mKeyboard ];
	mKeyboard.frame = CGRectMake( 300, 1024 - mKeyboard.frame.size.height, mKeyboard.frame.size.width, mKeyboard.frame.size.height );


	switch ( [ UIApplication sharedApplication ].statusBarOrientation ) 
	{
//		case 	UIInterfaceOrientationPortrait:
//			s.frame = CGRectMake( 0, 480, 320, 480 );
//			break;
			
//		case	UIInterfaceOrientationPortraitUpsideDown:
//			mKeyboard.center = CGPointMake( 160, mKeyboard.frame.size.height / 2 );
//			mKeyboard.transform = CGAffineTransformRotate( mKeyboard.transform, M_PI );
//			s.frame = CGRectMake( 0, -480, 320, 480 );
//			break;
			
		case	UIInterfaceOrientationLandscapeLeft:
			mKeyboard.center = CGPointMake( 600 - ( mKeyboard.frame.size.height / 2 ), 300 );
			mKeyboard.transform = CGAffineTransformRotate( mKeyboard.transform, - M_PI / 2 );
			s.frame = CGRectMake( 768, 0, 768, 1024 );
			break;
			
//		case	UIInterfaceOrientationLandscapeRight:
//			mKeyboard.center = CGPointMake( mKeyboard.frame.size.height / 2, 240 );
//			mKeyboard.transform = CGAffineTransformRotate( mKeyboard.transform, M_PI / 2 );
//			s.frame = CGRectMake( -320, 0, 320, 480 );
//			break;
	}
	
	if (![delegate	priceInputClick:self])   //NO  KeyBoard to Show;   YES  NotShow
	{
		[ UIView beginAnimations:nil context:nil ];
		[ UIView setAnimationDuration:.2 ];
		s.frame = self.window.frame;
		[ UIView commitAnimations ];
	}	
}

@end


@implementation PriceKeyboard

@synthesize	label = mLabel;
//@synthesize	commaInputed = mCommaInputed;

-	(IBAction)Number0:(id)p 
{
	if ( mLabel.text.length < 25 ) {
		//if ( mLabel.text.length ) mLabel.text = [ NSString stringWithFormat:@"%@0", mLabel.text ];
		mLabel.text = [ NSString stringWithFormat:@"%@0", mLabel.text ];
	}
}
-	(IBAction)Number1:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@1", mLabel.text ];
}
-	(IBAction)Number2:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@2", mLabel.text ];
}
-	(IBAction)Number3:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@3", mLabel.text ];
}
-	(IBAction)Number4:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@4", mLabel.text ];
}
-	(IBAction)Number5:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@5", mLabel.text ];
}
-	(IBAction)Number6:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@6", mLabel.text ];
}
-	(IBAction)Number7:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@7", mLabel.text ];
}
-	(IBAction)Number8:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@8", mLabel.text ];
}
-	(IBAction)Number9:(id)p {
	if ( mLabel.text.length < 25 ) mLabel.text = [ NSString stringWithFormat:@"%@9", mLabel.text ];
}
-	(IBAction)Comma:(id)p {
	if ( mLabel.text.length < 25 ) {
		/*if ( ! mCommaInputed ) {
			mLabel.text = mLabel.text.length == 0 ? @"0-" : [ NSString stringWithFormat:@"%@.", mLabel.text ];
			mCommaInputed = YES;
		}*/
		mLabel.text = [ NSString stringWithFormat:@"%@-", mLabel.text ];
	}
}

//最後の文字を削除する
- (IBAction)backClear:(id)sender
{
	int strLength = [mLabel.text length];
	if(strLength>1)
		mLabel.text= [mLabel.text substringWithRange:NSMakeRange(0,strLength-1)];
	else 
		mLabel.text=@"";
	

}

-	(IBAction)Clear:(id)p {
	mLabel.text = @"";
//	mCommaInputed = NO;
}
/*
-	(IBAction)Complete:(id)p {
	[ mPriceInput Complete:p ];
}
*/
@end
