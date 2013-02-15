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
static BOOL isDisabledApplication = YES;

static inline NSArray *CleanActivities()
{
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
  return cleanArray;
}

%hook UIActivityViewController
- (NSArray *)excludedActivityTypes
{
  NSArray *originalExcludes = %orig;
  if (!cleanActivityIsEnabled || isDisabledApplication)
    return originalExcludes;
  return CleanActivities();

/*  if (originalExcludes) {*/
/*    NSMutableSet *set = [NSMutableSet setWithArray:originalExcludes];*/
/*    [set addObjectsFromArray:CleanActivities()];*/
/*    return [set allObjects];*/
/*  } else {*/
/*    return CleanActivities();*/
/*  }*/
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
  id cameraRollPref = [dict objectForKey:@"CameraRoll"];
  cleanCameraRoll = cameraRollPref ? [cameraRollPref boolValue] : YES;

  NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
  // If dylib load to daemon, bundleIdentifier = nil.
  // stringByAppendingString:nil call will crash daemon.
  if (bundleIdentifier) {
    NSString *key = [@"CADisable-" stringByAppendingString:bundleIdentifier];
    id disablePref = [dict objectForKey:key];
    isDisabledApplication = disablePref ? [disablePref boolValue] : NO;
  }
}

static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
  LoadSettings();
}

%ctor
{
  @autoreleasepool {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("jp.r-plus.CleanActivity.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    LoadSettings();
  }
}
