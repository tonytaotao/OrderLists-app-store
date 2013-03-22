//
//  FreeRoomController.h
//  OrderLists
//
//  Created by fly on 12/10/10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"

@protocol FreeRoomDelegate;


@interface FreeRoomController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    
    //代理
    id<FreeRoomDelegate> delegate;
    
    //显示桌位信息的table
    IBOutlet UITableView *_tableView;
    //日期选择按钮
    IBOutlet UIButton *btnDate;
    //昼夜选择按钮
    IBOutlet UISegmentedControl *segmentedDayNig;
    
    UIButton *btnDateSelectCan;
    
    UIDatePicker *theDatePicker;
    NSString *selectedDate;
    NSString *selectedShopId;
    NSInteger selectedDayNig;
    
    NSMutableArray *allRoomList;
    
}

@property(nonatomic,assign) id<FreeRoomDelegate> delegate;

@property(nonatomic,retain) IBOutlet UITableView *_tableView;
//日期选择按钮
@property(nonatomic,retain) IBOutlet UIButton *btnDate;
//昼夜选择按钮
@property(nonatomic,retain) IBOutlet UISegmentedControl *segmentedDayNig;
@property(nonatomic,retain) UIButton *btnDateSelectCan;
@property(nonatomic,retain) UIDatePicker *theDatePicker;

@property(nonatomic,retain) NSString *selectedDate;
@property(nonatomic,retain) NSString *selectedShopId;
@property(nonatomic,assign) NSInteger selectedDayNig;

@property(nonatomic,retain) NSMutableArray *allRoomList;

//确定按钮
- (IBAction) search:(id) sender;
//日期选择
- (IBAction) selectDate:(id) sender;
//
- (IBAction) close:(id)sender;

- (void)ChangeCalendar:(id) sender;
- (void)DismissCalendar:(id) sender;

//返回各店铺房间图的view
- (UITableViewCell *) AddRoomView:(NSArray *)rooms;

//获取所有店铺房间信息
- (void) GetAllRoomInfo:(NSString *)shopId SelectDate:(NSString *) date DayNight:(NSString *) dayNight;
//解析XML
- (void) PasteRoomInfo:(NSString *) str;

- (void) PasteOneShopRoom:(NSMutableDictionary *) dic;

//房间绘制
- (UIColor *) ParseColor:(NSString *)strColor;
- (void) DrawMaster:(UIView *)view Text:(NSString *)info FontSize:(UIFont *)font Frame:(CGRect)frame Color:(UIColor *)color;

- (void) DrawMasterRoom:(UIView *)view Element:(CXMLElement *)roomItemElement;

- (void) DrawMasterSetItem:(UIView *)view Element:(CXMLElement *)_roomSetItem bginPos:(int)beginPos count:(int)count;

- (int)memberCount :(NSArray *)isShowArr;

- (int)memberBeginPos:(NSArray *)isShowArr;

@end

@protocol FreeRoomDelegate <NSObject>

- (void) CloseFreeRoomController:(FreeRoomController *) controller;

@end