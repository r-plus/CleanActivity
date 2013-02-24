#import <UIKit/UIKit.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/jp.r-plus.CleanActivity.plist"

static BOOL cleanActivityIsEnabled;
static BOOL isDisabledApplication = YES;
// UIKit
static BOOL cleanTwitter;
static BOOL cleanFacebook;
static BOOL cleanWeibo;
static BOOL cleanMessage;
static BOOL cleanMail;
static BOOL cleanPrint;
static BOOL cleanPasteboard;
static BOOL cleanContact;
static BOOL cleanCameraRoll;
// Photo
static BOOL cleanAlbumStream;
static BOOL cleanYoutube;
static BOOL cleanTodou;
static BOOL cleanYouku;
static BOOL cleanWallpaper;
// AppStore and iTunes
static BOOL cleanGift;

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
  if (cleanContact) {
    [cleanArray addObject:UIActivityTypeAssignToContact];
    [cleanArray addObject:@"PLActivityTypeAssignToContact"];
  }
  if (cleanCameraRoll)
    [cleanArray addObject:UIActivityTypeSaveToCameraRoll];
  if (cleanAlbumStream)
    [cleanArray addObject:@"PLActivityTypeAlbumStream"];
  if (cleanYoutube)
    [cleanArray addObject:@"PLActivityTypePublishToYouTube"];
  if (cleanTodou)
    [cleanArray addObject:@"PLActivityTypePublishToTudou"];
  if (cleanYouku)
    [cleanArray addObject:@"PLActivityTypePublishToYouku"];
  if (cleanWallpaper)
    [cleanArray addObject:@"PLActivityTypeUseAsWallpaper"];
  if (cleanGift)
    [cleanArray addObject:@"com.apple.AppStore.gift"];
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
  // UIKit
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
  // Photo
  id albumStreamPref = [dict objectForKey:@"AlbumStream"];
  cleanAlbumStream = albumStreamPref ? [albumStreamPref boolValue] : NO;
  id youtubePref = [dict objectForKey:@"Youtube"];
  cleanYoutube = youtubePref ? [youtubePref boolValue] : NO;
  id todouPref = [dict objectForKey:@"Todou"];
  cleanTodou = todouPref ? [todouPref boolValue] : YES;
  id youkuPref = [dict objectForKey:@"Youku"];
  cleanYouku = youkuPref ? [youkuPref boolValue] : YES;
  id wallpaperPref = [dict objectForKey:@"Wallpaper"];
  cleanWallpaper = wallpaperPref ? [wallpaperPref boolValue] : NO;
  // AppStore and iTunes
  id giftPref = [dict objectForKey:@"Gift"];
  cleanGift = giftPref ? [giftPref boolValue] : NO;

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
