#import "Sources/API/Internal.h"

%hook WCListBaseCellView
- (void)layoutSubviews {
    %orig;
    WCRoundMomentsImageCornerLayout(self);
}
- (void)setGroupItem:(id)item inGroup:(id)group {
    WCRoundMomentsImageCornerReset(self);
    %orig;
    WCRoundMomentsImageCornerLayout(self);
}
%end

%hook WCContentItemViewTemplateGrid
- (void)layoutSubviews {
    %orig;
    WCRoundMomentsImageCornerLayout(self);
}
%end

%hook WCSNSNodeVideoView
- (void)layoutSubviews {
    %orig;
    WCRoundMomentsImageCornerLayout(self);
}
%end

%hook MMImageGridView
- (void)layoutSubviews {
    %orig;
    WCRoundMomentsImageCornerLayout(self);
}
%end

%hook WCListPhotoCellView
- (void)initImageGridView {
    %orig;
    WCRoundMomentsImageCornerLayout(self);
    WCRoundMomentsImageCornerViewDidLayout(self);
}
%end

%hook WCListSightCellView
- (void)initTailView {
    %orig;
    WCRoundMomentsImageCornerLayout((UIView *)self);
    WCRoundMomentsImageCornerViewDidLayout((UIView *)self);
}
%end

%hook WCListHybridCellView
- (void)reloadItemContainerView {
    %orig;
    WCRoundMomentsImageCornerLayout((UIView *)self);
    WCRoundMomentsImageCornerViewDidLayout((UIView *)self);
}
%end

%hook WeixinContactInfoAssist
- (id)getAlbumView {
    id view = %orig;
    WCRoundMomentsImageCornerRegisterProfile(view);
    return view;
}
- (void)albumView:(id)view displayCellsWithDataItems:(id)items cellLeftContext:(double *)context {
    %orig;
    WCRoundMomentsImageCornerRegisterProfile(view);
}
%end

%hook WCFinderWXContactEntranceView
- (void)layoutSubviews {
    %orig;
    WCRoundMomentsImageCornerFinderLayout((UIView *)self);
}
- (void)didMoveToWindow {
    %orig;
    WCRoundMomentsImageCornerFinderLayout((UIView *)self);
}
%end

%ctor {
    %init;
}
