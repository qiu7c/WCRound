#import "Sources/API/Internal.h"
%hook ImageMessageCellView
- (void)layoutContentView {
    %orig;
    WCRoundChatImageCornerLayout((UIView *)self);
}
- (void)layoutSubviews {
    %orig;
    WCRoundChatImageCornerLayout((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundChatImageCornerLayout((UIView *)self);
}
%end
%hook VideoMessageCellView
- (void)layoutContentView {
    %orig;
    WCRoundChatImageCornerLayout((UIView *)self);
}
- (void)layoutSubviews {
    %orig;
    WCRoundChatImageCornerLayout((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundChatImageCornerLayout((UIView *)self);
}
%end
%ctor {
    %init;
}
