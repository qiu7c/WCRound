#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
void WCRoundApplyGlobalAvatarRoundingToHeadView(UIView *headView);
BOOL WCRoundHeadViewIsExcludedFromGlobalAvatarRounding(UIView *headView);
void WCRoundRefreshTrackedGlobalAvatarViews(void);
unsigned int WCRoundGlobalAvatarScaledCornerSize(unsigned int originalSize);
NS_ASSUME_NONNULL_END
