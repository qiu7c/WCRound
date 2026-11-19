#pragma once
#import <UIKit/UIKit.h>

// These optional class contracts connect the two independent dylibs.
@protocol WCHomeCornersIntegration <NSObject>
+ (BOOL)enabled;
+ (BOOL)isDark:(UIView *)view;
+ (UIColor *)color:(UIView *)view surface:(BOOL)surface;
+ (CGFloat)inset;
+ (CGFloat)gap;
+ (NSInteger)mergedSection:(UITableView *)table;
+ (void)layoutGroup:(UIView *)banner nativeHeight:(CGFloat)nativeHeight height:(CGFloat)height joined:(BOOL)joined;
+ (void)attach:(UIViewController *)controller;
@end

@protocol WCHomeGroupsIntegration <NSObject>
+ (BOOL)enabled;
+ (void)refreshAppearance;
@end
