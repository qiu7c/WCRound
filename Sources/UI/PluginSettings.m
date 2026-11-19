#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "Sources/API/Internal.h"

static BOOL WCRoundImportConfiguration(NSData *data) {
    if (!data) return NO;
    id document = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![document isKindOfClass:NSDictionary.class] || ![document[@"plugin"] isEqual:@"WCRound"]
        || ![document[@"format"] isEqual:@1] || ![document[@"settings"] isKindOfClass:NSDictionary.class]) return NO;
    NSDictionary *settings = document[@"settings"], *defaults = WCRoundDefaultSettings();
    NSDictionary *ranges = @{
        WCRoundHomePageCornerRadiusKey: @[@0, @48],
        WCRoundHomePageCornerInsetKey: @[@0, @32],
        WCRoundHomePageCornerGapKey: @[@0, @24],
        WCRoundEmoticonCornerRadiusKey: @[@0, @40],
        WCRoundChatImageCornerRadiusKey: @[@0, @40],
        WCRoundMomentsImageCornerRadiusKey: @[@0, @40],
        WCRoundGlobalAvatarCornerPercentKey: @[@0, @100],
        WCRoundChatInputInnerRadiusKey: @[@0, @40],
        WCRoundChatInputOuterRadiusKey: @[@0, @40],
        WCRoundPageScalePercentKey: @[@70, @100]
    };
    for (NSString *key in settings) {
        id value = settings[key], expected = defaults[key];
        if (!expected) return NO;
        if ([expected isKindOfClass:NSNumber.class]) {
            if (![value isKindOfClass:NSNumber.class] || !isfinite([value doubleValue])) return NO;
            if (CFGetTypeID((__bridge CFTypeRef)expected) == CFBooleanGetTypeID()
                && CFGetTypeID((__bridge CFTypeRef)value) != CFBooleanGetTypeID()) return NO;
            NSArray *range = ranges[key];
            if (range && ([value doubleValue] < [range[0] doubleValue] || [value doubleValue] > [range[1] doubleValue])) return NO;
        } else if ([expected isKindOfClass:NSString.class]) {
            if (![value isKindOfClass:NSString.class]) return NO;
            if ([key hasSuffix:@"color"] && [value length]) {
                NSString *hex = [value hasPrefix:@"#"] ? [value substringFromIndex:1] : value;
                unsigned long long parsed;
                NSScanner *scanner = [NSScanner scannerWithString:hex];
                if ((hex.length != 6 && hex.length != 8) || ![scanner scanHexLongLong:&parsed] || !scanner.isAtEnd) return NO;
            }
        } else if ([expected isKindOfClass:NSArray.class]) {
            if (![value isKindOfClass:NSArray.class]) return NO;
        } else if ([expected isKindOfClass:NSDictionary.class]) {
            if (![value isKindOfClass:NSDictionary.class]) return NO;
        }
    }

    NSUserDefaults *defaultsStore = NSUserDefaults.standardUserDefaults;
    for (NSString *key in settings) [defaultsStore setObject:settings[key] forKey:key];
    WCRoundSettingsPostChange(nil);
    return YES;
}

@interface WCRoundPluginSettingsController : UITableViewController <UIDocumentPickerDelegate>
@end

@implementation WCRoundPluginSettingsController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"插件设置";
    WCRoundSettingsConfigureNavigation(self);
    self.tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 52 * WCRoundSettingsScaleFactor();
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 12)];
    self.tableView.tableFooterView = WCRoundSettingsFooter(self.tableView.bounds.size.width);
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(settingsChanged:) name:WCRoundDidChangeNotification object:nil];
}
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; }
- (void)settingsChanged:(NSNotification *)notification {
    WCRoundSettingsConfigureNavigation(self);
    self.tableView.rowHeight = 52 * WCRoundSettingsScaleFactor();
    self.tableView.tableFooterView = WCRoundSettingsFooter(self.tableView.bounds.size.width);
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table { return 2; }
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return section == 0 ? 2 : 3; }
- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section { return 0; }
- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section { return 0; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = WCRoundSettingsCardCell(table, nil, UITableViewCellStyleValue1, path);
    cell.textLabel.font = [UIFont systemFontOfSize:16 * WCRoundSettingsScaleFactor()];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13 * WCRoundSettingsScaleFactor()];
    if (path.section == 0) {
        cell.textLabel.text = @[@"导出配置", @"导入配置"][path.row];
        cell.imageView.image = [UIImage systemImageNamed:@[@"square.and.arrow.up", @"square.and.arrow.down"][path.row]];
        cell.imageView.tintColor = UIColor.systemBlueColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @[@"版本", @"联系作者", @"项目地址"][path.row];
        cell.detailTextLabel.text = @[@"1.0.0+1", @"cc", @"GitHub"][path.row];
        cell.accessoryType = path.row ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        if (!path.row) cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (path.section == 1) {
        NSString *url = path.row == 1 ? @"https://qm.qq.com/q/ijROto4Oqc" : @"https://github.com/qiu7c/WCRound";
        if (path.row) [UIApplication.sharedApplication openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
        return;
    }
    if (path.row == 1) {
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeJSON] asCopy:YES];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        return;
    }
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    for (NSString *key in WCRoundDefaultSettings()) settings[key] = [NSUserDefaults.standardUserDefaults objectForKey:key];
    NSDictionary *document = @{@"plugin":@"WCRound", @"format":@1, @"version":@"1.0.0+1", @"settings":settings};
    NSData *data = [NSJSONSerialization dataWithJSONObject:document options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys error:nil];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"WCRound-config.json"]];
    if (!data || ![data writeToURL:url options:NSDataWritingAtomic error:nil]) {
        [WCRoundLocalPopup showMessage:@"导出失败" message:nil];
        return;
    }
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    share.popoverPresentationController.sourceView = table;
    share.popoverPresentationController.sourceRect = [table rectForRowAtIndexPath:path];
    [self presentViewController:share animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)picker didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSData *data = [NSData dataWithContentsOfURL:urls.firstObject];
    BOOL success = WCRoundImportConfiguration(data);
    dispatch_async(dispatch_get_main_queue(), ^{
        [WCRoundLocalPopup showMessage:success ? @"配置已导入" : @"导入失败" message:success ? nil : @"请选择此插件导出的有效配置文件"];
    });
}
@end

UIViewController *WCRoundCreatePluginSettingsController(void) {
    WCRoundPluginSettingsController *controller = [[WCRoundPluginSettingsController alloc] initWithStyle:UITableViewStylePlain];
    controller.hidesBottomBarWhenPushed = YES;
    return controller;
}

UIView *WCRoundSettingsFooter(CGFloat width) {
    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 56 * WCRoundSettingsScaleFactor())];
    footer.text = @"WCRound by cc\n1.0.0+1";
    footer.numberOfLines = 2;
    footer.textAlignment = NSTextAlignmentCenter;
    footer.font = [UIFont systemFontOfSize:12 * WCRoundSettingsScaleFactor()];
    footer.textColor = UIColor.secondaryLabelColor;
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return footer;
}
