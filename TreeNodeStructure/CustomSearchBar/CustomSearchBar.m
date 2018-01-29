//
//  CustomSearchBar.m
//  仿QQ添加讨论组
//
//  Created by ccSunday on 2018/1/25.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "CustomSearchBar.h"
#import <objc/runtime.h>
#import "UIView+Category.h"

CGFloat margin = 12;//元素间距与边界间距均为12
CGFloat cellHeight = 44;

@protocol ExtendTextFieldDelegate <UITextFieldDelegate>
@optional
/**点击了删除键 */
- (void)textFieldDidDeleteBackward:(UITextField *)textField;
@end

@interface UITextField (DeleteBackward)
@property (nonatomic, assign) id<ExtendTextFieldDelegate>delegate;
@end

@implementation UITextField (DeleteBackward)
+ (void)load {
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"deleteBackward"));
    Method method2 = class_getInstanceMethod([self class], @selector(exchange_deleteBackward));
    method_exchangeImplementations(method1, method2);
}

- (void)exchange_deleteBackward {
    [self exchange_deleteBackward];
    if ([self.delegate respondsToSelector:@selector(textFieldDidDeleteBackward:)]){
        id <ExtendTextFieldDelegate> delegate  = (id<ExtendTextFieldDelegate>)self.delegate;
        [delegate textFieldDidDeleteBackward:self];
    }
}
@end


@interface NSString (StringSize)
- (CGFloat)widthForFont:(UIFont *)font;
@end

@implementation NSString (StringSize)
- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

@end

@interface CustomSearchBar()<ExtendTextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CustomSearchBarStyle searchBarstyle;

@property (nonatomic, strong) NSMutableArray<id<CustomSearchInputItemProtocol>> *dataArray;

@end

@implementation CustomSearchBar

//static void *DeleteBackwardItemSelectedKey = &DeleteBackwardItemSelectedKey;
static char DeleteBackwardItemSelectedKey;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame searchBarStyle:(CustomSearchBarStyle)style{
    if (self = [super initWithFrame:frame]) {
        self.searchBarstyle = style;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChanged) name:UITextFieldTextDidChangeNotification object:nil];
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {
        self.scrollView.frame = CGRectMake(0, 0, self.width-200, self.height);
        self.textField.frame = CGRectMake(self.scrollView.right, 0, self.width-self.scrollView.width, self.height);
        if (self.dataArray.count>0) {
            UILabel *lastLabel = self.scrollView.subviews.lastObject;
            if (lastLabel.right>self.scrollView.width) {
                [self.scrollView setContentOffset:CGPointMake(lastLabel.right-self.scrollView.width+12, 0) animated:YES];
                self.scrollView.contentSize = CGSizeMake(lastLabel.right+12,0);
            }else{//删除
//                UILabel *firstLabel = self.scrollView.subviews.firstObject;
                NSLog(@"总长度小于scrollview的宽度");
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                self.scrollView.contentSize = CGSizeMake(self.scrollView.width,0);
            }
        }else{
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width,0);
        }
    }else{
        if (self.dataArray.count>0) {
            UILabel *label = [self.subviews lastObject];
            self.textField.frame = CGRectMake(label.right+margin, label.top-(44/2-25/2), self.width - label.right - margin, 44);
            self.height = label.bottom + (44/2-25/2);
        }else{
            self.textField.frame = CGRectMake(0, 0, self.width, self.height);
            self.height = 44;
        }
    }
}

#pragma mark ======= SystemDelegate =======
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    id delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(customSearchBarShouldReturn:)]) {
        return  [delegate customSearchBarShouldReturn:self];
    }else{
        return YES;
    }
}

#pragma mark ======= CustomDelegate =======
- (void)textFieldDidDeleteBackward:(UITextField *)textField{
    if (textField.text.length == 0) {
        if (self.dataArray.count>0) {
            UILabel *lastLabel;
            if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {
                lastLabel = [self.scrollView.subviews lastObject];
            }else{
                 lastLabel = [self.subviews lastObject];
            }
            NSLog(@"lastLabel:%@",lastLabel);

            //get if selected
            BOOL selected = (BOOL)objc_getAssociatedObject(lastLabel, &DeleteBackwardItemSelectedKey);
            if (selected) {
                [lastLabel removeFromSuperview];
                id delegate = self.delegate;
                id<CustomSearchInputItemProtocol>item = [self.dataArray lastObject];
                [self.dataArray removeLastObject];
                [self layoutSubviews];
                if (delegate && [delegate respondsToSelector:@selector(customSearchBar:removeItem:)]) {
                    [delegate customSearchBar:self removeItem:item];
                }
                
            }else{
                //set
                objc_setAssociatedObject(lastLabel, &DeleteBackwardItemSelectedKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                lastLabel.backgroundColor = [UIColor grayColor];
            }
        }
    }
}

#pragma mark ======= Notifications =======

- (void)textFieldTextDidChanged{
    if (self.dataArray.count>0) {
        UILabel *lastLabel;
        if (CustomSearchBarStyleMultipleLines == self.searchBarstyle) {
            lastLabel  = [self.subviews lastObject];
        }else{
            lastLabel  = [self.scrollView.subviews lastObject];
        }
        BOOL selected = (BOOL)objc_getAssociatedObject(lastLabel, &DeleteBackwardItemSelectedKey);
        NSLog(@"lastLabelxxxx:%@",lastLabel);
        if (self.textField.text.length>0) {
            //判断字数是否为0
            if (selected) {
//                objc_removeAssociatedObjects(lastLabel);
                objc_setAssociatedObject(lastLabel, &DeleteBackwardItemSelectedKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                objc_setAssociatedObject(lastLabel, &DeleteBackwardItemSelectedKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                lastLabel.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
            }
        }
    }
    id delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(customSearchBar:textDidChange:)]) {
        [delegate customSearchBar:self textDidChange:self.textField.text];
    }
}

#pragma mark ======= PrivateMethods =======

- (void)setupSubviews{
    [self addSubview:self.textField];
    if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {
        [self addSubview:self.scrollView];
    }
}

#pragma mark  追加单个元素
- (void)addItem:(id<CustomSearchInputItemProtocol>)item{
    [self.dataArray addObject:item];
    [self reloadSearchBar];
}

#pragma mark  从数组中追加多个元素
- (void)addItemFromArray:(NSArray <id<CustomSearchInputItemProtocol>> *)items{
    [self.dataArray addObjectsFromArray:items];
    [self reloadSearchBar];
}

#pragma mark  移除单个元素
- (void)removeItem:(id<CustomSearchInputItemProtocol>)item{
    [self.dataArray removeObject:item];
    [self reloadSearchBar];
}

#pragma mark  从数组中移除多个元素
- (void)removeItemsFromArray:(NSArray <id<CustomSearchInputItemProtocol>> *)items{
    [self.dataArray removeObjectsInArray:items];
    [self reloadSearchBar];
}

#pragma mark 刷新searchBar的布局
- (void)reloadSearchBar{
    self.textField.text = nil;
    if (self.searchBarstyle == CustomSearchBarStyleSingleLine) {//单行
        [self resetSingleLineSearchBar];
    }else{//多行
        [self resetMultipleLinesSearchBar];
    }
}

#pragma mark 刷新单行searchBar的布局
- (void)resetSingleLineSearchBar{
    //codes here:
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];//移除obj
    }];
     __block CGFloat left = 12;
    __block CGFloat top = 44/2-25/2;
    [self.dataArray enumerateObjectsUsingBlock:^(id<CustomSearchInputItemProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelWidth = [obj.inputItemtitle widthForFont:[UIFont systemFontOfSize:14]]+30;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, top, labelWidth, 25)];
        label.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        label.text = obj.inputItemtitle;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.layer.cornerRadius = 25/2;
        label.layer.masksToBounds = YES;
        [self.scrollView addSubview:label];
        left += labelWidth+12;
    }];
    [self setNeedsLayout];
}

#pragma mark 刷新多行searchBar的布局
- (void)resetMultipleLinesSearchBar{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != self.textField) {//不是自定义的textfield
            [obj removeFromSuperview];//移除obj
        }
    }];
    self.height = 44;
   __block CGFloat length = margin;
   __block CGFloat left = margin;
   __block CGFloat top = 44/2-25/2;
    [self.dataArray enumerateObjectsUsingBlock:^(id<CustomSearchInputItemProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelWidth = [obj.inputItemtitle widthForFont:[UIFont systemFontOfSize:14]]+30;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, top, (int)labelWidth, 25)];
        label.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        label.text = obj.inputItemtitle;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.layer.cornerRadius = 25/2;
        label.layer.masksToBounds = YES;
        [self addSubview:label];
        length = length + labelWidth + margin;
        if (length < self.width - 25) {
            left = length;
        }else{
            length = margin;
            left = margin;
            top  += 44;
            label.frame = CGRectMake(left, top, labelWidth, 25);
            length = length + labelWidth + margin;
            left = length;
            self.height += 44;
            //是否需要告知外界自身高度发生改变？
        }
    }];
}

#pragma mark ======= Getters && Setters =======

- (void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder = placeHolder;
    self.textField.placeholder = _placeHolder;
}

-(NSMutableArray<id<CustomSearchInputItemProtocol>> *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITextField *)textField{
    if (!_textField) {
        UITextField *textField = [[UITextField alloc]init];
        textField.placeholder = @"";
        textField.font = [UIFont systemFontOfSize:14];
        textField.returnKeyType = UIReturnKeySearch;
        textField.backgroundColor = [UIColor whiteColor];
        textField.delegate = self;
        textField.textColor = [UIColor blackColor];
        _textField = textField;
    }
    return _textField;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.bounces = YES;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}

#pragma mark ======= Others =======
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
