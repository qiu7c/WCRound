#import "Sources/API/Internal.h"

%hook NewMainFrameViewController
- (void)viewDidLoad {
    %orig;
    WCRoundHomePageCornerAttach((UIViewController *)self);
}
- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);
    WCRoundHomePageCornerAttach((UIViewController *)self);
}
- (void)viewDidLayoutSubviews {
    %orig;
    WCRoundHomePageCornerAttach((UIViewController *)self);
}
- (void)tableView:(UITableView *)table willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)path {
    %orig(table, cell, path);
    WCRoundHomePageCornerLayoutCell(cell);
}
- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section {
    CGFloat native = %orig(table, section);
    return WCRoundHomePageCornerHeaderHeight(table, section, native);
}
- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section {
    UIView *native = %orig(table, section);
    return WCRoundHomePageCornerHeaderView(table, section, native);
}
%end

%hook WCTimeLineCellView
- (void)layoutSubviews {
    %orig;
    WCRoundMomentsImageCornerLayout((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundMomentsImageCornerLayout((UIView *)self);
}
- (void)setViewModel:(id)model {
    WCRoundMomentsImageCornerReset((UIView *)self);
    %orig(model);
}
- (void)prepareForReuse {
    WCRoundMomentsImageCornerReset((UIView *)self);
    %orig;
}
- (void)updateWithDataItem:(id)item actionAreaVM:(id)model {
    WCRoundMomentsImageCornerReset((UIView *)self);
    %orig(item, model);
    WCRoundMomentsImageCornerLayout((UIView *)self);
}
%end

%hook CommonMessageCellView
- (void)setViewModel:(id)model {
    WCRoundMediaCornerReset((UIView *)self);
    %orig(model);
}
- (void)prepareForReuse {
    WCRoundMediaCornerReset((UIView *)self);
    %orig;
}
%end

%ctor {
    %init;
}
