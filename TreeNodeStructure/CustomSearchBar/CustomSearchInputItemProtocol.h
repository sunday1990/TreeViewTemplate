//
//  CustomSearchInputItemProtocol.h
//  仿QQ添加讨论组
//
//  Created by ccSunday on 2018/1/25.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#ifndef CustomSearchInputItemProtocol_h
#define CustomSearchInputItemProtocol_h
@protocol CustomSearchInputItemProtocol
/**
 名称
 */
@property(nonatomic, copy) NSString *inputItemtitle;
/**
 ID标记
 */
@property(nonatomic, copy) NSString *inputItemID;

@end

#endif /* CustomSearchInputItemProtocol_h */
