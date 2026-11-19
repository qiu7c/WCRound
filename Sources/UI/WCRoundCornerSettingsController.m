#import <math.h>
#import "Sources/API/Internal.h"

@interface WCRoundLocalCornerSettingsController : UITableViewController
@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *sections;
@property (nonatomic, strong) NSMutableIndexSet *collapsed;
@end
static NSDictionary *WCCornerSwitch(NSString *title, NSString *key) { return @{@"title":title,@"key":key,@"switch":@YES}; }
static NSDictionary *WCCornerNumber(NSString *title, NSString *key, double maximum) { return @{@"title":title,@"key":key,@"maximum":@(maximum)}; }
@implementation WCRoundLocalCornerSettingsController
- (instancetype)init { return [super initWithStyle:UITableViewStylePlain]; }
- (void)viewDidLoad {
    [super viewDidLoad]; self.title = @"微信圆角"; WCRoundSettingsConfigureNavigation(self);
    self.tableView.sectionHeaderHeight = 0; self.tableView.sectionFooterHeight = 0;
    self.tableView.tableHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0,0,0,12)];
    self.tableView.tableFooterView=WCRoundSettingsFooter(self.tableView.bounds.size.width);
    self.tableView.backgroundColor = UIColor.systemGroupedBackgroundColor; self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sections = @[
        @[WCCornerSwitch(@"首页圆角",WCRoundHomePageCornerEnabledKey),WCCornerSwitch(@"合并置顶",WCRoundHomePageCornerMergePinnedKey),WCCornerNumber(@"圆角程度",WCRoundHomePageCornerRadiusKey,48),WCCornerNumber(@"左右边距",WCRoundHomePageCornerInsetKey,32),WCCornerNumber(@"卡片间距",WCRoundHomePageCornerGapKey,24)],
        @[WCCornerSwitch(@"全局头像圆角",WCRoundGlobalAvatarRoundingEnabledKey),WCCornerNumber(@"头像圆角程度 (%)",WCRoundGlobalAvatarCornerPercentKey,100),@{@"title":@"头像预览与调节",@"previewKind":@0}],
        @[WCCornerSwitch(@"聊天输入栏圆角",WCRoundChatInputRoundingEnabledKey),@{@"title":@"作用范围",@"selection":@"input-target"},WCCornerNumber(@"内部圆角程度",WCRoundChatInputInnerRadiusKey,40),WCCornerNumber(@"外部圆角程度",WCRoundChatInputOuterRadiusKey,40),@{@"title":@"输入栏预览与调节",@"previewKind":@1}],
        @[WCCornerSwitch(@"朋友圈圆角",WCRoundMomentsImageCornerEnabledKey),WCCornerNumber(@"圆角程度",WCRoundMomentsImageCornerRadiusKey,40),@{@"title":@"朋友圈预览与调节",@"momentsPreview":@YES}],
        @[WCCornerSwitch(@"表情圆角",WCRoundEmoticonCornerEnabledKey),WCCornerNumber(@"圆角程度",WCRoundEmoticonCornerRadiusKey,40)],
        @[WCCornerSwitch(@"聊天媒体圆角",WCRoundChatImageCornerEnabledKey),WCCornerNumber(@"圆角程度",WCRoundChatImageCornerRadiusKey,40)],
        @[@{@"title":@"插件设置",@"pluginSettings":@YES}]
    ];
    self.collapsed = [NSMutableIndexSet indexSet];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(changed:) name:WCRoundDidChangeNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.collapsed=[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0,self.sections.count)];
    [self.tableView reloadData];
}
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; }
- (void)changed:(NSNotification *)note {
    for (UITableViewCell *cell in self.tableView.visibleCells) if (((UISlider *)[cell.contentView viewWithTag:9550]).isTracking) return;
    [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section { return 0; }
- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section { return 0; }
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.sections.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [self.collapsed containsIndex:section] ? 1 : self.sections[section].count; }
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)path { NSDictionary *row=self.sections[path.section][path.row]; return row[@"selection"] ? 88 : (row[@"maximum"] ? 84 : 50); }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)path {
    NSDictionary *row = self.sections[path.section][path.row];
    UITableViewCell *cell = WCRoundSettingsCardCell(tableView,nil,UITableViewCellStyleValue1,path);
    cell.backgroundColor = UIColor.clearColor; cell.textLabel.font = [UIFont systemFontOfSize:16]; cell.textLabel.text = row[@"title"];
    cell.indentationLevel = path.row ? 1 : 0; cell.indentationWidth = 18;
    if (!path.row) {
        cell.imageView.image = [UIImage systemImageNamed:[self.collapsed containsIndex:path.section] ? @"chevron.right" : @"chevron.down"
            withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:11 weight:UIImageSymbolWeightRegular]];
        cell.imageView.tintColor = UIColor.tertiaryLabelColor;
    }
    if (row[@"switch"]) {
        UISwitch *toggle = [UISwitch new]; toggle.onTintColor = UIColor.systemBlueColor; toggle.on = [NSUserDefaults.standardUserDefaults boolForKey:row[@"key"]];
        toggle.accessibilityIdentifier = row[@"key"]; [toggle addTarget:self action:@selector(toggled:) forControlEvents:UIControlEventValueChanged]; cell.accessoryView = toggle;
    } else if (row[@"selection"]) {
        cell.textLabel.text=nil;
        UILabel *label=[UILabel new]; label.text=row[@"title"]; label.font=[UIFont systemFontOfSize:15];
        UISegmentedControl *control=[[UISegmentedControl alloc] initWithItems:@[@"内部",@"外部",@"全部",@"关闭"]];
        NSUserDefaults *defaults=NSUserDefaults.standardUserDefaults;
        BOOL inner=[defaults boolForKey:WCRoundChatInputInnerRoundingKey], outer=[defaults boolForKey:WCRoundChatInputOuterRoundingKey];
        control.selectedSegmentIndex=inner?(outer?2:0):(outer?1:3);
        [control addTarget:self action:@selector(inputTargetChanged:) forControlEvents:UIControlEventValueChanged];
        for (UIView *view in @[label,control]) { view.translatesAutoresizingMaskIntoConstraints=NO; [cell.contentView addSubview:view]; }
        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:34],
            [label.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
            [label.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10],
            [control.leadingAnchor constraintEqualToAnchor:label.leadingAnchor],
            [control.trailingAnchor constraintEqualToAnchor:label.trailingAnchor],
            [control.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:8],
            [control.heightAnchor constraintEqualToConstant:32]
        ]];
    } else if (row[@"maximum"]) {
        cell.textLabel.text = nil;
        UILabel *label = [UILabel new]; label.tag = 9551; label.textColor = UIColor.labelColor; label.font = [UIFont systemFontOfSize:15];
        label.text = [NSString stringWithFormat:@"%@   %.0f",row[@"title"],[NSUserDefaults.standardUserDefaults doubleForKey:row[@"key"]]];
        UISlider *slider = [UISlider new]; slider.tag = 9550; slider.minimumValue = 0; slider.maximumValue = [row[@"maximum"] floatValue]; slider.value = [NSUserDefaults.standardUserDefaults doubleForKey:row[@"key"]]; slider.accessibilityIdentifier = row[@"key"];
        slider.accessibilityLabel = row[@"title"]; [slider addTarget:self action:@selector(slid:) forControlEvents:UIControlEventValueChanged];
        for (UIView *view in @[label,slider]) { view.translatesAutoresizingMaskIntoConstraints = NO; [cell.contentView addSubview:view]; }
        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:34], [label.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-20], [label.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10],
            [slider.leadingAnchor constraintEqualToAnchor:label.leadingAnchor], [slider.trailingAnchor constraintEqualToAnchor:label.trailingAnchor], [slider.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:4], [slider.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8]
        ]];
    } else { cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; }
    return cell;
}
- (void)inputTargetChanged:(UISegmentedControl *)control {
    NSInteger index=control.selectedSegmentIndex;
    NSUserDefaults *defaults=NSUserDefaults.standardUserDefaults;
    [defaults setBool:index==0 || index==2 forKey:WCRoundChatInputInnerRoundingKey];
    [defaults setBool:index==1 || index==2 forKey:WCRoundChatInputOuterRoundingKey];
    WCRoundSettingsPostChange(nil);
}
- (void)toggled:(UISwitch *)toggle { [NSUserDefaults.standardUserDefaults setBool:toggle.on forKey:toggle.accessibilityIdentifier]; WCRoundSettingsPostChange(toggle.accessibilityIdentifier); }
- (void)slid:(UISlider *)slider {
    NSString *key = slider.accessibilityIdentifier; double value = round(slider.value);
    [NSUserDefaults.standardUserDefaults setDouble:value forKey:key];
    UILabel *label = [slider.superview viewWithTag:9551];
    for (NSArray *section in self.sections) for (NSDictionary *row in section) if ([row[@"key"] isEqualToString:key]) label.text = [NSString stringWithFormat:@"%@   %.0f",row[@"title"],value];
    WCRoundSettingsPostChange(key);
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    [tableView deselectRowAtIndexPath:path animated:YES]; NSDictionary *row = self.sections[path.section][path.row];
    if (row[@"pluginSettings"]) {
        [self.navigationController pushViewController:WCRoundCreatePluginSettingsController() animated:YES];
        return;
    }
    if (!path.row) {
        if ([self.collapsed containsIndex:path.section]) [self.collapsed removeIndex:path.section]; else [self.collapsed addIndex:path.section];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationAutomatic]; return;
    }
    if (row[@"momentsPreview"]) { [self.navigationController pushViewController:WCRoundCreateCornerPreview(2) animated:YES]; return; }
    if (row[@"previewKind"]) { [self.navigationController pushViewController:WCRoundCreateCornerPreview([row[@"previewKind"] integerValue]) animated:YES]; return; }
    if (!row[@"maximum"]) return;
    [WCRoundLocalPopup showInputWithTitle:row[@"title"] message:nil text:[NSString stringWithFormat:@"%.0f",[NSUserDefaults.standardUserDefaults doubleForKey:row[@"key"]]] placeholder:[NSString stringWithFormat:@"0 - %@",row[@"maximum"]] keyboard:UIKeyboardTypeDecimalPad completion:^(NSString *text) {
        double value; NSScanner *scanner = [NSScanner scannerWithString:text];
        if (![scanner scanDouble:&value] || !scanner.isAtEnd || !isfinite(value)) return;
        [NSUserDefaults.standardUserDefaults setDouble:MAX(0,MIN([row[@"maximum"] doubleValue],value)) forKey:row[@"key"]]; WCRoundSettingsPostChange(row[@"key"]);
    }];
}
@end
UIViewController *WCRoundCreateCornerSettingsController(void) { return [WCRoundLocalCornerSettingsController new]; }
