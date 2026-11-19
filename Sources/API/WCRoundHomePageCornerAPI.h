#import <UIKit/UIKit.h>

BOOL WCRoundHomePageCornerEnabled(void);
BOOL WCRoundHomePageIsDark(UIView *view);
UIColor *WCRoundHomePageCornerColor(UIView *view, BOOL surface);
CGFloat WCRoundHomePageCornerInset(void);
CGFloat WCRoundHomePageCornerGap(void);
void WCRoundHomePageCornerAttach(UIViewController *controller);
void WCRoundHomePageCornerLayoutTable(UITableView *table);
void WCRoundHomePageCornerLayoutCell(UITableViewCell *cell);
CGRect WCRoundHomePageCornerCellFrame(UITableViewCell *cell, CGRect frame);
void WCRoundHomePageCornerLayoutSwipe(UIView *container);
void WCRoundHomePageCornerRestoreCell(UITableViewCell *cell);
void WCRoundHomePageCornerLayoutChrome(UIView *view);
void WCRoundHomePageCornerLayoutSearch(UIView *view);
NSInteger WCRoundHomePageCornerMergedSection(UITableView *table);
void WCRoundHomePageCornerLayoutGroup(UIView *banner, CGFloat nativeHeight, CGFloat height, BOOL joined);
CGFloat WCRoundHomePageCornerHeaderHeight(UITableView *table, NSInteger section, CGFloat original);
UIView *WCRoundHomePageCornerHeaderView(UITableView *table, NSInteger section, UIView *original);
CGFloat WCRoundHomePageCornerFooterHeight(UITableView *table, NSInteger section, CGFloat original);
UIView *WCRoundHomePageCornerFooterView(UITableView *table, NSInteger section, UIView *original);
void WCRoundHomePageCornerSettingsChanged(NSString *key);
void WCRoundHomePageCornerThemeChanged(void);
