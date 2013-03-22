//
//  CustomerAndOrderController.h
//  OrderLists
//
//  Created by fly on 12/10/22.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryDetailCell.h"
#import "common.h"

@protocol CustomerAndOrderDelegate;

@interface CustomerAndOrderController : UIViewController<UITableViewDelegate,UITableViewDataSource,HistoryDetailCellDelegate> {
    
    id<CustomerAndOrderDelegate>delegate;
    
    IBOutlet UITableView *_tableView;
    IBOutlet UIView *showView;
    
    IBOutlet UITextField *textFieldName;
    IBOutlet UITextField *textFieldPhone;
    IBOutlet UITextField *textFieldCompany;
    IBOutlet UITextView *textViewNG;
    IBOutlet UITextView *textViewRemark;
    
    NSString *memberCD;
    NSMutableDictionary *memberInfoDic;
    NSMutableArray *historyDetailArr;
}

@property(nonatomic,assign) id<CustomerAndOrderDelegate>delegate;

@property(nonatomic,retain) IBOutlet UITableView *_tableView;
@property(nonatomic,retain) IBOutlet UIView *showView;

@property(nonatomic,retain) IBOutlet UITextField *textFieldName;
@property(nonatomic,retain) IBOutlet UITextField *textFieldPhone;
@property(nonatomic,retain) IBOutlet UITextField *textFieldCompany;

@property(nonatomic,retain) IBOutlet UITextView *textViewNG;
@property(nonatomic,retain) IBOutlet UITextView *textViewRemark;

@property(nonatomic,retain) NSString *memberCD;
@property(nonatomic,retain) NSMutableDictionary *memberInfoDic;
@property(nonatomic,retain) NSMutableArray *historyDetailArr;


- (IBAction) close:(id)sender;
- (IBAction) updateMember:(id)sender;
- (IBAction) showOrHiddenView:(id)sender;

- (void) GetMemberInfoByCD:(NSString *)memCD;
- (void) PasteMemberXml:(NSString *) str;
- (void) GetHistoryDetailByMemberCD:(NSString *)memCD MemberName:(NSString *)memberName MemberPhone:(NSString *)phone;
- (void) PasteHistoryDetailXml:(NSString *)str;
- (void) InitMember;

@end


@protocol CustomerAndOrderDelegate <NSObject>

- (void) CloseCustomerAndOrder:(CustomerAndOrderController *) controller;

@end