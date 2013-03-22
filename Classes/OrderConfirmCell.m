//
//  OrderConfirmCell.m
//  OrderList
//
//  Created by fly on 10/11/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OrderConfirmCell.h"
#import "PriceInput.h"

@implementation OrderConfirmCell
@synthesize _foodName;
@synthesize _foodPrice;
@synthesize _foodCount;

@synthesize _foodPlus;
@synthesize _foodMinus;
@synthesize number;

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

 

//plus the count
- (IBAction)btnPlus:sender
{
	[delegate orderConfirmCellDidPlus:self];
	
//	NSInteger tempCount =[_foodCount.text intValue];
//	_foodCount.text = [NSString stringWithFormat:@"%d",(tempCount +1)];
}

//minus the count
- (IBAction)btnMinus:sender
{
	
	NSInteger tempCount =[_foodCount.titleLabel.text intValue];
	     
	if (tempCount > 1) {
//		_foodCount.text = [NSString stringWithFormat:@"%d",(tempCount -1)];
		[delegate orderConfirmCellDidMinus:self];
	}
	
}


#pragma mark --PriceInput delegate--
- (void)priceInputDidClose:(PriceInput *)prieInput
{
	[delegate orderConfirmCellDidInput:self];
}

- (BOOL)priceInputClick:(PriceInput	*)prieInput
{
	return NO;
}

- (void)dealloc 
{
	[_foodName release];
	[_foodPrice release];
	[_foodCount release];
	
	[_foodPlus release];
	[_foodMinus release];
    [super dealloc];
}


@end
