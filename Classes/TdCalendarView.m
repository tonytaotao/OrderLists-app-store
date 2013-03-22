//
//  CalendarView.m
//
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TdCalendarView.h"
#import <QuartzCore/QuartzCore.h>

const float headHeight=60;
const float itemHeight=45;	
const float prevNextButtonSize=20;
const float prevNextButtonSpaceWidth=15;
const float prevNextButtonSpaceHeight=12;
const float titleFontSize=30;
const int	weekFontSize=12;

@implementation TdCalendarView

@synthesize currentMonthDate;
@synthesize currentSelectDate;
@synthesize currentTime;
@synthesize viewImageView;
@synthesize delegate;

static id	*hisCalendar = nil;

CGPoint touchPoint;

#pragma mark --init--
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
						[self initCalView];
    }
    return self;
}

//- (id)initWithFrame:(CGRect)frame {
//	
//	if (self = [super initWithFrame:frame]) {
//		[self initCalView];
//	}
//	return self;
//}


#pragma mark --initCalView--
-(void)initCalView{
	currentTime=CFAbsoluteTimeGetCurrent();
	currentMonthDate=CFAbsoluteTimeGetGregorianDate(currentTime,CFTimeZoneCopyDefault());
	currentMonthDate.day=1;
	currentSelectDate.year=0;
	monthFlagArray=malloc(sizeof(int)*31);
	[self clearAllDayFlag];	
	
	//next month calendar
	if(self.frame.origin.y > 11)
	{
		hisCalendar	=	self;
		[self moveNextMonth];
	}	
}


-(int)getDayCountOfaMonth:(CFGregorianDate)date{
	switch (date.month) {
		case 1:
		case 3:
		case 5:
		case 7:
		case 8:
		case 10:
		case 12:
			return 31;
			
		case 2:
			if((date.year%4==0 && date.year%100!=0) || (date.year %400 ==0) )
				return 29;
			else
				return 28;
		case 4:
		case 6:
		case 9:		
		case 11:
			return 30;
		default:
			return 31;
	}
}

-(void)drawPrevButton:(CGPoint)leftTop
{
	if(self.frame.origin.y > 11)
	{
		return;
	}
	CGContextRef ctx=UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(ctx,0,1);
	CGContextMoveToPoint	(ctx,  0 + leftTop.x, prevNextButtonSize/2 + leftTop.y);
	CGContextAddLineToPoint	(ctx, prevNextButtonSize + leftTop.x,  0 + leftTop.y);
	CGContextAddLineToPoint	(ctx, prevNextButtonSize + leftTop.x,  prevNextButtonSize + leftTop.y);
	CGContextAddLineToPoint	(ctx,  0 + leftTop.x,  prevNextButtonSize/2 + leftTop.y);
	CGContextFillPath(ctx);
}

-(void)drawNextButton:(CGPoint)leftTop
{
	if(self.frame.origin.y > 11)
	{
		return;
	}
	CGContextRef ctx=UIGraphicsGetCurrentContext();
	CGContextSetGrayStrokeColor(ctx,0,1);
	CGContextMoveToPoint	(ctx,  0 + leftTop.x,  0 + leftTop.y);
	CGContextAddLineToPoint	(ctx, prevNextButtonSize + leftTop.x,  prevNextButtonSize/2 + leftTop.y);
	CGContextAddLineToPoint	(ctx,  0 + leftTop.x,  prevNextButtonSize + leftTop.y);
	CGContextAddLineToPoint	(ctx,  0 + leftTop.x,  0 + leftTop.y);
	CGContextFillPath(ctx);
}
-(int)getDayFlag:(int)day
{
	if(day>=1 && day<=31)
	{
		return *(monthFlagArray+day-1);
	}
	else 
		return 0;
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
-(void)clearAllDayFlag
{
	memset(monthFlagArray,0,sizeof(int)*31);
}


-(void)setDayFlag:(int)day flag:(int)flag
{
	if(day>=1 && day<=31)
	{
		if(flag>0)
			*(monthFlagArray+day-1)=1;
		else if(flag<0)
			*(monthFlagArray+day-1)=-1;
	}
	
}
-(void)drawTopGradientBar{
	
	CGContextRef ctx=UIGraphicsGetCurrentContext();
	
	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.5, 1.0};
	CGFloat components[12] = {  
		1.0, 1.0, 1.0, 1.0,
		0.5, 0.5, 0.5, 1.0,
		1.0, 1.0, 1.0, 1.0 
	};
	
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
													  locations, num_locations);
//	[myColorspace	release];
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = headHeight;
	myStartPoint.y = 0.0;
	myEndPoint.x = headHeight;
	myEndPoint.y = headHeight;
	
	CGContextDrawLinearGradient(ctx,myGradient,myStartPoint, myEndPoint, 0);
	CGGradientRelease(myGradient);

	[self drawPrevButton:CGPointMake(prevNextButtonSpaceWidth,prevNextButtonSpaceHeight)];
	[self drawNextButton:CGPointMake(self.frame.size.width-prevNextButtonSpaceWidth-prevNextButtonSize,prevNextButtonSpaceHeight)];
}

-(void)drawTopBarWords{
	int width=self.frame.size.width;
	int s_width=width/7;

	[[UIColor blackColor] set];
	NSString *title_Month   = [[NSString alloc] initWithFormat:@"%d年%d月",
                               (int)currentMonthDate.year,currentMonthDate.month];
	
	int fontsize=[UIFont buttonFontSize];
    UIFont   *font    = [UIFont systemFontOfSize:titleFontSize];
	CGPoint  location = CGPointMake(width/2 -2.5*titleFontSize, 0);
    [title_Month drawAtPoint:location withFont:font];
	[title_Month release];
	
	
	UIFont *weekfont=[UIFont boldSystemFontOfSize:weekFontSize];
	fontsize+=3;
	fontsize+=20;
	
	[@"月曜日" drawAtPoint:CGPointMake(s_width*0+9,fontsize) withFont:weekfont];
	[@"火曜日" drawAtPoint:CGPointMake(s_width*1+9,fontsize) withFont:weekfont];
	[@"水曜日" drawAtPoint:CGPointMake(s_width*2+9,fontsize) withFont:weekfont];
	[@"木曜日" drawAtPoint:CGPointMake(s_width*3+9,fontsize) withFont:weekfont];
	[@"金曜日" drawAtPoint:CGPointMake(s_width*4+9,fontsize) withFont:weekfont];
	[[UIColor redColor] set];
	[@"土曜日" drawAtPoint:CGPointMake(s_width*5+9,fontsize) withFont:weekfont];
	[@"日曜日" drawAtPoint:CGPointMake(s_width*6+9,fontsize) withFont:weekfont];
	[[UIColor blackColor] set];
	
}

-(void)drawGirdLines{
	
	CGContextRef ctx=UIGraphicsGetCurrentContext();
	int width=self.frame.size.width;
	int row_Count=([self getDayCountOfaMonth:currentMonthDate]+[self getMonthWeekday:currentMonthDate]-2)/7+1;

	
	int s_width=width/7;
	int tabHeight=row_Count*itemHeight+headHeight;

	CGContextSetGrayStrokeColor(ctx,0,1);
	CGContextMoveToPoint	(ctx,0,headHeight);
	CGContextAddLineToPoint	(ctx,0,tabHeight);
	CGContextStrokePath		(ctx);
	CGContextMoveToPoint	(ctx,width,headHeight);
	CGContextAddLineToPoint	(ctx,width,tabHeight);
	CGContextStrokePath		(ctx);
	
	for(int i=1;i<7;i++){
		CGContextSetGrayStrokeColor(ctx,1,1);
		CGContextMoveToPoint(ctx, i*s_width-1, headHeight);
		CGContextAddLineToPoint( ctx, i*s_width-1,tabHeight);
		CGContextStrokePath(ctx);
	}
	
	for(int i=0;i<row_Count+1;i++){
		CGContextSetGrayStrokeColor(ctx,1,1);
		CGContextMoveToPoint(ctx, 0, i*itemHeight+headHeight+3);
		CGContextAddLineToPoint( ctx, width,i*itemHeight+headHeight+3);
		CGContextStrokePath(ctx);
		
		CGContextSetGrayStrokeColor(ctx,0.3,1);
		CGContextMoveToPoint(ctx, 0, i*itemHeight+headHeight);
		CGContextAddLineToPoint( ctx, width,i*itemHeight+headHeight);
		CGContextStrokePath(ctx);
	}
	for(int i=1;i<7;i++){
		CGContextSetGrayStrokeColor(ctx,0.3,1);
		CGContextMoveToPoint(ctx, i*s_width+2, headHeight);
		CGContextAddLineToPoint( ctx, i*s_width+2,tabHeight);
		CGContextStrokePath(ctx);
	}
}


-(int)getMonthWeekday:(CFGregorianDate)date
{
	CFTimeZoneRef tz = CFTimeZoneCopyDefault();
//	[tz	autorelease];
	CFGregorianDate month_date;
	month_date.year=date.year;
	month_date.month=date.month;
	month_date.day=1;
	month_date.hour=0;
	month_date.minute=0;
	month_date.second=1;
	return (int)CFAbsoluteTimeGetDayOfWeek(CFGregorianDateGetAbsoluteTime(month_date,tz),tz);
}

#pragma mark --drawDateWords--
-(void)drawDateWords
{
	CGContextRef ctx=UIGraphicsGetCurrentContext();

	int width=self.frame.size.width;
	
	int dayCount=[self getDayCountOfaMonth:currentMonthDate];
	int day=0;
	int x=0;
	int y=0;
	int s_width=width/7;
	int curr_Weekday=[self getMonthWeekday:currentMonthDate];
	
	UIFont *weekfont=[UIFont boldSystemFontOfSize:17];
	CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
	
	NSArray *monthPeopleArr = [delegate getCalendarMonthPeopleData:[NSString stringWithFormat:@"%d/%d",(int)currentMonthDate.year,currentMonthDate.month]];
	if(monthPeopleArr.count>0)
	{
		for(int i=1;i<dayCount+1;i++)
		{
			day=i+curr_Weekday-2;
			x=day % 7;
			y=day / 7;
			
			NSString *date=[[[NSString alloc] initWithFormat:@"%2d",i] autorelease];
			[date drawAtPoint:CGPointMake(x*s_width+20,y*itemHeight+headHeight+10) withFont:weekfont];

			[delegate drawPeopleCountWords:CGPointMake(x*s_width+60, y*itemHeight+headHeight + 5) personCount:CGPointMake(x*s_width+60, y*itemHeight+headHeight + 25)  team:[monthPeopleArr objectAtIndex:(i-1)]];
			
		}//end for
		
	}//end if

}


#pragma mark --movePrevNext--
- (void) movePrevNext:(int)isPrev{
	currentSelectDate.year=0;
//	[delegate beforeMonthChange:self willto:currentMonthDate];
	int width=self.frame.size.width;
	int posX;
	if(isPrev==1)
	{
		posX=width;
	}
	else
	{
		posX=-width;
	}
	
	UIImage *viewImage;
	
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];	
	viewImage= UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	if(viewImageView)
	{
		viewImageView=[[UIImageView alloc] initWithImage:viewImage];
		
		viewImageView.center=self.center;
		[[self superview] addSubview:viewImageView];
	}
	else
	{
		viewImageView.image=viewImage;
	}
	
	viewImageView.hidden=NO;
	viewImageView.transform=CGAffineTransformMakeTranslation(0, 0);
	self.hidden=YES;
	[self setNeedsDisplay];
	self.transform=CGAffineTransformMakeTranslation(posX,0);
	
	
	//float height;
	//int row_Count=([self getDayCountOfaMonth:currentMonthDate]+[self getMonthWeekday:currentMonthDate]-2)/7+1;
	//float height=row_Count*itemHeight+headHeight;
	//self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
	self.hidden=NO;
	[UIView beginAnimations:nil	context:nil];
	[UIView setAnimationDuration:0.2];
	self.transform=CGAffineTransformMakeTranslation(0,0);
	viewImageView.transform=CGAffineTransformMakeTranslation(-posX, 0);
	[UIView commitAnimations];
//	[delegate monthChanged:currentMonthDate viewLeftTop:self.frame.origin height:height];
	
}

//- (void)movePrevMonth{
//	if(currentMonthDate.month>1)
//		currentMonthDate.month-=1;
//	else
//	{
//		currentMonthDate.month=12;
//		currentMonthDate.year-=1;
//	}
//	[self movePrevNext:0];
//}

- (void)movePrevMonth{
	if(currentMonthDate.month>2)
	{
		currentMonthDate.month-=2;
	}
	else
	{
		currentMonthDate.year-=1;
		if (currentMonthDate.month==1)
		{
			currentMonthDate.month=11;
		}
		else
		{
			currentMonthDate.month=12;
		}
	}
	[self movePrevNext:0];
}

- (void)moveNextTwoMonth{
	if(currentMonthDate.month<11)
		currentMonthDate.month+=2;
	else
	{
		//currentMonthDate.month=1;
		currentMonthDate.year+=1;
		if (currentMonthDate.month==11)
		{
			currentMonthDate.month=1;
		}
		else
		{
			currentMonthDate.month=2;
		}
	}
	[self movePrevNext:1];	
}


- (void)moveNextMonth{
	if(currentMonthDate.month<12)
		currentMonthDate.month+=1;
	else
	{
		currentMonthDate.month=1;
		currentMonthDate.year+=1;
	}
	[self movePrevNext:1];	
}


#pragma mark --darwCalendarColor--
- (void) drawCalendarColor
{
//	CFGregorianDate today=CFAbsoluteTimeGetGregorianDate(currentTime, CFTimeZoneCopyDefault());
	
	int width=self.frame.size.width;
	
	int dayCount = [self getDayCountOfaMonth:currentMonthDate];
	int day=0;
	int x=0;
	int y=0;
	int s_width=width/7;
	int curr_Weekday=[self getMonthWeekday:currentMonthDate];
	CGContextRef ctx=UIGraphicsGetCurrentContext(); 
	
	NSArray	*monthMemo= [delegate getCalendarMonthMemoData:[NSString stringWithFormat:@"%d/%d",(int)currentMonthDate.year,currentMonthDate.month]];
	
	if(monthMemo.count>0)
	{
		for (int i=1; i<=dayCount; i++) 
		{
			
			day = i+curr_Weekday-2;
			x=day % 7;
			y=day / 7;
			
			
			CGFloat posStart_x= x*s_width+1;
			CGFloat posStart_y= y*itemHeight+headHeight;
			
			CGFloat posEnd_x  = (x+1)*s_width +2;
			CGFloat posEnd_y  =  (y+1)*itemHeight+headHeight;
			
			
			NSString *strdayMemo = [[monthMemo objectAtIndex:i-1] stringValue];
			[delegate drawCalendarMemoColor:ctx dayMemo:strdayMemo startPosX:posStart_x startPosY:posStart_y endPosX:posEnd_x endPosY:posEnd_y];
		}//end for
		
	}//end if
	
}


//select it then change the color
- (void) drawCurrentSelectDate{
	int x;
	int y;
	int day;
	int todayFlag;
	if(currentSelectDate.year!=0)
	{
		CFGregorianDate today=CFAbsoluteTimeGetGregorianDate(currentTime, CFTimeZoneCopyDefault());

		if(today.year==currentSelectDate.year && today.month==currentSelectDate.month && today.day==currentSelectDate.day)
			todayFlag=1;
		else
			todayFlag=0;
		
		int width=self.frame.size.width;
		int swidth=width/7;
		int weekday=[self getMonthWeekday:currentMonthDate];
		day=currentSelectDate.day+weekday-2;
		x=day%7;
		y=day/7;
		CGContextRef ctx=UIGraphicsGetCurrentContext();
		
		if(todayFlag==1)
			CGContextSetRGBFillColor(ctx, 0, 0, 0.7, 1);
		else
			CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
		
		
		CGContextMoveToPoint(ctx, x*swidth+1, y*itemHeight+headHeight);
		CGContextAddLineToPoint(ctx, x*swidth+swidth+2, y*itemHeight+headHeight);
		CGContextAddLineToPoint(ctx, x*swidth+swidth+2, y*itemHeight+headHeight+itemHeight);
		CGContextAddLineToPoint(ctx, x*swidth+1, y*itemHeight+headHeight+itemHeight);
		CGContextFillPath(ctx);	
		
		if(todayFlag==1)
		{
			CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
			CGContextMoveToPoint	(ctx, x*swidth+4,			y*itemHeight+headHeight+3);
			CGContextAddLineToPoint	(ctx, x*swidth+swidth-1,	y*itemHeight+headHeight+3);
			CGContextAddLineToPoint	(ctx, x*swidth+swidth-1,	y*itemHeight+headHeight+itemHeight-3);
			CGContextAddLineToPoint	(ctx, x*swidth+4,			y*itemHeight+headHeight+itemHeight-3);
			CGContextFillPath(ctx);	
		}
		
		CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);

		UIFont *weekfont=[UIFont boldSystemFontOfSize:12];
		NSString *date=[[[NSString alloc] initWithFormat:@"%2d",currentSelectDate.day] autorelease];
		[date drawAtPoint:CGPointMake(x*swidth+15,y*itemHeight+headHeight) withFont:weekfont];
		if([self getDayFlag:currentSelectDate.day]!=0)
		{
			[@"." drawAtPoint:CGPointMake(x*swidth+19,y*itemHeight+headHeight+6) withFont:[UIFont boldSystemFontOfSize:25]];
		}		
	}
}

- (void) touchAtDate:(CGPoint) touchPoint{
	int x;
	int y;
	int width=self.frame.size.width;
	int weekday=[self getMonthWeekday:currentMonthDate];
	int monthDayCount=[self getDayCountOfaMonth:currentMonthDate];
	x=touchPoint.x*7/width;
	y=(touchPoint.y-headHeight)/itemHeight;
	int monthday=x+y*7-weekday+2;
	if(monthday>0 && monthday<monthDayCount+1)
	{
		currentSelectDate.year=currentMonthDate.year;
		currentSelectDate.month=currentMonthDate.month;
		currentSelectDate.day=monthday;
		currentSelectDate.hour=0;
		currentSelectDate.minute=0;
		currentSelectDate.second=1;
//		[delegate selectDateChanged:currentSelectDate];
		
		[self	performSelector:@selector(drawSelectDate)  withObject:nil afterDelay:.1];
		[self setNeedsDisplay];
	}
}

-	(void)drawSelectDate
{
	[delegate selectDateChanged:currentSelectDate];
}

//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch=[touches anyObject];
	
	touchPoint=[touch locationInView:self];
	NSUInteger tapCount = [touch tapCount];
	
	switch (tapCount) 
	{
		case 1:
			[self performSelector:@selector(singleTap)
					   withObject:nil	//[NSNumber numberWithInteger:number]
					   afterDelay:.1];
			break;
			
		case  2:
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(singleTap)
													   object:nil];
			
			[self performSelector:@selector(doubleTap)
					   withObject:nil	//[NSNumber numberWithInteger:number]
					   afterDelay:.1];
			break;
			
		default:
			break;
	}
}





- (void)singleTap
{
//	NSLog(@"------------S----------");
	
	int width=self.frame.size.width;
	//UIView* theview=[self hitTest:touchPoint withEvent:event];
	
	if(touchPoint.x<40 && touchPoint.y<headHeight)
	{
		if(self.frame.origin.y > 11)
		{
			return;
		}
		[self movePrevMonth];
		[hisCalendar	movePrevMonth];
	}
	else if(touchPoint.x>width-40 && touchPoint.y<headHeight)
	{
		if(self.frame.origin.y > 11)
		{
			return;
		}
		[self moveNextTwoMonth];
		[hisCalendar	moveNextTwoMonth];
	}
	else if(touchPoint.y>headHeight)
	{
		[self touchAtDate:touchPoint];
		[self	resignFirstResponder];
	}
}

- (void)doubleTap
{
//	NSLog(@"============D===========");
}




#pragma mark --drawRect--
- (void)drawRect:(CGRect)rect
{

	static int once=0;
	currentTime=CFAbsoluteTimeGetCurrent();
	
	[self drawTopGradientBar];
	[self drawTopBarWords];
	[self drawGirdLines];
	
	if(once==0)
	{
		once=1;
		//float height;
		//int row_Count=([self getDayCountOfaMonth:currentMonthDate]+[self getMonthWeekday:currentMonthDate]-2)/7+1;
		//float height=row_Count*itemHeight+headHeight;
//		[delegate monthChanged:currentMonthDate viewLeftTop:self.frame.origin height:height];
//		[delegate beforeMonthChange:self willto:currentMonthDate];
	}
	[self drawCurrentSelectDate];
	
	[self drawCalendarColor];
	[self drawDateWords];
}


- (void)dealloc {
	self.viewImageView = nil;
    [super dealloc];
	free(monthFlagArray);
}


@end
