#import <math.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "Sources/API/Internal.h"

static __thread NSUInteger WCLayoutThemeLookupDepth;
static char WCLayoutOriginalWebZoomKey;

BOOL WCRoundLayoutScaleEnabled(void) {
    return WCRoundEnabled(WCRoundPageScaleEnabledKey);
}

double WCRoundLayoutScaleFactor(void) {
    if (!WCRoundLayoutScaleEnabled()) return 1.0;
    double percent = [[NSUserDefaults standardUserDefaults] doubleForKey:WCRoundPageScalePercentKey];
    if (!isfinite(percent)) percent = 90.0;
    return MIN(100.0, MAX(70.0, percent)) / 100.0;
}

void WCRoundLayoutBeginThemeLookup(void) {
    WCLayoutThemeLookupDepth++;
}

id WCRoundLayoutEndThemeLookup(id value, id property, id ruleSet) {
    if (WCLayoutThemeLookupDepth == 0) return value;
    WCLayoutThemeLookupDepth--;
    if (WCLayoutThemeLookupDepth != 0 || !WCRoundLayoutScaleEnabled()) return value;
    if (![ruleSet isKindOfClass:NSString.class] || ![ruleSet isEqualToString:@"#font_set"] ||
        ![property isKindOfClass:NSString.class] ||
        (![property isEqualToString:@"alllevel"] && ![property isEqualToString:@"chatLevel"]) ||
        ![value isKindOfClass:NSArray.class] || [value count] == 0) return value;

    // Preserve the host's theme cache when applying the percentage.
    id first = [value firstObject];
    double number = 0.0;
    if ([first isKindOfClass:NSNumber.class]) {
        number = [first doubleValue];
    } else if ([first isKindOfClass:NSString.class]) {
        NSScanner *scanner = [NSScanner scannerWithString:first];
        if (![scanner scanDouble:&number] || !scanner.isAtEnd) return value;
    } else {
        return value;
    }
    if (!isfinite(number)) return value;
    double scaled = number * WCRoundLayoutScaleFactor();
    if (!isfinite(scaled)) return value;
    id replacement = @(scaled);
    if ([first isKindOfClass:NSString.class]) {
        NSDecimalNumber *decimal = [NSDecimalNumber decimalNumberWithString:first];
        NSDecimalNumber *factor = [NSDecimalNumber decimalNumberWithString:
            [NSString stringWithFormat:@"%.4f", WCRoundLayoutScaleFactor()]];
        NSDecimalNumber *result = [decimal decimalNumberByMultiplyingBy:factor];
        if ([result isEqualToNumber:NSDecimalNumber.notANumber]) return value;
        replacement = result.stringValue;
    }
    NSMutableArray *copy = [value mutableCopy];
    copy[0] = replacement;
    return copy;
}

double WCRoundLayoutWebViewZoom(id webView, double requestedFactor) {
    objc_setAssociatedObject(webView, &WCLayoutOriginalWebZoomKey, @(requestedFactor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return WCRoundLayoutScaleEnabled() ? WCRoundLayoutScaleFactor() : requestedFactor;
}

void WCRoundLayoutApplyWebView(id webView) {
    SEL selector = NSSelectorFromString(@"_setTextZoomFactor:");
    if (![webView respondsToSelector:selector]) return;
    NSNumber *original = objc_getAssociatedObject(webView, &WCLayoutOriginalWebZoomKey);
    if (!original && !WCRoundLayoutScaleEnabled()) return;
    ((void (*)(id, SEL, CGFloat))objc_msgSend)(webView, selector, original ? original.doubleValue : 1.0);
}

void WCRoundLayoutSettingsChanged(NSString *key) {
    if (key && ![key isEqualToString:WCRoundPageScaleEnabledKey] &&
        ![key isEqualToString:WCRoundPageScalePercentKey] &&
        ![key isEqualToString:WCRoundPageScalePluginUIKey] &&
        ![key isEqualToString:WCRoundEnabledKey]) return;
    NSArray<UIWindow *> *windows = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive || ![scene isKindOfClass:UIWindowScene.class]) continue;
        windows = ((UIWindowScene *)scene).windows;
        if (windows.count) break;
    }
    if (!windows.count) {
        id all = WCRoundTweakSafeValue(UIApplication.sharedApplication, @"windows");
        if ([all isKindOfClass:NSArray.class]) windows = all;
    }
    UIWindow *window = nil;
    for (UIWindow *candidate in windows) {
        if (candidate.isKeyWindow && !candidate.hidden && candidate.alpha > 0) { window = candidate; break; }
    }
    if (!window) for (UIWindow *candidate in windows) {
        if (!candidate.hidden && candidate.alpha > 0 && candidate.rootViewController) { window = candidate; break; }
    }
    if (!window) window = windows.firstObject;
    if (!window) return;
    NSMutableArray<UIView *> *stack = [NSMutableArray arrayWithObject:window];
    while (stack.count) {
        UIView *view = stack.lastObject;
        [stack removeLastObject];
        if ([view isKindOfClass:WKWebView.class]) WCRoundLayoutApplyWebView(view);
        [view setNeedsLayout];
        [stack addObjectsFromArray:view.subviews];
    }
}
