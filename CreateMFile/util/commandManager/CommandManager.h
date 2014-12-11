//
//  CommandManager.h
//  CreateMFile
//
//  Created by LamTsanFeng on 14/12/11.
//  Copyright (c) 2014年 lincf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandManager : NSObject

//! 终端处理过程 返回是否成功
+ (BOOL)execSystemResult:(NSString *)strCommand;

//! 终端处理过程 返回处理结果
+ (NSString *)runSystemCommand:(NSString *)command;

@end
