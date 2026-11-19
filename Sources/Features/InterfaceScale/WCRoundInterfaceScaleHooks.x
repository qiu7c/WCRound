#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "Sources/API/Internal.h"

#pragma mark - Chat layout hooks

// Theme manager overloads and the proxy may call one another. Only the
// outermost lookup applies the percentage; finally also balances exceptions.
%hook MMThemeManager

- (id)getValueOfProperty:(id)property inRuleSet:(id)ruleSet {
    id value = nil;
    WCRoundLayoutBeginThemeLookup();
    @try {
        value = %orig;
    }
    @finally { value = WCRoundLayoutEndThemeLookup(value, property, ruleSet); }
    return value;
}

- (id)getValueOfProperty:(id)property inRuleSet:(id)ruleSet isAdapt:(BOOL)isAdapt {
    id value = nil;
    WCRoundLayoutBeginThemeLookup();
    @try {
        value = %orig;
    }
    @finally { value = WCRoundLayoutEndThemeLookup(value, property, ruleSet); }
    return value;
}

%end

%hook WAThemeProxy

+ (id)getValueOfProperty:(id)property inRuleSet:(id)ruleSet {
    id value = nil;
    WCRoundLayoutBeginThemeLookup();
    @try {
        value = %orig;
    }
    @finally { value = WCRoundLayoutEndThemeLookup(value, property, ruleSet); }
    return value;
}

%end

%hook WKWebView

- (id)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    id webView = %orig;
    WCRoundLayoutApplyWebView(webView);
    return webView;
}

- (void)didMoveToWindow {
    %orig;
    WCRoundLayoutApplyWebView(self);
}

- (void)_setTextZoomFactor:(CGFloat)factor {
    CGFloat resolved = WCRoundLayoutWebViewZoom(self, factor);
    %orig(resolved);
}

%end

// Text size: WeChat asks CLocalInfo for the global font level on every layout
// pass, so overriding the getter makes native chat layout reflow at our size.
%hook CLocalInfo

- (unsigned int)m_uiWebviewFontLevel {
    unsigned int original = %orig;
    return WCRoundLayoutScaleEnabled() ? 1 : original;
}

- (unsigned int)m_uiGlobalFontLevel {
    unsigned int original = %orig;
    return WCRoundLayoutScaleEnabled() ? 1 : original;
}

%end

%ctor {
    %init;
}
