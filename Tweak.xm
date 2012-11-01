#import <UIKit/UIKit.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/jp.r-plus.CleanActivity.plist"

static BOOL cleanActivityIsEnabled;
static BOOL cleanTwitter;
static BOOL cleanFacebook;
static BOOL cleanWeibo;
static BOOL cleanMessage;
static BOOL cleanMail;
static BOOL cleanPrint;
static BOOL cleanPasteboard;
static BOOL cleanContact;
static BOOL cleanCameraRoll;
static BOOL isDisabledApplication;

%hook UIViewController
static inline void ApplyCleanActivity(UIViewController *vc)
{
  if (cleanActivityIsEnabled && !isDisabledApplication && [vc isKindOfClass:[UIActivityViewController class]]) {
    NSMutableArray *cleanArray = [NSMutableArray array];
    if (cleanTwitter)
      [cleanArray addObject:UIActivityTypePostToTwitter];
    if (cleanFacebook)
      [cleanArray addObject:UIActivityTypePostToFacebook];
    if (cleanWeibo)
      [cleanArray addObject:UIActivityTypePostToWeibo];
    if (cleanMessage)
      [cleanArray addObject:UIActivityTypeMessage];
    if (cleanMail)
      [cleanArray addObject:UIActivityTypeMail];
    if (cleanPrint)
      [cleanArray addObject:UIActivityTypePrint];
    if (cleanPasteboard)
      [cleanArray addObject:UIActivityTypeCopyToPasteboard];
    if (cleanContact)
      [cleanArray addObject:UIActivityTypeAssignToContact];
    if (cleanCameraRoll)
      [cleanArray addObject:UIActivityTypeSaveToCameraRoll];
    ((UIActivityViewController *)vc).excludedActivityTypes = cleanArray;
  }
}

#define APPLY_CLEAN_ACTIVITY ApplyCleanActivity(vc)

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)flag completion:(void (^)(void))completion
{
  APPLY_CLEAN_ACTIVITY;
  %orig;
}

// Deprecated method
- (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated
{
  APPLY_CLEAN_ACTIVITY;
  %orig;
}
%end

static void LoadSettings()
{
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];

  id enablePref = [dict objectForKey:@"Enabled"];
  cleanActivityIsEnabled = enablePref ? [enablePref boolValue] : YES;
  id twitterPref = [dict objectForKey:@"Twitter"];
  cleanTwitter = twitterPref ? [twitterPref boolValue] : NO;
  id facebookPref = [dict objectForKey:@"Facebook"];
  cleanFacebook = facebookPref ? [facebookPref boolValue] : NO;
  id weiboPref = [dict objectForKey:@"Weibo"];
  cleanWeibo = weiboPref ? [weiboPref boolValue] : YES;
  id messagePref = [dict objectForKey:@"Message"];
  cleanMessage = messagePref ? [messagePref boolValue] : YES;
  id mailPref = [dict objectForKey:@"Mail"];
  cleanMail = mailPref ? [mailPref boolValue] : YES;
  id printPref = [dict objectForKey:@"Print"];
  cleanPrint = printPref ? [printPref boolValue] : YES;
  id pasteboardPref = [dict objectForKey:@"Pasteboard"];
  cleanPasteboard = pasteboardPref ? [pasteboardPref boolValue] : NO;
  id contactPref = [dict objectForKey:@"Contact"];
  cleanContact = contactPref ? [contactPref boolValue] : YES;
  id cameraRollPref = [dict objectForKey:@"Contact"];
  cleanCameraRoll = cameraRollPref ? [cameraRollPref boolValue] : YES;

  NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
  NSString *key = [@"CADisable-" stringByAppendingString:bundleIdentifier];
  id disablePref = [dict objectForKey:key];
  isDisabledApplication = disablePref ? [disablePref boolValue] : NO;
}

static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
  LoadSettings();
}

%ctor
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("jp.r-plus.CleanActivity.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
  LoadSettings();

  [pool drain];
}
