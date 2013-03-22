//
//  HouseViewCell.h
//  OrderLists
//
//  Created by fly on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HouseViewCellDelegate;
@interface HouseViewCell : UITableViewCell 
{
	NSInteger	number;
	NSString	*cellStr;
	NSString *cellOrderId;
	NSString	*cellColor;
	id<HouseViewCellDelegate> delegate;

}
@property(nonatomic,readwrite)  NSInteger   number;
@property(nonatomic,retain)		NSString	*cellStr;
@property(nonatomic,retain) NSString * cellOrderId;
@property(nonatomic,retain) NSString * cellColor;
@property(nonatomic,assign) id<HouseViewCellDelegate> delegate;
@end

@protocol HouseViewCellDelegate
- (void)singleTap:(HouseViewCell *)cell;
- (void)doubleTap:(HouseViewCell *)cell;
@end