//
//  AttributeLabel.m
//  AttributeLabel
//
//  Created by ccSunday on 2017/8/17.
//  Copyright © 2017年 ccSunday. All rights reserved.
//

#import "AttributeLabel.h"

@interface NSString  (AttributeCategory)

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;

@end

@implementation NSString (AttributeCategory)

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

- (CGFloat)widthForFont:(UIFont *)font {
    CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

@end



@interface AttributeLabel ()<UITextViewDelegate>
{
    NSString *_realText;
    BOOL _hasHighText;
    UIFont *_font;
    UIColor *_textColor;
}
@end
static NSString *tempStrBefore = @"{{{{{{{{{{";
static NSString *tempStrAfter =  @"}}}}}}}}}}";

static NSString *tempImgBefore = @"((((((((((";
static NSString *tempImgAfter =  @"))))))))))";

@implementation AttributeLabel

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.editable = NO;
        self.scrollEnabled = NO;
        self.delegate = self;
        self.clearsOnInsertion = YES;
    }
    return self;
}

- (void)setText:(NSString *)text{
    [super setText:text];
    _realText = [text stringByReplacingOccurrencesOfString:@"\\<" withString:tempStrBefore];
    _realText = [_realText stringByReplacingOccurrencesOfString:@"\\>" withString:tempStrAfter];
    _realText = [_realText stringByReplacingOccurrencesOfString:@"\\[" withString:tempImgBefore];
    _realText = [_realText stringByReplacingOccurrencesOfString:@"\\]" withString:tempImgAfter];
    
    _hasHighText = [_realText rangeOfString:@"<"].location != NSNotFound || [_realText rangeOfString:@"["].location != NSNotFound;
    
    if (_hasHighText) {
        [self setAttributedString];
    }
}

- (void)setHighlightColor:(UIColor *)highlightColor{
    _highlightColor = highlightColor;
    if (self.text && _hasHighText) {
        [self setAttributedString];
    }
}

- (void)setHighlightFont:(UIFont *)highlightFont{
    _highlightFont = highlightFont;
    if (self.text && _hasHighText) {
        [self setAttributedString];
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing{
    _lineSpacing = lineSpacing;
    if (self.text && _hasHighText) {
        [self setAttributedString];
    }
}

- (void)setFont:(UIFont *)font{
    [super setFont:font];
    _font = font;
    if (self.text && _hasHighText) {
        [self setAttributedString];
    }
}

- (void)setTextColor:(UIColor *)textColor{
    [super setTextColor:textColor];
    _textColor = textColor;
}

- (void)setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent{
    _firstLineHeadIndent = firstLineHeadIndent;
    if (self.text && _hasHighText) {
        [self setAttributedString];
    }
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing{
    _paragraphSpacing = paragraphSpacing;
    if (self.text && _hasHighText) {
        [self setAttributedString];
    }
}

/**
 设置富文本
 */
- (void)setAttributedString{
    
    NSString *key_font = NSFontAttributeName;
    UIFont *value_font = nil;
    if (_font) {
        value_font = self.highlightFont ? self.highlightFont : _font;
    }else{
        value_font = self.highlightFont ? self.highlightFont : self.font;
    }
    NSString *key_color = NSForegroundColorAttributeName;
    UIColor *value_color = nil;
    if (_textColor) {
        value_color = self.highlightColor ? self.highlightColor : _textColor;
    }else{
        value_color = self.highlightColor ? self.highlightColor : [UIColor blackColor];
    }
    NSArray *rangeArray = [self scanBeginStr:@"<" endStr:@">" inText:_realText];
    
    NSString *text = [_realText stringByReplacingOccurrencesOfString:@"<" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@">" withString:@""];
    //字体
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    if (_font) {
        [attributedText addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    }else{
        [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, text.length)];
    }
    if (_textColor) {
        [attributedText addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, text.length)];
    }else{
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, text.length)];
    }
    //段落格式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSpacing;
    paragraphStyle.firstLineHeadIndent = self.firstLineHeadIndent;
    paragraphStyle.alignment = self.textAlignment ? self.textAlignment : NSTextAlignmentLeft;
    paragraphStyle.paragraphSpacing = self.paragraphSpacing;
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    //高亮文字属性设置
    for (NSDictionary *dict in rangeArray) {
        NSUInteger location = [dict[@"location"] integerValue];
        NSUInteger length = [dict[@"length"] integerValue];
        self.linkTextAttributes = @{key_color:value_color};
        
        [attributedText addAttribute:NSLinkAttributeName
                               value:[NSURL URLWithString:@"click://"]
                               range:NSMakeRange(location, length)];
        
        [attributedText addAttribute:key_font
                               value:value_font
                               range:NSMakeRange(location, length)];
    }
    //处理图片
    attributedText = [self addAttachmentWithAttributedString:attributedText];
    //文字转义处理
    attributedText = [self stringByReplacingOccurrencesOfString:tempStrBefore withString:@"<" inAttributedString:attributedText];
    attributedText = [self stringByReplacingOccurrencesOfString:tempStrAfter withString:@">" inAttributedString:attributedText];
    //图片转义处理
    attributedText = [self stringByReplacingOccurrencesOfString:tempImgBefore withString:@"[" inAttributedString:attributedText];
    attributedText = [self stringByReplacingOccurrencesOfString:tempImgAfter withString:@"]" inAttributedString:attributedText];
    self.attributedText = attributedText;
}

- (NSMutableAttributedString *)addAttachmentWithAttributedString:(NSMutableAttributedString *)attributedText{
    NSRange range1;
    NSRange range2;
    NSUInteger location = 0;
    NSUInteger length = 0;
    range1.location = 0;
    range2.location = 0;
    
    NSString *string = attributedText.string;
    NSString *beginstr = @"[";
    NSString *endstr = @"]";
    while ([string containsString:beginstr] && [string containsString:endstr]) {
        range1 = [string rangeOfString:beginstr];
        range2 = [string rangeOfString:endstr];
        length = range2.location - range1.location + range2.length;
        location = range1.location;
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        NSAttributedString *imgAttrStr = [attributedText attributedSubstringFromRange:NSMakeRange(range1.location + range1.length, length - range1.length - range2.length)];
        UIImage *image = [UIImage imageNamed:imgAttrStr.string];
        attachment.image = image;
        CGFloat height = [[string substringToIndex:1] heightForFont:self.font width:self.frame.size.height];
        attachment.bounds = CGRectMake(0, -fabs(image.size.height - height), image.size.width, image.size.height);
        NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attachment];
        [attributedText replaceCharactersInRange:NSMakeRange(location, length) withAttributedString:attrStr];
        string = attributedText.string;
    }
    
    return attributedText;
}

/**
 *  通过传入的开始标记和结束标记在这个字符串中扫描并将获得的范围装在数组中返回
 *
 *  @param beginstr 开始标记
 *  @param endstr   结束标记
 *  @param text     信息
 *
 *  @return 字典数组装着一个个range
 */
- (NSArray *)scanBeginStr:(NSString *)beginstr endStr:(NSString *)endstr inText:(NSString *)text{
    NSRange range1;
    NSRange range2;
    NSUInteger location = 0;
    NSUInteger length = 0;
    range1.location = 0;
    range2.location = 0;
    
    NSMutableArray *rangeArray = [NSMutableArray array];
    while ([text containsString:beginstr] && [text containsString:endstr]) {
        range1 = [text rangeOfString:beginstr];
        range2 = [text rangeOfString:endstr];
        length = range2.location - range1.location - 1;
        location = range1.location;
        text = [text stringByReplacingOccurrencesOfString:beginstr withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, location + range1.length)];
        text = [text stringByReplacingOccurrencesOfString:endstr withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, range2.location + range2.length - range1.length)];
        NSDictionary *dict = @{@"location":@(location),@"length":@(length)};
        [rangeArray addObject:dict];
    }
    return rangeArray;
}

- (NSMutableAttributedString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement inAttributedString:(NSMutableAttributedString *)attributedString{
    
    NSString *string = attributedString.string;
    while ([string containsString:target]) {
        NSRange range = [string rangeOfString:target];
        [attributedString replaceCharactersInRange:range withString:replacement];
        string = attributedString.string;
    }
    
    return attributedString;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if ([[URL scheme] isEqualToString:@"click"]) {
        NSAttributedString *attStr = [textView.attributedText attributedSubstringFromRange:characterRange];
        if (self.HighlightAction) {
            self.HighlightAction(attStr.string);
        }
        
        return NO;
    }
    
    return YES;
}

@end

