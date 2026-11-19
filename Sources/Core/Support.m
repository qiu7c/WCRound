#import <objc/message.h>
#import "Sources/API/Internal.h"

id WCRoundTweakSafeValue(id object, NSString *key) {
    if (!object) return nil;
    @try { return [object valueForKey:key]; }
    @catch (__unused NSException *exception) { return nil; }
}

id WCRoundServiceForClass(Class cls) {
    Class contextClass = NSClassFromString(@"MMContext");
    SEL current = NSSelectorFromString(@"currentContext");
    if (![contextClass respondsToSelector:current]) return nil;
    id context = ((id (*)(id, SEL))objc_msgSend)(contextClass, current);
    SEL service = NSSelectorFromString(@"getService:");
    if ([context respondsToSelector:service]) return ((id (*)(id, SEL, Class))objc_msgSend)(context, service, cls);
    id center = WCRoundTweakSafeValue(context, @"serviceCenter");
    return [center respondsToSelector:service] ? ((id (*)(id, SEL, Class))objc_msgSend)(center, service, cls) : nil;
}

id WCRoundPrivateContact(NSString *user) {
    id manager = WCRoundServiceForClass(NSClassFromString(@"CContactMgr"));
    SEL selector = NSSelectorFromString(@"getContactByName:");
    return user.length && [manager respondsToSelector:selector] ? ((id (*)(id, SEL, id))objc_msgSend)(manager, selector, user) : nil;
}

NSString *WCRoundCurrentUserWXID(void) {
    Class contextClass = NSClassFromString(@"MMContext");
    SEL selector = NSSelectorFromString(@"currentUserName");
    id value = [contextClass respondsToSelector:selector] ? ((id (*)(id, SEL))objc_msgSend)(contextClass, selector) : nil;
    return [value isKindOfClass:NSString.class] ? value : @"";
}


static NSString *WCContactsName(id contact, NSArray<NSString *> *keys) {
    for (NSString *key in keys) {
        id value = WCRoundTweakSafeValue(contact, key);
        if (![value isKindOfClass:NSString.class]) continue;
        NSString *name = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (name.length) return name;
    }
    return nil;
}

static UIView *WCContactAvatarView(NSString *username, BOOL rounded) {
    id contact = WCRoundPrivateContact(username);
    NSString *url = WCContactsName(contact, @[@"m_nsHeadHDImgUrl", @"m_nsHeadImgUrlHD", @"m_nsHeadImgUrl"]) ?: @"";
    Class helper = NSClassFromString(@"MMHeadImageHelper");
    for (NSString *name in @[@"getContactHeadImageViewWithUsrName:headImgUrl:bAutoUpdate:bRoundCorner:",
                            @"getMainFrameHeadImageViewWithUsrName:headImgUrl:bAutoUpdate:bRoundCorner:"]) {
        SEL selector = NSSelectorFromString(name);
        NSMethodSignature *signature = [helper methodSignatureForSelector:selector];
        if (![helper respondsToSelector:selector] || signature.numberOfArguments != 6
            || signature.methodReturnType[0] != '@' || [signature getArgumentTypeAtIndex:2][0] != '@'
            || [signature getArgumentTypeAtIndex:3][0] != '@'
            || !strchr("BcCsSiIlLqQ", [signature getArgumentTypeAtIndex:4][0])
            || !strchr("BcCsSiIlLqQ", [signature getArgumentTypeAtIndex:5][0])) continue;
        @try {
            id view = ((id (*)(id, SEL, id, id, BOOL, BOOL))objc_msgSend)(helper, selector, username, url, YES, rounded);
            if ([view isKindOfClass:UIView.class]) return view;
        } @catch (__unused NSException *exception) {}
    }
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.tertiarySystemGroupedBackgroundColor;
    return view;
}

UIView *WCRoundContactAvatarView(NSString *username) { return WCContactAvatarView(username, YES); }
