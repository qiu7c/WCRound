#import <objc/runtime.h>
#import "Sources/API/Internal.h"

@interface WCRoundLocalEmoticonPreviewOwner : NSObject
@property (nonatomic, weak) UIView *view;
@end
@implementation WCRoundLocalEmoticonPreviewOwner
@end
static char WCEmoticonPreviewOwnerKey;

static BOOL WCEmoticonClass(UIView *view, NSString *name) {
    Class cls = NSClassFromString(name); return cls && [view isKindOfClass:cls];
}
static BOOL WCEmoticonHost(UIView *view) {
    for (UIView *host = view.superview; host; host = host.superview)
        if (WCEmoticonClass(host, @"EmoticonViewWithPreview")
            || WCEmoticonClass(host, @"EmoticonMessageCellView")
            || WCEmoticonClass(host, @"AppEmoticonMessageCellView")) return YES;
    WCRoundLocalEmoticonPreviewOwner *owner = objc_getAssociatedObject(view, &WCEmoticonPreviewOwnerKey);
    UIView *host = owner.view;
    id backdrop = WCRoundTweakSafeValue(host, @"m_emoticonPreviewBack");
    BOOL previewSlot = WCRoundTweakSafeValue(host, @"m_emoticonPreview") == view || WCRoundTweakSafeValue(host, @"m_emoticonShowPlayView") == view;
    return host.window && previewSlot && [WCRoundTweakSafeValue(host, @"m_isPreviewing") boolValue]
        && [backdrop isKindOfClass:UIView.class] && [view isDescendantOfView:backdrop];
}
void WCRoundEmoticonCornerLayout(UIView *view) {
    if (WCEmoticonClass(view, @"EmoticonViewWithPreview")) {
        for (NSString *key in @[@"m_emoticonView", @"m_emoticonPreview", @"m_emoticonShowPlayView"]) {
            id media = WCRoundTweakSafeValue(view, key);
            if ([media isKindOfClass:UIView.class]) {
                WCRoundLocalEmoticonPreviewOwner *owner = objc_getAssociatedObject(media, &WCEmoticonPreviewOwnerKey);
                if (!owner) { owner = [WCRoundLocalEmoticonPreviewOwner new]; objc_setAssociatedObject(media, &WCEmoticonPreviewOwnerKey, owner, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
                owner.view = view;
                WCRoundMediaCornerApply(media, WCRoundEmoticonCornerEnabledKey, WCRoundEmoticonCornerRadiusKey, WCEmoticonHost(media));
            }
        }
        return;
    }
    BOOL media = WCEmoticonClass(view, @"MMEmoticonView") || WCEmoticonClass(view, @"YYAsyncImageView");
    if (media) WCRoundMediaCornerApply(view, WCRoundEmoticonCornerEnabledKey, WCRoundEmoticonCornerRadiusKey, WCEmoticonHost(view));
}
