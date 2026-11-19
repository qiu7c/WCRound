#import "Sources/API/Internal.h"

@interface WCRoundInterfaceScaleSettingsController : UITableViewController
@end

@implementation WCRoundInterfaceScaleSettingsController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"界面大小";
    WCRoundSettingsConfigureNavigation(self);
    self.tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 12)];
    self.tableView.tableFooterView = WCRoundSettingsFooter(self.tableView.bounds.size.width);
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(settingsChanged:) name:WCRoundDidChangeNotification object:nil];
}
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; }
- (void)settingsChanged:(NSNotification *)notification {
    WCRoundSettingsConfigureNavigation(self);
    self.tableView.tableFooterView = WCRoundSettingsFooter(self.tableView.bounds.size.width);
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return 3; }
- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section { return 0; }
- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section { return 0; }
- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)path {
    CGFloat scale = WCRoundSettingsScaleFactor();
    return path.row == 1 ? MAX(104, 116 * scale) : 50 * scale;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = WCRoundSettingsCardCell(table, nil, UITableViewCellStyleDefault, path);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGFloat scale = WCRoundSettingsScaleFactor();
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if (path.row != 1) {
        NSString *key = path.row == 0 ? WCRoundPageScaleEnabledKey : WCRoundPageScalePluginUIKey;
        cell.textLabel.text = path.row == 0 ? @"调整界面大小" : @"包含本插件界面";
        cell.textLabel.font = [UIFont systemFontOfSize:16 * scale];
        UISwitch *toggle = [UISwitch new];
        toggle.onTintColor = UIColor.systemBlueColor;
        toggle.on = [defaults boolForKey:key];
        toggle.accessibilityIdentifier = key;
        [toggle addTarget:self action:@selector(toggled:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
        return cell;
    }
    double percent = [defaults doubleForKey:WCRoundPageScalePercentKey];
    UILabel *label = [UILabel new];
    label.tag = 9661;
    label.text = [NSString stringWithFormat:@"界面比例   %.0f%%", percent];
    label.font = [UIFont systemFontOfSize:15 * scale];
    UISlider *slider = [UISlider new];
    slider.tag = 9660;
    slider.minimumValue = 70;
    slider.maximumValue = 100;
    slider.value = percent;
    slider.accessibilityLabel = @"界面比例";
    [slider addTarget:self action:@selector(slid:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(finishedSliding:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    UISegmentedControl *presets = [[UISegmentedControl alloc] initWithItems:@[@"80%", @"85%", @"90%", @"100%"]];
    presets.tag = 9662;
    NSUInteger index = [@[@80, @85, @90, @100] indexOfObject:@(percent)];
    presets.selectedSegmentIndex = index == NSNotFound ? UISegmentedControlNoSegment : (NSInteger)index;
    [presets addTarget:self action:@selector(presetChanged:) forControlEvents:UIControlEventValueChanged];
    for (UIView *view in @[label, slider, presets]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:view];
    }
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [label.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [label.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10 * scale],
        [slider.leadingAnchor constraintEqualToAnchor:label.leadingAnchor],
        [slider.trailingAnchor constraintEqualToAnchor:label.trailingAnchor],
        [slider.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:4 * scale],
        [slider.heightAnchor constraintEqualToConstant:28],
        [presets.leadingAnchor constraintEqualToAnchor:label.leadingAnchor],
        [presets.trailingAnchor constraintEqualToAnchor:label.trailingAnchor],
        [presets.topAnchor constraintEqualToAnchor:slider.bottomAnchor constant:6 * scale],
        [presets.heightAnchor constraintEqualToConstant:32],
        [presets.bottomAnchor constraintLessThanOrEqualToAnchor:cell.contentView.bottomAnchor constant:-8 * scale]
    ]];
    return cell;
}
- (void)toggled:(UISwitch *)toggle {
    [NSUserDefaults.standardUserDefaults setBool:toggle.on forKey:toggle.accessibilityIdentifier];
    WCRoundSettingsPostChange(toggle.accessibilityIdentifier);
}
- (void)slid:(UISlider *)slider {
    double percent = round(slider.value);
    UILabel *label = [slider.superview viewWithTag:9661];
    label.text = [NSString stringWithFormat:@"界面比例   %.0f%%", percent];
    UISegmentedControl *presets = [slider.superview viewWithTag:9662];
    NSUInteger index = [@[@80, @85, @90, @100] indexOfObject:@(percent)];
    presets.selectedSegmentIndex = index == NSNotFound ? UISegmentedControlNoSegment : (NSInteger)index;
}
- (void)finishedSliding:(UISlider *)slider {
    [NSUserDefaults.standardUserDefaults setDouble:round(slider.value) forKey:WCRoundPageScalePercentKey];
    WCRoundSettingsPostChange(WCRoundPageScalePercentKey);
}
- (void)presetChanged:(UISegmentedControl *)control {
    double percent = [@[@80, @85, @90, @100][control.selectedSegmentIndex] doubleValue];
    [NSUserDefaults.standardUserDefaults setDouble:percent forKey:WCRoundPageScalePercentKey];
    WCRoundSettingsPostChange(WCRoundPageScalePercentKey);
}
@end

UIViewController *WCRoundCreateInterfaceScaleSettingsController(void) {
    WCRoundInterfaceScaleSettingsController *controller = [[WCRoundInterfaceScaleSettingsController alloc] initWithStyle:UITableViewStylePlain];
    controller.hidesBottomBarWhenPushed = YES;
    return controller;
}
