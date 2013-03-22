//
//  SearchCustomerController.h
//  OrderLists
//
//  Created by fly on 12/10/10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@protocol SearchCustomerControllerDelegate;

@interface SearchCustomerController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    id<SearchCustomerControllerDelegate> delegate;
    
    //关键字
    IBOutlet UITextField *textFieldKey;
    //显示数据table
    IBOutlet UITableView *_tableView;
    
    NSMutableArray *customerList;
    NSMutableDictionary *customerInfo;
}

@property(nonatomic,assign) id<SearchCustomerControllerDelegate> delegate;

@property(nonatomic,retain) IBOutlet UITextField *textFieldKey;
@property(nonatomic,retain) IBOutlet UITableView *_tableView;

@property(nonatomic,retain) NSMutableArray *customerList;
@property(nonatomic,retain) NSMutableDictionary *customerInfo;


//检索
- (IBAction) search:(id)sender;
//关闭
- (IBAction) close:(id)sender;

//获取客户信息
- (void) GetCustomerList:(NSString *) key;
//解析xml
- (void) PasteCustomerList:(NSString *) str;
//调用查询功能
- (void) searchCommon;
@end


@protocol SearchCustomerControllerDelegate <NSObject>

- (void)SearchCustomerControllerDidClose:(SearchCustomerController *)controller;

@end