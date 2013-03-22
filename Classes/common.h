//
//  common.h
//  OrderList
//
//  Created by fly on 10/11/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "TouchXML.h"
#import "DDXML.h"
#import "PriceInput.h"

#define LeftScrollViewWidth      78
#define TopScrollViewHeight      70
#define ContentScrollViewWidth   700

//#define soapIP					@"http://192.168.254.208:8089/Service.asmx"
#define soapIP                  @"http://10.0.0.105:8090/Service.asmx"
#define ResetName				@"reset"



static NSString *hisPhoneCdNameInfo = nil;
static NSString	*detailPhoneCdNameInfo	=	nil;
//static NSString *SelectShopId = nil;

@interface common : NSObject 
{
}

+ (void)showErrorAlert:(NSString *)err;
+ (void)showSuccessAlert:(NSString *)msg;

+ (BOOL)requestDidError;

+ (NSString	*)formatCntStr:(NSString *)str Count:(NSInteger)count;

//stringがxmlの式になる
//eg:
//from:
/* <ArrayOfString>
		<string>
			&lt;customerCount&gt;6&lt;/customerCount&gt;
			&lt;groupCount&gt;1&lt;/groupCount&gt;
		</string>
  </ArrayOfString>
*/

//to:
/* <ArrayOfString>
 <string>
	<customerCount>6</customerCount>
	<groupCount>1</groupCount>
 </string>
 </ArrayOfString>
 */
+ (NSString *)formateXmlString:(NSString *)htmlString;

+ (NSString *)serverSoapIp;
@end
