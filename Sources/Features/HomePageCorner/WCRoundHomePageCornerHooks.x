#import "Sources/API/Internal.h"

%hook NewMainFrameViewController
- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section {
    CGFloat original=%orig(table,section);
    return WCRoundHomePageCornerFooterHeight(table,section,original);
}
- (UIView *)tableView:(UITableView *)table viewForFooterInSection:(NSInteger)section {
    UIView *original=%orig(table,section);
    return WCRoundHomePageCornerFooterView(table,section,original);
}
- (void)changeNavigationFakeBackgroundColor {
    %orig;
    WCRoundHomePageCornerAttach((UIViewController *)self);
}
%end

%hook MainFrameTableView
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutTable((UITableView *)self);
}
- (void)traitCollectionDidChange:(UITraitCollection *)previous {
    %orig(previous);
    if ([((UIView *)self).traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previous])
        WCRoundHomePageCornerThemeChanged();
}
%end
%hook NewMainFrameCell
- (void)setFrame:(CGRect)frame {
    CGRect adjusted=WCRoundHomePageCornerCellFrame((UITableViewCell *)self,frame);
    %orig(adjusted);
}
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutCell((UITableViewCell *)self);
}
- (void)updateCellBackground:(id)background {
    %orig(background);
    WCRoundHomePageCornerLayoutCell((UITableViewCell *)self);
}
- (void)prepareForReuse {
    WCRoundHomePageCornerRestoreCell((UITableViewCell *)self);
    %orig;
}
%end
%hook MMTableViewCell
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutCell((UITableViewCell *)self);
}
- (void)prepareForReuse {
    WCRoundHomePageCornerRestoreCell((UITableViewCell *)self);
    %orig;
}
%end
%hook MFBannerBtn
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutChrome((UIView *)self);
}
%end
%hook MFWebMMBtn
- (void)updateWithOnlineStatus {
    %orig;
    WCRoundHomePageCornerLayoutChrome((UIView *)self);
}
%end
%hook WCSearchBar
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutSearch((UIView *)self);
}
%end
%hook _UITableViewCellSwipeContainerView
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutSwipe((UIView *)self);
}
%end
%hook UISwipeActionPullView
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutSwipe(((UIView *)self).superview);
}
%end
%hook MainFrameSectionFoldView
- (void)layoutSubviews {
    %orig;
    WCRoundHomePageCornerLayoutChrome((UIView *)self);
}
%end
%hook MMDarkModeConfigUtil
+ (void)updateCurrentIsDarkMode:(BOOL)dark {
    static BOOL hasMode, lastMode;
    BOOL changed=!hasMode || lastMode!=dark;
    hasMode=YES;lastMode=dark;
    %orig(dark);
    if (changed) {
        WCRoundHomePageCornerThemeChanged();
    }
}
%end
%ctor {
    %init;
}
