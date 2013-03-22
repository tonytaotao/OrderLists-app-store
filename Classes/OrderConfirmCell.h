//
//  OrderConfirmCell.h
//  OrderList
//
//  Created by fly on 10/11/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderConfirmCellDelegate;

@interface OrderConfirmCell : UITableViewCell {
	id<OrderConfirmCellDelegate> delegate;
	
	IBOutlet UILabel *_foodName;
	IBOutlet UILabel *_foodPrice;
	IBOutlet UIButton *_foodCount;
	
	IBOutlet UIButton *_foodPlus;
	IBOutlet UIButton *_foodMinus;
	NSInteger	number;

}
@property(nonatomic,retain) UILabel *_foodName;
@property(nonatomic,retain) UILabel *_foodPrice;
@property(nonatomic,retain) UIButton *_foodCount;

@property(nonatomic,retain) UIButton *_foodPlus;
@property(nonatomic,retain) UIButton *_foodMinus;
@property(nonatomic,readwrite) NSInteger number;
@property(nonatomic,assign) id<OrderConfirmCellDelegate> delegate;

- (IBAction)btnPlus:sender;					//plus the count
- (IBAction)btnMinus:sender;				//minus the count
@end


@protocol OrderConfirmCellDelegate
- (void)orderConfirmCellDidPlus:(OrderConfirmCell *)cell;
- (void)orderConfirmCellDidMinus:(OrderConfirmCell *)cell;
- (void)orderConfirmCellDidInput:(OrderConfirmCell *)cell;
@end