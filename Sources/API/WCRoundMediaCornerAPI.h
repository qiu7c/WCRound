#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
void WCRoundMediaCornerApply(UIView *view, NSString *enabledKey, NSString *radiusKey, BOOL eligible);
void WCRoundMediaCornerViewDidLayout(UIView *view);
void WCRoundMediaCornerReset(UIView *root);
void WCRoundMediaCornerSettingsChanged(NSString * _Nullable key);
void WCRoundEmoticonCornerLayout(UIView *view);
void WCRoundChatImageCornerLayout(UIView *view);
NS_ASSUME_NONNULL_END
