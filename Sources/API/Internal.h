#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <math.h>
#import <string.h>
#import "Sources/Core/Config.h"

FOUNDATION_EXPORT NSNotificationName const WCRoundDidChangeNotification;
CGFloat WCRoundSettingsScaleFactor(void);
id WCRoundTweakSafeValue(id object, NSString *key);
id WCRoundServiceForClass(Class cls);
id WCRoundPrivateContact(NSString *user);
NSString *WCRoundCurrentUserWXID(void);
UIView *WCRoundContactAvatarView(NSString *user);
UIImage *WCRoundSettingsBackImage(void);
void WCRoundSettingsConfigureNavigation(UIViewController *controller);
void WCRoundSettingsPostChange(NSString *key);
UITableViewCell *WCRoundSettingsCardCell(UITableView *table, NSString *identifier, UITableViewCellStyle style, NSIndexPath *path);
UIViewController *WCRoundCreateCornerSettingsController(void);
UIViewController *WCRoundCreateCornerPreview(NSInteger kind);
UIViewController *WCRoundCreateSettingsController(void);
void WCRoundRefreshEntry(UIViewController *controller);
void WCRoundRegisterEntry(void);
#import "Sources/API/WCRoundHomePageCornerAPI.h"
#import "Sources/API/WCRoundHomeGroupsAPI.h"
#import "Sources/API/WCRoundAvatarAppearanceAPI.h"
#import "Sources/API/WCRoundChatInputAppearanceAPI.h"
#import "Sources/API/WCRoundMomentsImageCornerAPI.h"
#import "Sources/API/WCRoundMediaCornerAPI.h"
#import "Sources/API/WCRoundPopupAPI.h"

@interface NewMainFrameViewController : UIViewController
@end

@interface MainFrameTableView : UITableView
@end

@interface MMTableViewCell : UITableViewCell
@end

@interface NewMainFrameCell : MMTableViewCell
@end

@interface MFBannerBtn : UIButton
@end

@interface MFWebMMBtn : MFBannerBtn
@end

@interface WCSearchBar : UISearchBar
@end

@interface MainFrameSectionFoldView : UIView
@end

@interface MMHeadImageView : UIView
@end

@interface FakeHeadImageView : UIView
@end

@interface MMInputToolView : UIView
@end

@interface EmoticonViewWithPreview : UIView
@end

@interface MMEmoticonView : UIView
@end

@interface CommonMessageCellView : UIView
@end

@interface ImageMessageCellView : CommonMessageCellView
@end

@interface VideoMessageCellView : CommonMessageCellView
@end

@interface WCTimeLineCellView : UIView
@end

@interface WCListBaseCellView : UIView
@end

@interface WCListPhotoCellView : WCListBaseCellView
@end

@interface WCListSightCellView : WCListBaseCellView
@end

@interface WCListHybridCellView : WCListBaseCellView
@end

@interface WCContentItemViewTemplateGrid : UIView
@end

@interface WCSNSNodeVideoView : UIView
@end

@interface MMImageGridView : UIView
@end

@interface WCFinderWXContactEntranceView : UIView
@end

@interface WeixinContactInfoAssist : NSObject
@end

@interface MMDarkModeConfigUtil : NSObject
@end

#import "Sources/Integration/HomeAppearanceBridge.h"

@interface MoreViewController : UIViewController
@end

UIViewController *WCRoundCreatePluginSettingsController(void);
UIView *WCRoundSettingsFooter(CGFloat width);
