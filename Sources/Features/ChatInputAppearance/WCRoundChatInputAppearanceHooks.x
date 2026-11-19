#import "Sources/API/Internal.h"

%hook MMInputToolView
- (void)didMoveToWindow {
    %orig;
    WCRoundChatInputRoundingApply(self);
}
- (void)layoutSubviews {
    %orig;
    WCRoundChatInputRoundingApply(self);
}
%end

%ctor {
    %init;
}
