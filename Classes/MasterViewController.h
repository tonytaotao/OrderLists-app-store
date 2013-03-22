//
//  MasterViewController.h
//  MasterDetail
//
//  Created by Andreas Katzian on 15.05.10.
//  Copyright 2010 Blackwhale GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MasterViewController : UITableViewController {
//	UIDatePicker *theDatePicker;
}

//@property (nonatomic, retain) id masViewController;

- (void)parseXml: (NSString*)xmlString ;
+ (MasterViewController*) getTableViewController;
- (void) changeView:(int)indexRow iSection:(int)section;
@end
