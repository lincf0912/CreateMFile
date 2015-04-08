//
//  ViewController.h
//  CreateMFile
//
//  Created by LamTsanFeng on 14/10/24.
//  Copyright (c) 2014年 lincf. All rights reserved.
//

/** 
 使用说明：
 
1.指定.h文件生成.m文件

2.指定路径，根据路径下的.h文件批量生产.m文件

3.将2个不同类型的.a文件合并成一个.a文件
 
 附加功能（待完善）：
 编译.m文件 xcrun clang -c *.m
 当前目录中的所有.o文件创建libxx.a静态库：
*/

#import <Cocoa/Cocoa.h>

typedef enum methodType
{
    methodType_void = 0,
    methodType_string = 1,
}methodType;

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *hDir;
@property (weak) IBOutlet NSTextField *aDirFirst;
@property (weak) IBOutlet NSTextField *aDirSecond;
@property (weak) IBOutlet NSTextField *hDirMsg;
@property (weak) IBOutlet NSTextField *aDirFirstMsg;
@property (weak) IBOutlet NSTextField *aDirSecondMsg;
@property (weak) IBOutlet NSTextField *showMsg;
- (IBAction)selectIsDestop:(id)sender;

@end

