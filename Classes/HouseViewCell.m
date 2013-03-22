//
//  HouseViewCell.m
//  OrderLists
//
//  Created by fly on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HouseViewCell.h"
#import "common.h"



@implementation HouseViewCell
@synthesize number,cellStr;
@synthesize delegate;
@synthesize cellOrderId;
@synthesize cellColor;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (![common	requestDidError]) 
	{
		return;			
	}
	
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	
	switch (tapCount) 
	{
		case 1:
			[self performSelector:@selector(singleTap)
					   withObject:nil	//[NSNumber numberWithInteger:number]
					   afterDelay:.3];
			break;
			
		case  2:
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(singleTap)
													   object:nil];
			
			[self performSelector:@selector(doubleTap)
					   withObject:nil	//[NSNumber numberWithInteger:number]
					   afterDelay:.3];
			break;
			
		default:
			break;
	}
}

- (void)singleTap
{
//	NSLog(@"-----S------");
	[delegate singleTap:self];
}

- (void)doubleTap
{
//	NSLog(@"============D========");
	[delegate doubleTap:self];
}

- (void)dealloc 
{
	[cellStr release];
	[cellOrderId release];
	[cellColor release];
	[super dealloc];
}


@end
