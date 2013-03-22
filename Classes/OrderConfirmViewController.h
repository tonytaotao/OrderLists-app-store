//
//  OrderConfirmViewController.h
//  OrderList
//
//  Created by fly on 10/11/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderConfirmCell.h"

@protocol OrderConfirmViewControllerDelegate;

@interface OrderConfirmViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,OrderConfirmCellDelegate>
{
	id<OrderConfirmViewControllerDelegate> delegate;
	NSMutableArray *records;

	IBOutlet UITableView *_tableView;
	
	IBOutlet UIScrollView *_leftScrollView;
	IBOutlet UIScrollView *_topScrollView;
	IBOutlet UIScrollView *_contentScrollView;
	
	NSString			 *shopId;
	
}

@property(nonatomic,assign)id<OrderConfirmViewControllerDelegate> delegate;
@property(nonatomic,retain) UITableView  *_tableView;

@property(nonatomic,retain) UIScrollView *_leftScrollView;
@property(nonatomic,retain) UIScrollView *_topScrollView;
@property(nonatomic,retain) UIScrollView *_contentScrollView;


@property(nonatomic,retain) NSMutableArray *records;
@property(nonatomic,retain) NSString       *shopId;


- (IBAction)btnClose:(id)sender;			//close this view
@end




@protocol OrderConfirmViewControllerDelegate
- (void)OrderConfirmViewControllerDidClose:(OrderConfirmViewController *)controller;
@end