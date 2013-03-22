//
//  CalendarViewController.h
//  OrderList
//
//  Created by fly on 10/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TdCalendarView.h"

@interface CalendarViewController : UIViewController<CalendarViewDelegate> 
{
	NSString     *shopId ;
	NSInteger    selectShopRow;					//選択店のRow
	NSInteger	 selectShopSection;				//選択店のSection
	NSString	*cIsDayOrNight ;
}


@property(nonatomic,retain)NSString *shopId;
@property(nonatomic,assign)NSInteger selectShopRow;
@property(nonatomic,assign)NSInteger selectShopSection;
@property(nonatomic,retain)NSString	 *cIsDayOrNight;

@end
