//
//  BJPULessonListView.m
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import "BJPULessonListView.h"
#import "BJPUTheme.h"

@interface BJPULessonListCell : UITableViewCell
@property (strong, nonatomic) UILabel *lessonNameLabel;

@end

@implementation BJPULessonListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.lessonNameLabel];
        [self.lessonNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.offset(10.f);
            make.trailing.offset(-20.f);
            make.bottom.offset(-10.f);
            make.height.mas_greaterThanOrEqualTo(40.f);
        }];
    }
    return self;
}

- (void)resetLessonModel:(PMVideoSectionModel *)lessonModel highlight:(BOOL)hilit
{
    self.lessonNameLabel.text = lessonModel.title;
    if (hilit) { //当前播放的
        self.lessonNameLabel.textColor = [BJPUTheme highlightTextColor];
    } else {
        self.lessonNameLabel.textColor = [BJPUTheme defaultTextColor];
    }
}

- (UILabel *)lessonNameLabel
{
    if (!_lessonNameLabel) {
        _lessonNameLabel = [[UILabel alloc] init];
        _lessonNameLabel.font = [UIFont systemFontOfSize:14.f];
        _lessonNameLabel.numberOfLines = 2;
        _lessonNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _lessonNameLabel;
}

@end

#pragma mark - BJPULessonListView
@interface BJPULessonListView () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray<__kindof PMVideoSectionModel*> *lessonList;
@property (assign, nonatomic) long long currVID;

@end

@implementation BJPULessonListView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.5];
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.offset(0.f);
        }];
    }
    return self;
}

- (void)resetLessonList:(NSArray<__kindof PMVideoSectionModel*> *)lessonList currentVideoID:(long long)currVID
{
    self.lessonList = lessonList;
    self.currVID = currVID;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lessonList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMVideoSectionModel *lessonModel = [self.lessonList objectAtIndex:indexPath.row];
    BJPULessonListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (lessonModel.videoId == _currVID) {
        [cell resetLessonModel:lessonModel highlight:true];
    } else {
        [cell resetLessonModel:lessonModel highlight:false];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    PMVideoSectionModel *lessonModel = [self.lessonList objectAtIndex:indexPath.row];
    //[self.delegate lessonListView:self selectLesson:lessonModel];
    
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

@end
