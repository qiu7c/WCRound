#import <objc/message.h>
#import "Sources/API/Internal.h"

static BOOL WCRoundEntryRegistered;
static char WCRoundEntryCellKey;

UIViewController *WCRoundCreateSettingsController(void) {
    UIViewController *controller = WCRoundCreateCornerSettingsController();
    controller.hidesBottomBarWhenPushed = YES;
    return controller;
}

void WCRoundRegisterEntry(void) {
    if (WCRoundEntryRegistered) return;
    Class managerClass = NSClassFromString(@"WCPluginsMgr");
    SEL shared = NSSelectorFromString(@"sharedInstance");
    if (![managerClass respondsToSelector:shared]) return;
    id manager = ((id (*)(id, SEL))objc_msgSend)(managerClass, shared);
    SEL registerSelector = NSSelectorFromString(@"registerControllerWithTitle:version:controller:");
    if (![manager respondsToSelector:registerSelector]) return;
    ((void (*)(id, SEL, id, id, id))objc_msgSend)(manager, registerSelector, @"微信圆角", @"1.0.0", @"WCRoundLocalCornerSettingsController");
    WCRoundEntryRegistered = YES;
}

void WCRoundRefreshEntry(UIViewController *controller) {
    WCRoundRegisterEntry();
    id manager = WCRoundTweakSafeValue(controller, @"m_tableViewMgr");
    NSArray *sections = WCRoundTweakSafeValue(manager, @"getAllSections");
    if (![sections isKindOfClass:NSArray.class] || !sections.count) return;
    id ownSection = nil;
    NSUInteger ownIndex = NSNotFound;
    for (id section in sections) {
        NSArray *cells = WCRoundTweakSafeValue(section, @"getAllCells");
        if (![cells isKindOfClass:NSArray.class]) continue;
        for (NSUInteger index = 0; index < cells.count; index++) {
            if (!objc_getAssociatedObject(cells[index], &WCRoundEntryCellKey)) continue;
            ownSection = section; ownIndex = index;
            break;
        }
        if (ownSection) break;
    }
    if (WCRoundEntryRegistered && ownSection) {
        ((void (*)(id, SEL, unsigned long long))objc_msgSend)(ownSection, NSSelectorFromString(@"removeCellAt:"), ownIndex);
    } else if (!WCRoundEntryRegistered && !ownSection) {
        Class factoryClass = NSClassFromString(@"WCTableViewCellManager");
        SEL factory = NSSelectorFromString(@"normalCellForSel:target:leftImage:title:WithDisclosureIndicator:");
        if (![factoryClass respondsToSelector:factory]) return;
        UIImage *icon = [[UIImage systemImageNamed:@"square.on.circle"] imageWithTintColor:UIColor.systemBlueColor renderingMode:UIImageRenderingModeAlwaysOriginal];
        id cell = ((id (*)(id, SEL, SEL, id, id, id, BOOL))objc_msgSend)(factoryClass, factory, NSSelectorFromString(@"wcr_openSettings"), controller, icon, @"微信圆角", YES);
        if (!cell) return;
        objc_setAssociatedObject(cell, &WCRoundEntryCellKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        ((void (*)(id, SEL, id))objc_msgSend)(sections[MIN(2, sections.count - 1)], NSSelectorFromString(@"addCell:"), cell);
    } else return;
    ((void (*)(id, SEL))objc_msgSend)(manager, NSSelectorFromString(@"reloadTableView"));
}
