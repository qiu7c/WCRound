#import "Sources/API/Internal.h"

NSString *const WCRoundHomePageCornerEnabledKey = @"com.qiu7c.wcround.home.corner.enabled";
NSString *const WCRoundHomePageCornerRadiusKey = @"com.qiu7c.wcround.home.corner.radius";
NSString *const WCRoundHomePageCornerInsetKey = @"com.qiu7c.wcround.home.corner.inset";
NSString *const WCRoundHomePageCornerGapKey = @"com.qiu7c.wcround.home.corner.gap";
NSString *const WCRoundHomePageCornerMergePinnedKey = @"com.qiu7c.wcround.home.corner.mergePinned";
NSString *const WCRoundEmoticonCornerEnabledKey = @"com.qiu7c.wcround.interface.emoticon-corner.enabled";
NSString *const WCRoundEmoticonCornerRadiusKey = @"com.qiu7c.wcround.interface.emoticon-corner.radius";
NSString *const WCRoundChatImageCornerEnabledKey = @"com.qiu7c.wcround.interface.chat-image-corner.enabled";
NSString *const WCRoundChatImageCornerRadiusKey = @"com.qiu7c.wcround.interface.chat-image-corner.radius";
NSString *const WCRoundMomentsImageCornerEnabledKey = @"com.qiu7c.wcround.moments.image-corner.enabled";
NSString *const WCRoundMomentsImageCornerRadiusKey = @"com.qiu7c.wcround.moments.image-corner.radius";
NSString *const WCRoundGlobalAvatarRoundingEnabledKey = @"com.qiu7c.wcround.interface.global-avatar-rounding";
NSString *const WCRoundGlobalAvatarCornerPercentKey = @"com.qiu7c.wcround.interface.global-avatar-corner-percent";
NSString *const WCRoundChatInputRoundingEnabledKey = @"com.qiu7c.wcround.interface.chat-input-rounding.enabled";
NSString *const WCRoundChatInputInnerRoundingKey = @"com.qiu7c.wcround.interface.chat-input-rounding.inner";
NSString *const WCRoundChatInputOuterRoundingKey = @"com.qiu7c.wcround.interface.chat-input-rounding.outer";
NSString *const WCRoundChatInputInnerRadiusKey = @"com.qiu7c.wcround.interface.chat-input-rounding.inner-radius";
NSString *const WCRoundChatInputOuterRadiusKey = @"com.qiu7c.wcround.interface.chat-input-rounding.outer-radius";
NSString *const WCRoundEnabledKey = @"com.qiu7c.wcround.enabled";

NSDictionary *WCRoundDefaultSettings(void) {
    return @{
        WCRoundHomePageCornerEnabledKey: @NO,
        WCRoundHomePageCornerRadiusKey: @16,
        WCRoundHomePageCornerInsetKey: @16,
        WCRoundHomePageCornerGapKey: @8,
        WCRoundHomePageCornerMergePinnedKey: @NO,
        WCRoundEmoticonCornerEnabledKey: @NO,
        WCRoundEmoticonCornerRadiusKey: @8.0,
        WCRoundChatImageCornerEnabledKey: @NO,
        WCRoundChatImageCornerRadiusKey: @8.0,
        WCRoundMomentsImageCornerEnabledKey: @NO,
        WCRoundMomentsImageCornerRadiusKey: @8.0,
        WCRoundGlobalAvatarRoundingEnabledKey: @NO,
        WCRoundGlobalAvatarCornerPercentKey: @100.0,
        WCRoundChatInputRoundingEnabledKey: @NO,
        WCRoundChatInputInnerRoundingKey: @YES,
        WCRoundChatInputOuterRoundingKey: @YES,
        WCRoundChatInputInnerRadiusKey: @18.0,
        WCRoundChatInputOuterRadiusKey: @22.0,
        WCRoundEnabledKey: @YES,
    };
}

void WCRoundRegisterDefaults(void) {
    [NSUserDefaults.standardUserDefaults registerDefaults:WCRoundDefaultSettings()];
}

BOOL WCRoundEnabled(NSString *key) {
    return [NSUserDefaults.standardUserDefaults boolForKey:WCRoundEnabledKey] && [NSUserDefaults.standardUserDefaults boolForKey:key];
}
