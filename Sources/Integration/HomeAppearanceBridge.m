#import <objc/message.h>
#import "Sources/API/Internal.h"

@interface WCRoundHomeIntegration : NSObject <WCHomeCornersIntegration>
@end
@implementation WCRoundHomeIntegration
+ (BOOL)enabled { return WCRoundHomePageCornerEnabled(); }
+ (BOOL)isDark:(UIView *)view { return WCRoundHomePageIsDark(view); }
+ (UIColor *)color:(UIView *)view surface:(BOOL)surface { return WCRoundHomePageCornerColor(view, surface); }
+ (CGFloat)inset { return WCRoundHomePageCornerInset(); }
+ (CGFloat)gap { return WCRoundHomePageCornerGap(); }
+ (NSInteger)mergedSection:(UITableView *)table { return WCRoundHomePageCornerMergedSection(table); }
+ (void)layoutGroup:(UIView *)banner nativeHeight:(CGFloat)nativeHeight height:(CGFloat)height joined:(BOOL)joined {
    WCRoundHomePageCornerLayoutGroup(banner, nativeHeight, height, joined);
}
+ (void)attach:(UIViewController *)controller { WCRoundHomePageCornerAttach(controller); }
@end

BOOL WCRoundHomeGroupsEnabled(void) {
    return [(Class<WCHomeGroupsIntegration>)NSClassFromString(@"WCGroupsHomeIntegration") enabled];
}
void WCRoundHomeGroupsRefreshAppearance(void) {
    [(Class<WCHomeGroupsIntegration>)NSClassFromString(@"WCGroupsHomeIntegration") refreshAppearance];
}
