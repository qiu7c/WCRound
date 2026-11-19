#import <math.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "Sources/API/Internal.h"

@interface WCRoundLocalInputRoundingState : NSObject
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) BOOL masks;
@property (nonatomic, copy) NSString *curve;
@end
@implementation WCRoundLocalInputRoundingState
@end

@interface WCRoundLocalInputRoundingTargets : NSObject
@property (nonatomic, weak) UIView *inner;
@property (nonatomic, weak) UIView *outer;
@end
@implementation WCRoundLocalInputRoundingTargets
@end

static char WCInputRoundingStateKey;
static char WCInputRoundingTargetsKey;

static NSHashTable<UIView *> *WCInputRoundingTools(void) {
    static NSHashTable<UIView *> *tools;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ tools = [NSHashTable weakObjectsHashTable]; });
    return tools;
}

CGFloat WCRoundChatInputRoundingRadius(BOOL inner, CGFloat height) {
    NSString *key = inner ? WCRoundChatInputInnerRadiusKey : WCRoundChatInputOuterRadiusKey;
    id stored = [NSUserDefaults.standardUserDefaults objectForKey:key];
    double radius = [stored respondsToSelector:@selector(doubleValue)] ? [stored doubleValue] : (inner ? 18 : 22);
    if (!isfinite(radius)) radius = inner ? 18 : 22;
    radius = MIN(40, MAX(0, radius));
    return isfinite(height) && height > 0 ? MIN(radius, height * 0.5) : radius;
}

static void WCInputSetRounded(UIView *view, BOOL enabled, BOOL inner) {
    if (!view) return;
    WCRoundLocalInputRoundingState *saved = objc_getAssociatedObject(view, &WCInputRoundingStateKey);
    if (enabled) {
        if (!saved) {
            saved = [WCRoundLocalInputRoundingState new];
            saved.radius = view.layer.cornerRadius; saved.masks = view.layer.masksToBounds;
            saved.curve = view.layer.cornerCurve ?: kCACornerCurveCircular;
            objc_setAssociatedObject(view, &WCInputRoundingStateKey, saved, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        CGFloat radius = WCRoundChatInputRoundingRadius(inner, CGRectGetHeight(view.bounds));
        if (fabs(view.layer.cornerRadius - radius) > 0.01) view.layer.cornerRadius = radius;
        if (![view.layer.cornerCurve isEqualToString:kCACornerCurveContinuous]) view.layer.cornerCurve = kCACornerCurveContinuous;
        if (!view.layer.masksToBounds) view.layer.masksToBounds = YES;
    } else if (saved) {
        view.layer.cornerRadius = saved.radius; view.layer.masksToBounds = saved.masks;
        view.layer.cornerCurve = saved.curve;
        objc_setAssociatedObject(view, &WCInputRoundingStateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

void WCRoundChatInputRoundingApplyToViews(UIView *inner, UIView *outer, BOOL preview) {
    NSUserDefaults *d = NSUserDefaults.standardUserDefaults;
    BOOL enabled = preview || WCRoundEnabled(WCRoundChatInputRoundingEnabledKey);
    WCInputSetRounded(inner, enabled && [d boolForKey:WCRoundChatInputInnerRoundingKey], YES);
    if (outer != inner) WCInputSetRounded(outer, enabled && [d boolForKey:WCRoundChatInputOuterRoundingKey], NO);
}

static UIView *WCInputFindGrowView(UIView *root) {
    if ([NSStringFromClass(root.class) containsString:@"MMGrowTextView"]) return root;
    for (UIView *child in root.subviews) {
        UIView *match = WCInputFindGrowView(child);
        if (match) return match;
    }
    return nil;
}

void WCRoundChatInputRoundingApply(UIView *toolView) {
    [WCInputRoundingTools() addObject:toolView];
    WCRoundLocalInputRoundingTargets *targets = objc_getAssociatedObject(toolView, &WCInputRoundingTargetsKey);
    BOOL enabled = toolView.window && WCRoundEnabled(WCRoundChatInputRoundingEnabledKey);
    // Preserve WCAtlas's fast disabled path: no traversal unless restoring.
    if (!enabled) {
        WCInputSetRounded(targets.inner, NO, YES); WCInputSetRounded(targets.outer, NO, NO);
        if (targets) objc_setAssociatedObject(toolView, &WCInputRoundingTargetsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return;
    }
    if (!targets) {
        targets = [WCRoundLocalInputRoundingTargets new];
        objc_setAssociatedObject(toolView, &WCInputRoundingTargetsKey, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UIView *inner = targets.inner;
    if (!inner || ![inner isDescendantOfView:toolView]) {
        WCInputSetRounded(inner, NO, YES);
        id candidate = WCRoundTweakSafeValue(toolView, @"textView") ?: WCRoundTweakSafeValue(toolView, @"_textView");
        inner = [candidate isKindOfClass:UIView.class] && [NSStringFromClass([candidate class]) containsString:@"MMGrowTextView"]
            && [candidate isDescendantOfView:toolView] ? candidate : WCInputFindGrowView(toolView);
        targets.inner = inner;
    }
    // The supplied view tree confirms InputToolContainerView is the first
    // visible toolbar under MMInputToolView, not the full-screen tool view.
    UIView *outer = toolView.subviews.firstObject;
    for (UIView *child in toolView.subviews) {
        if ([NSStringFromClass(child.class) isEqualToString:@"InputToolContainerView"]) { outer = child; break; }
    }
    if (outer == inner) outer = nil;
    if (targets.outer != outer) { WCInputSetRounded(targets.outer, NO, NO); targets.outer = outer; }
    // Re-evaluate against current heights, including multi-line input and
    // keyboard transitions. A settings-only cache would miss these changes.
    WCRoundChatInputRoundingApplyToViews(inner, outer, NO);
}

void WCRoundChatInputRoundingSettingsChanged(NSString *key) {
    if (key && ![key hasPrefix:@"com.qiu7c.wcround.interface.chat-input-rounding."]) return;
    for (UIView *tool in WCInputRoundingTools().allObjects) WCRoundChatInputRoundingApply(tool);
}
