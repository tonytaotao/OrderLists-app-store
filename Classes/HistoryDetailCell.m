//
//  HistoryDetailCell.m
//  OrderList
//
//  Created by fly on 10/11/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HistoryDetailCell.h"


@implementation HistoryDetailCell

@synthesize _foodName;
@synthesize _foodPrice;
@synthesize _foodCount;
@synthesize _foodShopName;
@synthesize delegate;
@synthesize _foodCD;

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

//cell click
- (IBAction)btnHisCellClick:(id)sender
{
	[delegate appendHistRecord:self];
}

- (void)dealloc 
{	
	[_foodName release];
	[_foodPrice release];
	[_foodCount release];
	
    [super dealloc];
}


@end
