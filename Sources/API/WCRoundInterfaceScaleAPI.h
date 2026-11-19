#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

BOOL WCRoundLayoutScaleEnabled(void);
double WCRoundLayoutScaleFactor(void);
/// Paired around theme lookups so nested proxy/manager calls scale only once.
void WCRoundLayoutBeginThemeLookup(void);
id _Nullable WCRoundLayoutEndThemeLookup(id _Nullable value, id _Nullable property, id _Nullable ruleSet);
/// Record the requested WebView zoom before applying the interface override.
double WCRoundLayoutWebViewZoom(id webView, double requestedFactor);
void WCRoundLayoutApplyWebView(id webView);
void WCRoundLayoutSettingsChanged(NSString * _Nullable key);

UIViewController *WCRoundCreateInterfaceScaleSettingsController(void);

NS_ASSUME_NONNULL_END
