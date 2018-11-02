//
//  BJPUDefinitionView.m
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import "BJPUDefinitionView.h"
#import "BJPUTheme.h"
#import "BJPUMacro.h"

/**
 清晰度列表Cell
 */
#pragma mark - BJPUDefinitionCell
@interface BJPUDefinitionCell : UITableViewCell
@property (strong, nonatomic) UILabel *definitionLabel;
@end

@implementation BJPUDefinitionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.definitionLabel];
    }
    return self;
}

- (void)resetDefinitionModel:(PMVideoDefinitionInfoModel *)definitionModel highlit:(BOOL)highlit
{
    self.definitionLabel.text = definitionModel.definition;
    if (highlit) {
        [_definitionLabel setTextColor:[BJPUTheme highlightTextColor]];
        _definitionLabel.layer.borderColor = [BJPUTheme highlightTextColor].CGColor;
    } else {
        [_definitionLabel setTextColor:[BJPUTheme defaultTextColor]];
        _definitionLabel.layer.borderColor = [BJPUTheme defaultTextColor].CGColor;
    }
}

- (UILabel *)definitionLabel
{
    if (!_definitionLabel) {
        _definitionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 50, 20)];
        _definitionLabel.backgroundColor = [UIColor clearColor];
        [_definitionLabel setFont:[UIFont systemFontOfSize:14.f]];
        _definitionLabel.textAlignment = NSTextAlignmentCenter;
        _definitionLabel.layer.cornerRadius = 10.f;
        _definitionLabel.layer.borderWidth = BJPUOnePixel;
        _definitionLabel.tag = 1000;
    }

    return _definitionLabel;
}
@end

#pragma mark - BJPUDefinitionView
@interface BJPUDefinitionView () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray<PMVideoDefinitionInfoModel*> *definitionList;
@property (strong, nonatomic) PMVideoDefinitionInfoModel *currentDefinition;

@end

@implementation BJPUDefinitionView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.5];
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark - public
- (void)resetDefinitionList:(NSArray<__kindof PMVideoDefinitionInfoModel*> *)definitionList
          currentDefinition:(PMVideoDefinitionInfoModel *)currentDefinition
{
    self.definitionList = definitionList;
    self.currentDefinition = currentDefinition;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(definitionList.count * 40.f);
    }];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.definitionList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMVideoDefinitionInfoModel *definitionModel = [self.definitionList objectAtIndex:indexPath.row];
    BJPUDefinitionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (definitionModel.definitionType == _currentDefinition.definitionType) {
        [cell resetDefinitionModel:definitionModel highlit:true];
    } else {
        [cell resetDefinitionModel:definitionModel highlit:false];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMVideoDefinitionInfoModel *definitionModel = [self.definitionList objectAtIndex:indexPath.row];
    [self.delegate definitionView:self selectDefinition:definitionModel];
    [self resetDefinitionList:self.definitionList currentDefinition:definitionModel];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        __strong typeof(weakSelf) self = weakSelf;
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) self = weakSelf;
        self.hidden = true;
        self.alpha = 1.f;
    }];
}

#pragma mark - set get
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = false;
        _tableView.estimatedRowHeight = 40.0;
        [_tableView registerClass:[BJPUDefinitionCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end

