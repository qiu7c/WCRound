#import "Sources/API/Internal.h"

%hook EmoticonViewWithPreview
- (void)layoutSubviews {
    %orig;
    WCRoundEmoticonCornerLayout((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundEmoticonCornerLayout((UIView *)self);
}
- (void)showPreview {
    %orig;
    WCRoundEmoticonCornerLayout((UIView *)self);
}
- (void)hidePreview {
    %orig;
    WCRoundEmoticonCornerLayout((UIView *)self);
}
%end
%hook MMEmoticonView
- (void)layoutSubviews {
    %orig;
    WCRoundEmoticonCornerLayout((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundEmoticonCornerLayout((UIView *)self);
}
- (BOOL)setEmoticonWrap:(id)wrap PlayGif:(BOOL)play {
    BOOL result = %orig(wrap, play);
    WCRoundEmoticonCornerLayout((UIView *)self);
    return result;
}
%end
%ctor {
    %init;
}
