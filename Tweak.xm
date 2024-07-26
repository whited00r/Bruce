#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <IOSurface/IOSurface.h>
#import <QuartzCore/QuartzCore2.h>
#import <QuartzCore/CAAnimation.h>
#import <UIKit/UIGraphics.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <notify.h>
#import <Foundation/NSTask.h>
#import "WD7API.h"
#import "UIImage+StackBlur.h"
//#import "bruceBanner.h"
int BRUCE_LS_SCROLL_HEIGHT = 40;

UIKIT_EXTERN CGImageRef UIGetScreenImage(); //Meeeeeehhhh
//Messy much?
%class SBApplication
%class SBUIController
%class SBApplicationController
%class UIStatusBar
%class SBStatusBarController
%class UIApplication
%class SBAwayController
%class SBAlertItem
%class SBRemoteNotificationAlertSheet

@interface UIButton (PassTouch)
@end

@implementation UIButton (PassTouch)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self.nextResponder touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.nextResponder touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.nextResponder touchesCancelled:touches withEvent:event];
}
@end


//Stuff needs to be cleaned up here probably...
@interface SBRemoteNotificationAlertSheet

@end
@interface SBApplication
-(NSString*)bundleIdentifier;
-(NSString*)pathForSmallIcon;
-(NSString*)pathForIcon;
-(NSString*)displayName;
@end

@interface SBAlertItem 
-(Class)alertSheetClass;
-(id)alertSheet;
// inherited: -(void)dealloc;
-(BOOL)allowMenuButtonDismissal;
-(BOOL)shouldShowInLockScreen;
-(BOOL)shouldShowInEmergencyCall;
-(BOOL)undimsScreen;
-(BOOL)unlocksScreen;
-(BOOL)togglesMediaControls;
-(BOOL)dismissOnLock;
-(BOOL)dimissOnAlertActivation;
-(BOOL)willShowInAwayItems;
-(void)cleanPreviousConfiguration;
-(void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)actions;
-(id)lockLabel;
-(float)lockLabelFontSize;
-(double)autoDismissInterval;
-(void)setDisallowsUnlockAction:(BOOL)action;
-(BOOL)disallowsUnlockAction;
-(void)performUnlockAction;
-(void)setOrderOverSBAlert:(BOOL)alert;
-(BOOL)preventLockOver;
-(void)setPreventLockOver:(BOOL)over;
-(void)willActivate;
-(void)didActivate;
-(void)willRelockForButtonPress:(BOOL)buttonPress;
-(void)dismiss;
-(void)screenWillUndim;
-(void)willDeactivateForReason:(int)reason;
-(void)didDeactivateForReason:(int)reason;
-(void)noteVolumeOrLockPressed;
-(id)awayItem;
@end

@interface SBRemoteNotificationAlert : SBAlertItem
-(void)bannerPressed;
-(void)alertSheet:(id)sheet buttonClicked:(int)clicked;
-(void)activateApplication;
NSString *alertApplication;
@end


@interface SBUIController
+(id)sharedInstance;
-(void)activateApplicationAnimated:(SBApplication*)application;

@end

@interface SBApplicationController
+(id)sharedInstance;
-(NSArray*)applicationsWithBundleIdentifier:(NSString*)bundleIdentifier;

@end

@interface UIImage (CropThis)

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;

@end

@implementation UIImage (CropThis)
- (UIImage *)croppedToRect:(CGRect)rect {

   CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef); 
    return cropped;
}
@end

//Views and variables and such!
static UIView *bannerView;
static BOOL lsLoaded = FALSE;
static BOOL isWhited00r = FALSE;
static BOOL showingOverlay = FALSE;
static BOOL iOS7Style = TRUE;
static BOOL darkerBackground = TRUE;
static BOOL blurBackground = TRUE;
#define prefsPlist @"/var/mobile/Library/Preferences/com.whited00r.bruce.plist"

	/*
__attribute__((constructor))
static void initialize() {

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
if([[NSFileManager defaultManager]fileExistsAtPath:prefsPlist]){
		NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefsPlist];

		iOS7Style=[[prefs objectForKey:@"iOS7Style"]boolValue];
		darkerBackground=[[prefs objectForKey:@"darkerBackground"]boolValue];
		blurBackground=[[prefs objectForKey:@"blurBackground"]boolValue];
		[prefs release];

	}else{
		NSDictionary *prefs=[[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"iOS7Style",[NSNumber numberWithBool:TRUE],@"darkerBackground",[NSNumber numberWithBool:FALSE],@"blurBackground",nil];
		[prefs writeToFile:prefsPlist atomically:YES];
		[prefs release];
	}






}
[pool drain];
	}
*/
static void loadPrefs();


static void loadPrefs(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if([[NSFileManager defaultManager]fileExistsAtPath:prefsPlist]){
		NSDictionary *prefs=[[NSDictionary alloc]initWithContentsOfFile:prefsPlist];

		iOS7Style=[[prefs objectForKey:@"iOS7Style"]boolValue];
		darkerBackground=[[prefs objectForKey:@"darkerBackground"]boolValue];
		blurBackground=[[prefs objectForKey:@"blurBackground"]boolValue];
		[prefs release];

	}else{
		NSDictionary *prefs=[[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"iOS7Style",[NSNumber numberWithBool:TRUE],@"darkerBackground",[NSNumber numberWithBool:TRUE],@"blurBackground",nil];
		[prefs writeToFile:prefsPlist atomically:YES];
		[prefs release];
	}
	
	if(!isWhited00r){

NSFileManager *fMgr = [NSFileManager defaultManager]; 


NSString *firstLevel = [NSString stringWithFormat:@"%@-CantCrackDis",[[UIDevice currentDevice] uniqueIdentifier]]; //they could, in fact, crack this
NSString *arguments = [NSString stringWithFormat:@"echo %@ | openssl dgst -sha1 -hmac \"PlsNo\"", firstLevel];
NSPipe *resultPipe = [[NSPipe alloc] init];
NSTask *taskCrypt = [[NSTask alloc] init];
NSArray *argsCrypt = [NSArray arrayWithObjects:@"-c", arguments, nil];
[taskCrypt setStandardOutput:resultPipe];

[taskCrypt setLaunchPath:@"/bin/bash"];
[taskCrypt setArguments:argsCrypt];
[taskCrypt launch];    // Run
[taskCrypt waitUntilExit]; // Wait
NSData *result = [[resultPipe fileHandleForReading] readDataToEndOfFile];
NSString *licenseKey = [[NSString alloc] initWithData: result
                               encoding: NSUTF8StringEncoding];

licenseKey = [licenseKey substringToIndex:[licenseKey length] - 1];

NSString *magicFilePath = [NSString stringWithFormat:@"/var/mobile/Whited00r/%@", licenseKey];
//NSLog(magicFilePath);

if ([fMgr fileExistsAtPath:magicFilePath] && [fMgr fileExistsAtPath:@"/var/lib/dpkg/info/com.whited00r.whited00r.list"]) { 
//NSLog(@"LicenceKey isWhited00r: /var/mobile/Whited00r/%@", licenseKey);
isWhited00r = TRUE;
}
[taskCrypt release];
//[result release];
//[licenseKey release];
[resultPipe release];
[pool drain];
}
}

//Finally, I think I mostly figured this stuff out (probably far from it actually)
@class bruceLSCell;

@interface bruceLSCell : UIView
NSString *bannerLSBody;
NSString *bannerLSBundleID;
NSString *bannerLSTitle;
NSString *bannerLSIconPath;
-(void)baseInit;

@property (nonatomic,retain) NSString *bannerLSBody;
@property (nonatomic,retain) NSString *bannerLSBundleID;
@property (nonatomic,retain) NSString *bannerLSTitle;
@property (nonatomic,retain) NSString *bannerLSIconPath;




@end


@implementation bruceLSCell

@synthesize bannerLSBody, bannerLSBundleID, bannerLSTitle, bannerLSIconPath;

-(id)initWithFrame:(CGRect)frame
{

self = [super initWithFrame:frame];
if (self) {
self.userInteractionEnabled = TRUE;
}
return self;
}

-(void)baseInit{

//int maxHeight = 80;
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
UIImageView *bannerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height)];
bannerBackground.userInteractionEnabled = TRUE;
UIImage *backgroundImage;
if(iOS7Style){
backgroundImage = [UIImage imageWithContentsOfFile:@"/Library/Bruce/LSBannerBackgroundiOS7.png"];
}
else{
backgroundImage = [UIImage imageWithContentsOfFile:@"/Library/Bruce/LSBannerBackground.png"];
}
[bannerBackground setImage:[backgroundImage stretchableImageWithLeftCapWidth:6 topCapHeight:10]]; 
[self addSubview:bannerBackground];

UILabel *textTitle = [[UILabel alloc] init];
textTitle.textAlignment = UITextAlignmentLeft;
textTitle.font = [UIFont boldSystemFontOfSize:16];
textTitle.frame=CGRectMake(40, 7, 220, 20);
textTitle.backgroundColor = [UIColor clearColor];
textTitle.text = self.bannerLSTitle;
textTitle.textColor = [UIColor whiteColor];

[self addSubview:textTitle];
[textTitle release];

/*
NSString *time = nil;

NSCalendar *calendar = [NSCalendar currentCalendar];

NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];

time = [NSString stringWithFormat:@"%@:%@", [components hour], @"oh"];
UILabel *timeTitle = [[UILabel alloc] init];
timeTitle.textAlignment = UITextAlignmentLeft;
timeTitle.font = [UIFont boldSystemFontOfSize:12];
timeTitle.frame=CGRectMake(260, 7, 60, 20);
timeTitle.backgroundColor = [UIColor clearColor];
timeTitle.text = time;
timeTitle.textColor = [UIColor whiteColor];
timeTitle.alpha = 0.7;
[self addSubview:timeTitle];
[timeTitle release];
*/
UILabel *textBody = [[UILabel alloc] init];
textBody.textAlignment = UITextAlignmentLeft;
textBody.font = [UIFont systemFontOfSize:14];
textBody.frame=CGRectMake(40, 30, 260, 30);
textBody.backgroundColor = [UIColor clearColor];
textBody.text = self.bannerLSBody;
textBody.lineBreakMode = UILineBreakModeWordWrap;
textBody.numberOfLines = 0;
textBody.textColor = [UIColor whiteColor];
[textBody sizeToFit];

//For sizing stuff correctly
if(textBody.bounds.size.height >= 50){
textBody.frame=CGRectMake(40, 30, 260, 50);
}

[self addSubview:textBody];
[textBody release];
//Resizing the frame accordingly to the size.
self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, textBody.frame.size.height + 50);
bannerBackground.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, textBody.frame.size.height + 50);
[bannerBackground release];

//For the banner icon
int heightMiddle = self.frame.size.height / 2;

UIImageView *bannerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
bannerIcon.image = [UIImage imageWithContentsOfFile:self.bannerLSIconPath];
bannerIcon.layer.cornerRadius = 5.0;
bannerIcon.layer.masksToBounds = YES;
[self addSubview:bannerIcon];




UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
bannerButton.frame = bannerIcon.frame;
[bannerButton setTitle:nil forState:UIControlStateNormal];  
[bannerButton setBackgroundImage:nil forState:UIControlStateNormal];
[bannerButton addTarget:self action:@selector(bannerPressed) forControlEvents:UIControlEventTouchUpInside];
  
[self addSubview:bannerButton];
[bannerIcon release];
[pool drain];
}

-(void)bannerPressed{

//Very very messy, but seems to be the only way to do this on 3.1.3 :(
//Unlocking the device, then going to the homescreen, seems odd but is needed

lsLoaded = FALSE;
[[%c(SBUIController) sharedInstance] openAppWithBundleID:self.bannerLSBundleID];


}

-(void)closeToHome{
//And then going to the homescreen, and then opening the app
[(SBUIController*)[objc_getClass("SBUIController") sharedInstance] clickedMenuButton];
[self performSelector:@selector(openApp) withObject:nil afterDelay:0.5];

}

-(void)openApp{

//Opening up the app :P
SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:self.bannerLSBundleID];
   
[(SBUIController*)[objc_getClass("SBUIController") sharedInstance] activateApplicationAnimated:app];

}

@end


//Dynamic slightly...
@class bruceLSHolder;
@interface bruceLSHolder : UIView
UIScrollView *scoll;
BOOL hasDimmedCells;
-(void)addCell:(bruceLSCell*)cell;
@property (nonatomic,retain) UIScrollView* scroll;
@end

@implementation bruceLSHolder

@synthesize scroll;

-(id)initWithFrame:(CGRect)frame
{

self = [super initWithFrame:frame];
if (self) {
hasDimmedCells = FALSE;
self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,245)];
self.scroll.delegate = self;
[self.scroll setBackgroundColor:[UIColor clearColor]];
self.scroll.contentSize = CGSizeMake(320, BRUCE_LS_SCROLL_HEIGHT);
self.scroll.userInteractionEnabled = TRUE;
self.userInteractionEnabled = TRUE;
[self addSubview:self.scroll];
[self.scroll release];

}
return self;
}

//Simple and elegant? Need to get the animation working right though.
//Probably is a way more efficient way to do this, but ah well.
-(void)addCell:(bruceLSCell*)cell{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
int addedHeight = cell.frame.size.height;
BRUCE_LS_SCROLL_HEIGHT = BRUCE_LS_SCROLL_HEIGHT + addedHeight;
self.scroll.contentSize = CGSizeMake(320, BRUCE_LS_SCROLL_HEIGHT);
CGRect oldFrame = cell.frame;
cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 0);
[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(undimCells) object:nil];
[UIView beginAnimations:@"Close animation" context:nil];   
[UIView setAnimationDelegate:self];
[UIView setAnimationDuration:.4f];

for(UIView *oldCell in [self.scroll subviews]) 
{
oldCell.frame = CGRectMake(0,oldCell.frame.origin.y + addedHeight, oldCell.frame.size.width, oldCell.frame.size.height);
oldCell.alpha = 0.3;
}


[UIView commitAnimations];
[self performSelector:@selector(undimCells) withObject:nil afterDelay:20.0];
hasDimmedCells = TRUE;

[self.scroll addSubview:cell];
[UIView beginAnimations:@"Close animation" context:nil];   
[UIView setAnimationDelegate:self];
[UIView setAnimationDuration:.4f];
cell.frame = oldFrame;
[UIView commitAnimations];
[pool drain];
}


-(void)undimCells{
hasDimmedCells = FALSE;
[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(undimCells) object:nil];
[UIView beginAnimations:@"Close animation" context:nil];   
[UIView setAnimationDelegate:self];
[UIView setAnimationDuration:.3f];

for(UIView *oldCell in [self.scroll subviews]) 
{
oldCell.alpha = 1.0;
}

[UIView commitAnimations];

}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
	if(hasDimmedCells){
		[self undimCells];
	}
}
@end




//BANNERS MAN
@class bruceBanner;

@interface bruceBanner : UIView
NSString *bannerBody;
NSString *bannerBundleID;
NSString *bannerTitle;
NSString *bannerIconPath;
CGPoint startLocation;

-(void)baseInit;
-(void)timeoutBanner;
-(void)animateOut;

@property (nonatomic,retain) NSString *bannerBody;
@property (nonatomic,retain) NSString *bannerBundleID;
@property (nonatomic,retain) NSString *bannerTitle;
@property (nonatomic,retain) NSString *bannerIconPath;




@end

@implementation bruceBanner

@synthesize bannerBody, bannerBundleID, bannerTitle, bannerIconPath;

-(id)initWithFrame:(CGRect)frame
{

self = [super initWithFrame:frame];
if (self) {
self.userInteractionEnabled = TRUE;
}
return self;
}

-(void)baseInit{

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.backgroundColor = [UIColor clearColor];

//[[%c(SBStatusBarController) sharedStatusBarController] resizeStatusBar:20.0 grow:TRUE fenceID:2];

bannerView.frame = CGRectMake(0,0,320,self.frame.size.height);



UIImageView *bannerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height)];
if(self.frame.size.height == 40){
bannerBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Bruce/BannerBackground.png"];
}
else{
bannerBackground.image = [UIImage imageWithContentsOfFile:@"/Library/Bruce/BannerBackgroundiOS7.png"] ;//[[UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeWallpaperBlurred_dark.png"] croppedToRect:CGRectMake(0,0,320,self.frame.size.height)];
}
[self addSubview:bannerBackground];
[bannerBackground release];

UILabel *textTitle = [[UILabel alloc] init];
textTitle.textAlignment = UITextAlignmentLeft;
textTitle.font = [UIFont boldSystemFontOfSize:15];
textTitle.frame=CGRectMake(36, 3, 220, 20);
textTitle.backgroundColor = [UIColor clearColor];
textTitle.text = self.bannerTitle;
textTitle.numberOfLines = 0;
if(self.frame.size.height == 40){
textTitle.textColor = [UIColor blackColor];
}
else{
textTitle.textColor = [UIColor whiteColor];

}

[self addSubview:textTitle];
[textTitle sizeToFit];

CGSize textSize = [[textTitle text] sizeWithFont:[textTitle font]];
float textHeight = textSize.height;
[textTitle release];

UIImageView *bannerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 20, 20)];
bannerIcon.image = [UIImage imageWithContentsOfFile:self.bannerIconPath];
[self addSubview:bannerIcon];
[bannerIcon release];

bannerIcon.layer.cornerRadius = 5.0;
bannerIcon.layer.masksToBounds = YES;

UILabel *textBody = [[UILabel alloc] init];
textBody.textAlignment = UITextAlignmentLeft;
textBody.font = [UIFont systemFontOfSize:12];
if(iOS7Style){
textBody.frame=CGRectMake(36, textHeight +1, 260, 20);
}
else{
textBody.frame=CGRectMake(36, 18, 260, 20);
}
textBody.backgroundColor = [UIColor clearColor];
textBody.text = self.bannerBody;
if(self.frame.size.height == 40){
textBody.textColor = [UIColor blackColor];
}
else{
textBody.textColor = [UIColor whiteColor];
textBody.numberOfLines = 0;
textBody.lineBreakMode = UILineBreakModeWordWrap;
}
[textBody sizeToFit];

//For sizing stuff correctly
if(textBody.bounds.size.height >= 40){
if(iOS7Style){
textBody.frame=CGRectMake(36, textHeight + 1, 260, 40);
}
else{
textBody.frame=CGRectMake(36, 23, 260, 20);
}
}

[self addSubview:textBody];
[textBody release];




UILabel *timeTitle = [[UILabel alloc] init];
timeTitle.textAlignment = UITextAlignmentLeft;
timeTitle.font = [UIFont boldSystemFontOfSize:10];
timeTitle.frame=CGRectMake(textTitle.frame.size.width + 46, 3, 60, 20);
timeTitle.backgroundColor = [UIColor clearColor];
timeTitle.text = @"Now";
if(self.frame.size.height == 40){
timeTitle.textColor = [UIColor blackColor];
}
else{
timeTitle.textColor = [UIColor whiteColor];

}
timeTitle.alpha = 0.7;
[self addSubview:timeTitle];
[timeTitle release];


/*
UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
bannerButton.frame = CGRectMake(40,0,self.frame.size.width -40, self.frame.size.height);
[bannerButton setTitle:nil forState:UIControlStateNormal];  
[bannerButton setBackgroundImage:nil forState:UIControlStateNormal];
[bannerButton addTarget:self action:@selector(bannerPressed) forControlEvents:UIControlEventTouchUpInside];
  
//[self addSubview:bannerButton];
*/
//Timeout the banner, so it doesn't stay there forever
[self performSelector:@selector(animateOut) withObject:nil afterDelay:8];


[pool drain];
}


//For later on, I shall fill this in after I learn animations...
-(void)animateOut{
[UIView beginAnimations:@"Close animation" context:nil]; 
[UIView setAnimationDidStopSelector:@selector(removeBanner:finished:context:)];  
[UIView setAnimationDelegate:self];
[UIView setAnimationDuration:.4f];
self.frame = CGRectMake(0, -self.frame.size.height, 320, self.frame.size.height);

[UIView commitAnimations];

}
- (void)removeBanner:(NSString *)animationID finished:(BOOL)finished context:(void *)context{
bannerView.frame = CGRectMake(0,0,320,20);
[self removeFromSuperview];

}

-(void)bannerPressed{

[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateOut) object:nil];

[[%c(SBUIController) sharedInstance] openAppWithBundleID:self.bannerBundleID];
//[(SBUIController*)[objc_getClass("SBUIController") sharedInstance] clickedMenuButton];
//[self performSelector:@selector(openApp) withObject:nil afterDelay:0.5];

}

-(void)openApp{
SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:self.bannerBundleID];
   
       [(SBUIController*)[objc_getClass("SBUIController") sharedInstance] activateApplicationAnimated:app];
bannerView.frame = CGRectMake(0,0,320,20);
[self removeFromSuperview];

}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
CGPoint pt = [[touches anyObject] locationInView:self];
[[self superview] bringSubviewToFront:self];
[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateOut) object:nil];
startLocation = [[touches anyObject] locationInView:self];
}


- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
CGPoint pt;
pt = [[touches anyObject] locationInView:self];
float dx = pt.x - startLocation.x;
	float dy = pt.y - startLocation.y;
	float newCenterX;
	float newCenterY;

//I'll let it slide left/right just because I'm nice...
newCenterY = self.center.y + dy;
if(newCenterY >= self.frame.size.height / 2){
newCenterY = self.frame.size.height /2;
}
self.center = CGPointMake(self.center.x, newCenterY);


}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{

if(self.center.y == self.frame.size.height / 2){
[self bannerPressed];
return;

}
if(self.center.y <= -10){
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
[UIView setAnimationDidStopSelector:@selector(slideOutFinished:finished:context:)];

[UIView setAnimationDelegate:self];

	 self.frame = CGRectMake(0,-self.frame.size.height,320, self.frame.size.height);
    [UIView commitAnimations];
}

else{
[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];


	 self.frame = CGRectMake(0,0,320, self.frame.size.height);
[self performSelector:@selector(animateOut) withObject:nil afterDelay:3];
    [UIView commitAnimations];

}

}

- (void)slideOutFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context{
[self removeFromSuperview];
bannerView.frame = CGRectMake(0,0,320,20);


}
@end

//So other things can access this...


@interface SBAwayView

bruceLSHolder *lsHolder;
UIImageView *overlay;
-(BOOL)bruceEnabled;
@property(nonatomic, retain) bruceLSHolder *lsHolder;
@property(nonatomic, retain) UIImageView *overlay;
@end


@interface SBAwayDateView : UIView

@end
static SBAwayView *lsView;


%hook SBAlertItemsController


-(void)activateAlertItem:(id)item{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSString *title = nil;
NSString *body = nil;
NSString *iconPath = nil;
NSString *bundleID = nil;


if ([item isKindOfClass:%c(SBSMSAlertItem)]){


title = [item name];


body = [item messageText];
bundleID = @"com.apple.MobileSMS";
iconPath = [[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:bundleID] pathForIcon];


if ([%c(SBSMSAlertItem) shouldPlayMessageReceived])
{
[%c(SBSMSAlertItem) playMessageReceived];
}

}
else if (([item isKindOfClass:%c(SBRemoteNotificationAlert)]) ||
             ([item isKindOfClass:%c(SBRemoteLocalNotificationAlert)]))
    {
        // Get the SBApplication object,
        // we need its bundle identifier
        SBApplication *app(MSHookIvar<SBApplication *>(item, "_app"));

body = MSHookIvar<NSString*>(item, "_body");
title = [app displayName];
bundleID = [app bundleIdentifier];
iconPath = app.pathForIcon;


}
else if ([item isKindOfClass:%c(SBVoiceMailAlertItem)])
    {

title = [item title];
body = [item bodyText];
bundleID = @"com.apple.mobilephone";
iconPath = [[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:bundleID] pathForIcon];
}
else if ([item isKindOfClass:%c(SBInvitationAlertItem)])
    {

title = MSHookIvar<NSString*>(item, "_title");
body = MSHookIvar<NSString*>(item, "_organizer");
bundleID = @"com.apple.mobilecal";
iconPath = [[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:bundleID] pathForIcon];
[%c(SBInvitationAlertItem) _removeActiveItem:item];
}
    else
    {
        // Let's run the original
        // function for now
        %orig;
	return;
    }


if([[%c(SBAwayController) sharedAwayController] isLocked]){
lsView = [(SBAwayController*)[objc_getClass("SBAwayController") sharedAwayController] awayView];
bruceLSHolder *lsHolder = lsView.lsHolder;




if(!showingOverlay){
[lsView showOverlay];
}




//The cell we add into the bruceLSHolder

bruceLSCell *lsCell = [[bruceLSCell alloc] initWithFrame:CGRectMake(0,0,320,63)];
if(iOS7Style){
lsCell.frame = CGRectMake(0,0,320,63);


}
else{
lsCell.frame = CGRectMake(0,0,320,40);

}
lsCell.bannerLSBundleID = bundleID;
if(isWhited00r){
lsCell.bannerLSBody = body;
lsCell.bannerLSTitle = title;
}
else{
lsCell.bannerLSTitle = @"Hey you!";
lsCell.bannerLSBody = @"Try whited00r <3";
}
lsCell.bannerLSIconPath = iconPath;
[lsCell baseInit];
[lsHolder addCell:lsCell];
[lsCell release];


}
else{
//So, the device isn't locked, we can show the regular notification.
bannerView = [(SBStatusBarController*)[objc_getClass("SBStatusBarController") sharedStatusBarController] statusBarWindow];

bruceBanner* banner = [[bruceBanner alloc] initWithFrame:CGRectMake(0,0,320,63)];
if(iOS7Style){
banner.frame = CGRectMake(0,-63,320,63);

/*
CGImageRef screen = UIGetScreenImage();
CGImageRef imageRef = CGImageCreateWithImageInRect(screen, CGRectMake(0,0,320,63));
CGImageRelease(screen);

CAFilter *filter = [CAFilter filterWithType:@"gaussianBlur"];
[filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputRadius"];
NSArray * filters = [[NSArray alloc] initWithObjects:filter, nil];

CALayer *layer = [CALayer layer];
layer.contents = (id)imageRef;
layer.filters = filters;
//layer.shouldRasterize = YES;
banner.blurLayer = layer;
[filters release];
CGImageRelease(imageRef);
*/
}
else{
banner.frame = CGRectMake(0,-40,320,40);

}
banner.bannerBundleID = bundleID;
if(isWhited00r){
banner.bannerBody = body;
banner.bannerTitle = title;
}
else{
banner.bannerTitle = @"Hey you!";
banner.bannerBody = @"Try whited00r <3";
}

banner.bannerIconPath = iconPath;
[banner baseInit];

[bannerView addSubview:banner];

[UIView beginAnimations:@"Animate in" context:nil]; 
[UIView setAnimationDelegate:self];
[UIView setAnimationDuration:.4f];
banner.frame = CGRectMake(0, 0, 320, banner.frame.size.height);

[UIView commitAnimations];
[banner release];



}

/*
if([item undimsScreen]){

[[%c(SBAwayController) sharedAwayController] undimScreen];

}
*/
[pool drain];
%orig;
}

%end

%hook SBAlertItem

//These hooks are to hide the alert sheet, unless it is a system alert rather than a push notificaition. Took a while to figure this out -__-
-(void)didActivate{

//So, this seems to be the only way to do this correctly...  Otherwise it doesn't detect it is the same class -__-
%orig;
NSString *alertClass = NSStringFromClass([self alertSheetClass]);
NSArray *notificationClasses = [[NSArray alloc] initWithObjects:@"SBRemoteNotificationAlertSheet", @"SBVoiceMailAlertItem", @"SBRemoteLocalNotificationAlert", @"SBInvitationAlertItem", @"SBSMSAlertItem", @"SMSAlertSheet", @"SBINvitationAlertSheet", @"SBVoiceMailAlertSheet", nil];

if ([notificationClasses containsObject:alertClass]) {

[notificationClasses release];
[self dismiss];

}
//NSLog(@"ALERTCLASS: %@", alertClass);
}

-(id)alertSheet{
//NSLog(@"DONKEY PIG: %@",[self alertSheetClass]);

NSString *alertClass = NSStringFromClass([self alertSheetClass]);
NSArray *notificationClasses = [[NSArray alloc] initWithObjects:@"SBRemoteNotificationAlertSheet", @"SBVoiceMailAlertItem", @"SBRemoteLocalNotificationAlert", @"SBInvitationAlertItem", @"SBSMSAlertItem", @"SMSAlertSheet", @"SBINvitationAlertSheet", @"SBVoiceMailAlertSheet", nil];

if ([notificationClasses containsObject:alertClass]) {

[notificationClasses release];

return nil;
//return %orig;
}
else{
[notificationClasses release];

return %orig;
}
}

%end


%hook SBAwayModel

-(void)populateWithMissedSMS:(id)missedSMS
{

}

-(void)populateWithMissedEnhancedVoiceMails:(id)missedEnhancedVoiceMails
{

}

%end

//Probably good to hook, so we can clean up locking and unlocking with the notificaions and stuff
%hook SBAwayView

-(id)initWithFrame:(CGRect)frame{
self = %orig;


if(self){
//bruceLSHolder *lsHolder = MSHookIvar<bruceLSHolder*>(self, "lsHolder");
//[self showOverlay];
loadPrefs();
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
lsHolder = [[bruceLSHolder alloc] initWithFrame:CGRectMake(0,160,320,235)];

[pool drain];
}

return self;
}

%new(v@:)
-(void)hideOverlay{
if(overlay){
overlay.hidden = TRUE;
}
}

%new(v@:)
-(void)unhideOverlay{
if(overlay){
overlay.hidden = FALSE;
}

}

%new(v@:)
-(void)showOverlay{

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
[self addSubview:lsHolder];
[lsHolder release];
lsLoaded = TRUE;
if(iOS7Style){

UIImage *lockImage = nil;
NSFileManager *fMgr = [NSFileManager defaultManager]; 
if (![fMgr fileExistsAtPath:@"/var/mobile/Library/LockBackground.jpg"]) { 
lockImage = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/HomeBackground.jpg"];
}
else{
lockImage = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockBackground.jpg"];
}

UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
UIView *lockBar = MSHookIvar<UIView *>(self, "_lockBar");
UIView *chargingView = MSHookIvar<UIView *>(self, "_chargingView");
UIView *albumArtView = MSHookIvar<UIView *>(self, "_albumArtView");
UIView *controlsView = MSHookIvar<UIView *>(dateView, "_controlsView");
[dateView removeFromSuperview];
[lockBar removeFromSuperview];
[controlsView removeFromSuperview];
//[chargingView removeFromSuperview];
albumArtView.hidden = TRUE;
overlay = [[UIImageView alloc] initWithFrame:CGRectMake(-10,0, 340, 480)];
//overlay.image = [[lockImage imageWithGaussianBlur] imageWithGaussianBlur];
if(darkerBackground){
if(blurBackground){
//overlay.image = [[UIImage imageWithContentsOfFile:@"/Library/Bruce/LockScreenBackgroundDarker.png"] mergeWithImage:[[lockImage imageWithGaussianBlur] imageWithGaussianBlur] withAlpha:1.0];
//overlay.image = [[UIImage imageWithContentsOfFile:@"/Library/Bruce/LockScreenBackgroundDarker.png"] stackBlur:30];
overlay.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockWallpaperBlurred_dark.png"];
}
else{
overlay.image = [[UIImage imageWithContentsOfFile:@"/Library/Bruce/LockScreenBackgroundDarker.png"] mergeWithImage:lockImage withAlpha:1.0];
}
}
else{
if(blurBackground){
//overlay.image = [[UIImage imageWithContentsOfFile:@"/Library/Bruce/LockScreenBackground.png"] mergeWithImage:[[lockImage imageWithGaussianBlur] imageWithGaussianBlur] withAlpha:1.0];
//overlay.image = [[UIImage imageWithContentsOfFile:@"/Library/Bruce/LockScreenBackground.png"] stackBlur:30];
overlay.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LockWallpaperBlurred.png"];
}
else{
overlay.image = [[UIImage imageWithContentsOfFile:@"/Library/Bruce/LockScreenBackground.png"] mergeWithImage:lockImage withAlpha:1.0];

}
}
overlay.userInteractionEnabled = TRUE;
//[self addSubview:albumArtView];
[self insertSubview:overlay atIndex:2];
//[self addSubview:chargingView];

[self addSubview:lockBar];
[self addSubview:dateView];
[self addSubview:controlsView];

[self bringSubviewToFront:lsHolder];
[self bringSubviewToFront:dateView];
[self bringSubviewToFront:controlsView];
[self bringSubviewToFront:lockBar];
//[self bringSubviewToFront:chargingView];
//[self bringSubviewToFront:albumArtView];

[overlay release];

}
showingOverlay = TRUE;
[pool drain];
}

//For hiding moving the alert screen down and back and such... Probably messes up passcode locks, but I haven't bothered testing that yet.
-(void)showMediaControls{
//lsHolder.hidden = TRUE;
//One of these was causing issues when the device re-locked because the lsHolder was not loaded/there anymore. So I had it check and see if it was loaded :P
if(lsLoaded){
UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");

lsHolder.frame = CGRectMake(0,175,320,195);
lsHolder.scroll.frame = CGRectMake(0,0,320,195);
}
%orig;
}

-(void)_hideMediaControls{
//lsHolder.hidden = FALSE;
if(lsLoaded){
UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
lsHolder.frame = CGRectMake(0,160,320,225);
lsHolder.scroll.frame = CGRectMake(0,0,320,225);
}
%orig;

}


-(void)hideMediaControls{
//lsHolder.hidden = FALSE;
if(lsLoaded){
UIView *dateView = MSHookIvar<UIView *>(self, "_dateView");
lsHolder.frame = CGRectMake(0,160,320,225);
lsHolder.scroll.frame = CGRectMake(0,0,320,225);
}
%orig;

}

%new(@@:)
-(BOOL)bruceEnabled{
return TRUE;
}

%new(@@:)
-(id)lsHolder{
	if(lsHolder){
return lsHolder;
}
else{
	return nil;
}
}
%end


%hook SBAwayDateView 
-(void)setIsShowingControls:(BOOL)controls{
%orig;
if(controls){
lsHolder.frame = CGRectMake(0,175,320,235);

}
else{
lsHolder.frame = CGRectMake(0,160,320,225);

}

}

%end




%hook SBAwayController

//Cleaning up...
-(void)unlockWithSound:(BOOL)sound{
//lsView.lsHolder.scroll.contentSize = CGSizeMake(320, 0);
BRUCE_LS_SCROLL_HEIGHT = 40;
lsLoaded = FALSE;
showingOverlay = FALSE;
%orig;
}

-(void)_unlockWithSound:(BOOL)sound{
//lsView.lsHolder.scroll.contentSize = CGSizeMake(320, 0);
BRUCE_LS_SCROLL_HEIGHT = 40;
lsLoaded = FALSE;
showingOverlay = FALSE;
%orig;

}

-(void)makeEmergencyCall
{
    %orig;
    [[self awayView] hideOverlay];
}

-(void)emergencyCallWasRemoved
{
    %orig;
    [[self awayView] unhideOverlay];
}

-(void)undimScreen
{
    %orig;
    SBTelephonyManager *telephonyManager = (SBTelephonyManager *)[%c(SBTelephonyManager) sharedTelephonyManager];


    if ([telephonyManager incomingCallExists])
    {
       [[self awayView] hideOverlay];
      
    }

}

%end
