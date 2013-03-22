//
//  CategorySetting.h
//  OrderLists
//
//  Created by fly on 11/03/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategorySettingDelegate;
@interface CategorySetting : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
	id<CategorySettingDelegate> delegate;
	NSMutableArray			*records;
	IBOutlet UITableView *_tableView;
	
	IBOutlet UIScrollView *_leftScrollView;
	IBOutlet UIScrollView *_topScrollView;
	IBOutlet UIScrollView *_contentScrollView;
	
	NSString			 *shopId;
}

@property(nonatomic,assign) id<CategorySettingDelegate> delegate;
@property(nonatomic,retain) UITableView  *_tableView;

@property(nonatomic,retain) UIScrollView *_leftScrollView;
@property(nonatomic,retain) UIScrollView *_topScrollView;
@property(nonatomic,retain) UIScrollView *_contentScrollView;

@property(nonatomic,retain) NSMutableArray *records;
@property(nonatomic,retain) NSString       *shopId;

- (IBAction)btnOK:(id)sender;				//料理メニューを設定する
- (IBAction)btnClose:(id)sender;			//close this view
@end



@protocol CategorySettingDelegate
- (void)CategorySettingDidClose:(CategorySetting *)controller;
@end