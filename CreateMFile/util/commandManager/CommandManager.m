//
//  CommandManager.m
//  CreateMFile
//
//  Created by LamTsanFeng on 14/12/11.
//  Copyright (c) 2014年 lincf. All rights reserved.
//

#import "CommandManager.h"

@implementation CommandManager

#pragma mark - 终端处理过程 返回是否成功
+ (BOOL)execSystemResult:(NSString *)strCommand
{
    int result;
    result=system([strCommand UTF8String]);
    if (!(WIFEXITED(result) && !(-1 == result) && 0 == WEXITSTATUS(result)))
    {
        return NO;
    }
    return YES;
}

#pragma mark - 终端处理过程 返回处理结果
+ (NSString *)runSystemCommand:(NSString *)command
{
    FILE* fp = NULL;
    char cmd[512];
    sprintf(cmd, "lipo -info %s ; echo $?", [command UTF8String]);
    if ((fp = popen(cmd, "r")) != NULL)
    {
        fgets(cmd, sizeof(cmd), fp);
        pclose(fp);
    }
    
    //0 成功， 1 失败
    printf("cmd is %s\n", cmd);
    return [NSString stringWithFormat:@"%s", cmd];
}

@end
