#import "Sources/API/Internal.h"

NSNotificationName const WCRoundDidChangeNotification = @"com.qiu7c.wcround.changed";

%hook UIView
- (void)layoutSubviews {
    %orig;
    WCRoundMomentsImageCornerViewDidLayout(self);
    WCRoundMediaCornerViewDidLayout(self);
}
%end

%ctor {
    @autoreleasepool {
        WCRoundRegisterDefaults();
        %init;
        dispatch_async(dispatch_get_main_queue(), ^{ WCRoundRegisterEntry(); });
        [NSNotificationCenter.defaultCenter addObserverForName:WCRoundDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
            WCRoundHomePageCornerSettingsChanged(note.object);
            WCRoundRefreshTrackedGlobalAvatarViews();
            WCRoundChatInputRoundingSettingsChanged(note.object);
            WCRoundMomentsImageCornerSettingsChanged(note.object);
            WCRoundMediaCornerSettingsChanged(note.object);
        }];
    }
}
