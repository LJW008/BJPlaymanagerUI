//
//  BJPULessonListView.h
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import <UIKit/UIKit.h>

@class BJPULessonListView;
@protocol BJPULessonListViewProtocol <NSObject>
@required

/**
 清晰度选中事件
 */
- (void)lessonListView:(BJPULessonListView *)lessonListView selectLesson:(PMVideoSectionModel *)lessonModel;

@end

@interface BJPULessonListView : UIView

@property (weak, nonatomic) id<BJPULessonListViewProtocol> delegate;

- (void)resetLessonList:(NSArray<__kindof PMVideoSectionModel*> *)lessonList currentVideoID:(long long)currVID;

@end
