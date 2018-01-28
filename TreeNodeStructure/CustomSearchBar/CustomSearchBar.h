//
//  CustomSearchBar.h
//  仿QQ添加讨论组
//
//  Created by ccSunday on 2018/1/25.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchInputItemProtocol.h"

typedef NS_ENUM(NSUInteger,CustomSearchBarStyle)
{
    CustomSearchBarStyleSingleLine,     //单行展示，scrollview形式
    CustomSearchBarStyleMultipleLines   //多行展示，多的换行展示
};

@class CustomSearchBar;

@protocol CustomSearchBarDelegate
/**
 called when 'return' key pressed. return NO to ignore.
 */
- (BOOL)customSearchBarShouldReturn:(CustomSearchBar *)searchBar;
/**
 文本改变时就会调用这个方法

 @param searchBar searchBar 实例
 @param text 输入框中的文字
 */
- (void)customSearchBar:(CustomSearchBar *)searchBar textDidChange:(NSString *)text;
/**
 减少元素,告知外界

 @param searchBar searchBar实例
 @param item item 遵循输入item协议的模型
 */
- (void)customSearchBar:(CustomSearchBar *)searchBar removeItem:(id<CustomSearchInputItemProtocol>)item ;

@end
/**
 数据源代理，用来自定义视图，自定义间距，
 */
@protocol CustomSearchBarDataSource
/**
 返回第index下所对应的view视图

 @param searchBar searchBar 实例
 @param index 下标
 @return 第index下的view视图
 */
- (UIView *)customSearchBar:(CustomSearchBar *)searchBar viewForItemAtIndex:(NSInteger)index;

@end

@interface CustomSearchBar : UIView

@property (nonatomic, copy) NSString *placeHolder;

@property (nonatomic, assign) id<CustomSearchBarDelegate>delegate;

@property (nonatomic, assign) id<CustomSearchBarDataSource>dataSource;//未实现
/**
 初始化方法

 @param frame frame
 @param style style
 @return searchBar实例
 */
- (instancetype)initWithFrame:(CGRect)frame searchBarStyle:(CustomSearchBarStyle)style;

/**
 追加单个元素

 @param item item实例
 */
- (void)addItem:(id<CustomSearchInputItemProtocol>)item;

/**
 从数组中追加多个元素

 @param items item数组
 */
- (void)addItemFromArray:(NSArray <id<CustomSearchInputItemProtocol>> *)items;

/**
 移除单个元素

 @param item item实例
 */
- (void)removeItem:(id<CustomSearchInputItemProtocol>)item;

/**
 从数组中移除多个元素

 @param items item数组
 */
- (void)removeItemsFromArray:(NSArray <id<CustomSearchInputItemProtocol>> *)items;
@end
