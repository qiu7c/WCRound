#import "Sources/API/Internal.h"

%hook MoreViewController
- (void)addFunctionSection {
    %orig;
    WCRoundRefreshEntry((UIViewController *)self);
}
- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);
    WCRoundRefreshEntry((UIViewController *)self);
}
%new
- (void)wcr_openSettings {
    [((UIViewController *)self).navigationController pushViewController:WCRoundCreateSettingsController() animated:YES];
}
%end

%ctor {
    %init;
}
