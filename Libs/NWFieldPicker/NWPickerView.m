//
//  NWPickerView.m
//  NWFieldPicker
//


#import "NWPickerView.h"
#import "NWPickerField.h"

@interface NWPickerField(PickerViewExtension)
// call in our picker field to now if control was hidden or not. Used
// to toggle indicator in the field.
-(void) pickerViewHidden:(BOOL)wasHidden;

@end

@implementation NWPickerView

@synthesize hiddenFrame;
@synthesize visibleFrame;
@synthesize field;

-(void) dealloc {
    field = nil;
    [super dealloc];
}


-(BOOL)resignFirstResponder 
{
	// when we resign the first responder we want to hide our selves.
    if (!self.hidden)
		[self toggle];
	
    // do what ever the control needs to do normally.
	return [super resignFirstResponder];
}

-(BOOL) canBecomeFirstResponder 
{
	// we need to allow this control to become the first responder
    // this allows us to hide what ever keyboards are up and allows us
    // to get a resign when we lose focus.
    return YES;
}

-(void) sendNotification:(NSString*) notificationName {
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSValue valueWithCGRect:self.bounds] forKey:UIPickerViewBoundsUserInfoKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self.field userInfo:userInfo];
}

-(void) toggle 
{
	if (self.hidden) 
	{
		self.hidden = NO;
		
        // this will toggle the indicator.
        [field pickerViewHidden:NO];
        
        // send the notification that we are about to show.
		[self sendNotification:UIPickerViewWillShownNotification];
		
        // set up our animation
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.25];
		[self setFrame:visibleFrame];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(slideInAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
		
        // become the first responder.
		[self becomeFirstResponder];
	}
	else 
	{
         // this will toggle the indicator.
        [field pickerViewHidden:YES];
        
        // send our notification that we are about to hide.
		[self sendNotification:UIPickerViewWillHideNotification];
		
        // setup our animation
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.25];
		[self setFrame:hiddenFrame];	
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(slideOutAnimationDidStop:finished:context:)];
		[UIView commitAnimations];

		[self becomeFirstResponder];
	}
	
}

- (void)slideOutAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.hidden = YES;
//    [self sendNotification:UIPickerViewDidHideNotification];
}

- (void)slideInAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self sendNotification:UIPickerViewDidShowNotification];
}


@end
