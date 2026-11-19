#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
void WCRoundChatInputRoundingApply(UIView *toolView);
void WCRoundChatInputRoundingSettingsChanged(NSString * _Nullable key);
/// Shared by the native controls and the full-page preview. Preview mode can
/// show configured radii without enabling the actual feature.
void WCRoundChatInputRoundingApplyToViews(UIView * _Nullable inner, UIView * _Nullable outer, BOOL preview);
CGFloat WCRoundChatInputRoundingRadius(BOOL inner, CGFloat height);
NS_ASSUME_NONNULL_END
