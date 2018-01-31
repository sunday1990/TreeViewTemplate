//
//  CustomNodeModelProtocol.h
//  TreeNodeStructure
//
//  Created by ccSunday on 2018/1/31.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#ifndef CustomNodeModelProtocol_h
#define CustomNodeModelProtocol_h
#import "NodeModelProtocol.h"

@protocol CustomNodeModelProtocol <NodeModelProtocol>
/*自定义属性*/
@property(nonatomic, strong) id customProperty;
@property(nonatomic, strong) id customProperty1;
@property(nonatomic, strong) id customProperty2;
@property(nonatomic, strong) id customProperty3;
@property(nonatomic, strong) id customProperty4;
/*自定义方法*/
- (void)customMethod;
@end

#endif /* CustomNodeModelProtocol_h */
