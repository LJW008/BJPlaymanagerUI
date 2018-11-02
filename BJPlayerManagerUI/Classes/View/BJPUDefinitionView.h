//
//  BJPUDefinitionView.h
//  Pods
//
//  Created by DLM on 2017/4/27.
//
//

#import <UIKit/UIKit.h>

@class BJPUDefinitionView;
@protocol BJPUDefinitionViewProtocol <NSObject>
@required

/**
 清晰度选中事件
 */
- (void)definitionView:(BJPUDefinitionView *)definitionView selectDefinition:(PMVideoDefinitionInfoModel *)definition;

@end

@interface BJPUDefinitionView : UIView

@property (weak, nonatomic) id<BJPUDefinitionViewProtocol> delegate;

- (void)resetDefinitionList:(NSArray<__kindof PMVideoDefinitionInfoModel*> *)definitionList
          currentDefinition:(PMVideoDefinitionInfoModel *)currentDefinition;

@end
