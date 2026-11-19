#import "Sources/API/Internal.h"

// Reuses the landscape rendering from the original Moments preview.
static UIImage *WCRoundPreviewLandscape(NSUInteger index) {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(240, 180)];
    return [renderer imageWithActions:^(__unused UIGraphicsImageRendererContext *context) {
        NSArray *skies = @[[UIColor colorWithRed:.66 green:.84 blue:.94 alpha:1],
            [UIColor colorWithRed:.96 green:.80 blue:.65 alpha:1], [UIColor colorWithRed:.75 green:.85 blue:.76 alpha:1]];
        [skies[index % skies.count] setFill]; UIRectFill(CGRectMake(0, 0, 240, 180));
        [[UIColor colorWithWhite:1 alpha:.8] setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(158, 28, 32, 32)] fill];
        [[UIColor colorWithRed:.33 green:.59 blue:.54 alpha:1] setFill];
        UIBezierPath *mountain = [UIBezierPath bezierPath];
        [mountain moveToPoint:CGPointMake(0, 134)]; [mountain addLineToPoint:CGPointMake(82, 66 + index % 3 * 12)];
        [mountain addLineToPoint:CGPointMake(170, 138)]; [mountain addLineToPoint:CGPointMake(240, 85)];
        [mountain addLineToPoint:CGPointMake(240, 180)]; [mountain addLineToPoint:CGPointMake(0, 180)];
        [mountain closePath]; [mountain fill];
        [[UIColor colorWithRed:.23 green:.52 blue:.66 alpha:1] setFill]; UIRectFill(CGRectMake(0, 143, 240, 37));
    }];
}

@interface WCRoundPreviewView : UIView
@property (nonatomic) NSInteger kind;
@property (nonatomic, strong) NSArray<UIView *> *avatars;
@property (nonatomic, strong) NSArray<UILabel *> *messages;
@property (nonatomic, strong) NSArray<UIImageView *> *photos;
@property (nonatomic, strong) UIView *outerInput;
@property (nonatomic, strong) UILabel *innerInput;
@end

@implementation WCRoundPreviewView
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    self.backgroundColor = UIColor.systemGroupedBackgroundColor;
    NSMutableArray *avatars = [NSMutableArray array], *messages = [NSMutableArray array], *photos = [NSMutableArray array];
    for (NSUInteger index = 0; index < 2; index++) {
        UIView *avatar = WCRoundContactAvatarView(WCRoundCurrentUserWXID());
        avatar.userInteractionEnabled = NO;
        [self addSubview:avatar]; [avatars addObject:avatar];
        UILabel *message = [UILabel new];
        message.font = [UIFont systemFontOfSize:16];
        message.text = index ? @"调整后马上可以看到效果" : @"这是圆角预览";
        message.textAlignment = NSTextAlignmentCenter;
        message.textColor = index ? UIColor.blackColor : UIColor.labelColor;
        message.backgroundColor = index ? [UIColor colorWithRed:.58 green:.91 blue:.43 alpha:1] : UIColor.secondarySystemGroupedBackgroundColor;
        message.layer.cornerRadius = 5; message.clipsToBounds = YES;
        [self addSubview:message]; [messages addObject:message];
    }
    for (NSUInteger index = 0; index < 6; index++) {
        UIImageView *photo = [[UIImageView alloc] initWithImage:WCRoundPreviewLandscape(index)];
        photo.contentMode = UIViewContentModeScaleAspectFill;
        photo.clipsToBounds = YES;
        [self addSubview:photo]; [photos addObject:photo];
    }
    self.avatars = avatars; self.messages = messages; self.photos = photos;
    self.outerInput = [UIView new]; self.outerInput.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    [self addSubview:self.outerInput];
    self.innerInput = [UILabel new]; self.innerInput.text = @"  输入消息";
    self.innerInput.font = [UIFont systemFontOfSize:16]; self.innerInput.textColor = UIColor.secondaryLabelColor;
    self.innerInput.backgroundColor = UIColor.tertiarySystemGroupedBackgroundColor;
    [self.outerInput addSubview:self.innerInput];
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, scale = WCRoundLayoutScaleFactor();
    for (NSUInteger index = 0; index < self.avatars.count; index++) {
        BOOL sender = index == 1;
        UIView *avatar = self.avatars[index];
        avatar.hidden = self.kind == 2 && sender;
        CGFloat avatarSide = 42 * scale;
        avatar.frame = CGRectMake(sender ? width - 16 - avatarSide : 16, (sender ? 100 : 24) * scale, avatarSide, avatarSide);
        [avatar layoutIfNeeded];
        if (self.kind == 0) {
            UIView *image = WCRoundTweakSafeValue(avatar, @"headImageView");
            if (![image isKindOfClass:UIView.class]) image = avatar;
            image.layer.cornerRadius = MIN(image.bounds.size.width, image.bounds.size.height) * .5
                * [NSUserDefaults.standardUserDefaults doubleForKey:WCRoundGlobalAvatarCornerPercentKey] / 100;
            image.layer.cornerCurve = kCACornerCurveContinuous;
            image.clipsToBounds = YES;
        }
        UILabel *message = self.messages[index];
        message.hidden = self.kind == 2 && sender;
        message.font = [UIFont systemFontOfSize:16 * scale];
        CGFloat contentX = 16 + avatarSide + 14 * scale;
        CGFloat available = MAX(0, width - contentX - 16);
        CGFloat messageWidth = MIN((sender ? 232 : 162) * scale, available);
        message.frame = CGRectMake(sender ? width - contentX - messageWidth : contentX, (sender ? 102 : 26) * scale, messageWidth, 38 * scale);
        if (self.kind == 2) message.text = @"今天的风景";
    }
    CGFloat photoX = 16 + 56 * scale;
    CGFloat side = MAX(0, MIN(88 * scale, (width - photoX - 24) / 3));
    for (NSUInteger index = 0; index < self.photos.count; index++) {
        UIImageView *photo = self.photos[index];
        photo.hidden = self.kind != 2;
        photo.frame = CGRectMake(photoX + (index % 3) * (side + 4), 82 * scale + (index / 3) * (side + 4), side, side);
        photo.layer.cornerRadius = WCRoundMomentsImageCornerResolvedRadius(photo.bounds.size,
            [NSUserDefaults.standardUserDefaults doubleForKey:WCRoundMomentsImageCornerRadiusKey]);
        photo.layer.cornerCurve = kCACornerCurveContinuous;
    }
    self.outerInput.hidden = self.kind != 1;
    self.innerInput.font = [UIFont systemFontOfSize:16 * scale];
    self.outerInput.frame = CGRectMake(16, self.bounds.size.height - 88 * scale, MAX(0, width - 32), 64 * scale);
    self.innerInput.frame = CGRectMake(12 * scale, 10 * scale, MAX(0, self.outerInput.bounds.size.width - 24 * scale), 44 * scale);
    WCRoundChatInputRoundingApplyToViews(self.innerInput, self.outerInput, YES);
}
@end

@interface WCRoundPreviewController : UITableViewController
@property (nonatomic) NSInteger kind;
@property (nonatomic, strong) WCRoundPreviewView *preview;
@property (nonatomic, copy) NSArray<NSDictionary *> *rows;
@end

@implementation WCRoundPreviewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @[@"头像圆角", @"输入栏圆角", @"朋友圈圆角"][self.kind];
    WCRoundSettingsConfigureNavigation(self);
    self.tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = MAX(70, 90 * WCRoundSettingsScaleFactor());
    self.rows = @[
        @[@{@"title":@"头像圆角程度 (%)", @"key":WCRoundGlobalAvatarCornerPercentKey, @"max":@100}],
        @[@{@"title":@"输入框圆角", @"key":WCRoundChatInputInnerRadiusKey, @"max":@40},
          @{@"title":@"外工具栏圆角", @"key":WCRoundChatInputOuterRadiusKey, @"max":@40}],
        @[@{@"title":@"圆角程度", @"key":WCRoundMomentsImageCornerRadiusKey, @"max":@40}]
    ][self.kind];
    self.preview = [[WCRoundPreviewView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    self.preview.kind = self.kind;
    self.tableView.tableHeaderView = self.preview;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(changed:) name:WCRoundDidChangeNotification object:nil];
}
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; }
- (void)changed:(NSNotification *)notification {
    WCRoundSettingsConfigureNavigation(self);
    [self.preview setNeedsLayout];
    for (UITableViewCell *cell in self.tableView.visibleCells) if (((UISlider *)[cell.contentView viewWithTag:9550]).isTracking) return;
    self.tableView.rowHeight = MAX(70, 90 * WCRoundSettingsScaleFactor());
    [self.tableView reloadData];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = self.kind == 2 ? MIN(332, self.view.bounds.size.width * .8) : 284;
    if (self.preview.bounds.size.width != self.tableView.bounds.size.width || self.preview.bounds.size.height != height) {
        self.preview.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, height);
        self.tableView.tableHeaderView = self.preview;
    }
}
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return self.rows.count; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    NSDictionary *row = self.rows[path.row];
    UITableViewCell *cell = WCRoundSettingsCardCell(table, nil, UITableViewCellStyleDefault, path);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *label = [UILabel new]; label.tag = 77; label.font = [UIFont systemFontOfSize:15 * WCRoundSettingsScaleFactor()];
    double value = [NSUserDefaults.standardUserDefaults doubleForKey:row[@"key"]];
    label.text = [NSString stringWithFormat:@"%@   %.0f", row[@"title"], value];
    UISlider *slider = [UISlider new]; slider.tag = 9550; slider.minimumValue = 0; slider.maximumValue = [row[@"max"] floatValue];
    slider.value = value; slider.accessibilityIdentifier = row[@"key"]; slider.accessibilityLabel = row[@"title"];
    [slider addTarget:self action:@selector(slid:) forControlEvents:UIControlEventValueChanged];
    for (UIView *view in @[label, slider]) { view.translatesAutoresizingMaskIntoConstraints = NO; [cell.contentView addSubview:view]; }
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [label.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [label.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:12 * WCRoundSettingsScaleFactor()],
        [slider.leadingAnchor constraintEqualToAnchor:label.leadingAnchor],
        [slider.trailingAnchor constraintEqualToAnchor:label.trailingAnchor],
        [slider.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:4 * WCRoundSettingsScaleFactor()],
        [slider.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-10 * WCRoundSettingsScaleFactor()]
    ]];
    return cell;
}
- (void)slid:(UISlider *)slider {
    double value = round(slider.value);
    [NSUserDefaults.standardUserDefaults setDouble:value forKey:slider.accessibilityIdentifier];
    UILabel *label = [slider.superview viewWithTag:77];
    label.text = [NSString stringWithFormat:@"%@   %.0f", slider.accessibilityLabel, value];
    WCRoundSettingsPostChange(slider.accessibilityIdentifier);
}
@end

UIViewController *WCRoundCreateCornerPreview(NSInteger kind) {
    WCRoundPreviewController *controller = [[WCRoundPreviewController alloc] initWithStyle:UITableViewStylePlain];
    controller.kind = kind; controller.hidesBottomBarWhenPushed = YES;
    return controller;
}
