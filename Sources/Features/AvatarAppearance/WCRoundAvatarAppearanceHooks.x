#import "Sources/API/Internal.h"

%hook MMHeadImageView
- (void)layoutSubviews {
    %orig;
    WCRoundApplyGlobalAvatarRoundingToHeadView(self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundApplyGlobalAvatarRoundingToHeadView(self);
}
- (void)setConerSize:(unsigned int)cornerSize {
    unsigned int value = WCRoundHeadViewIsExcludedFromGlobalAvatarRounding(self)
        ? cornerSize : WCRoundGlobalAvatarScaledCornerSize(cornerSize);
    %orig(value);
}
%end

%hook FakeHeadImageView
- (void)layoutSubviews {
    %orig;
    WCRoundApplyGlobalAvatarRoundingToHeadView(self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundApplyGlobalAvatarRoundingToHeadView(self);
}
- (void)setConerSize:(unsigned int)cornerSize {
    unsigned int value = WCRoundHeadViewIsExcludedFromGlobalAvatarRounding(self)
        ? cornerSize : WCRoundGlobalAvatarScaledCornerSize(cornerSize);
    %orig(value);
}
%end

%ctor {
    %init;
}
