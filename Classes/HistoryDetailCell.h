//
//  HistoryDetailCell.h
//  OrderList
//
//  Created by fly on 10/11/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HistoryDetailCellDelegate;
@interface HistoryDetailCell : UITableViewCell 
{
	id<HistoryDetailCellDelegate> delegate;
	
	NSString		*_foodCD;
	IBOutlet UILabel *_foodName;
	IBOutlet UILabel *_foodPrice;
	IBOutlet UILabel *_foodCount;
	IBOutlet UILabel *_foodShopName;
}



@property(nonatomic,retain)	NSString *_foodCD;
@property(nonatomic,retain) UILabel *_foodName;
@property(nonatomic,retain) UILabel *_foodPrice;
@property(nonatomic,retain) UILabel *_foodCount;
@property(nonatomic,retain) UILabel *_foodShopName;
@property(nonatomic,assign) id<HistoryDetailCellDelegate> delegate;

- (IBAction)btnHisCellClick:(id)sender;
@end




@protocol HistoryDetailCellDelegate
- (void)appendHistRecord:(HistoryDetailCell *)cell;
@end