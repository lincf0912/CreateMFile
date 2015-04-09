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
    if (command.length > 0) {
        FILE* fp = NULL;
        char cmd[512];
        NSString *resultStr = @"";
        sprintf(cmd, "lipo -info %s ; echo $?", [command UTF8String]);
        if ((fp = popen(cmd, "r")) != NULL)
        {
            while (fgets(cmd, sizeof(cmd), fp) != NULL) {
                if (cmd[strlen(cmd) - 1] == '\n') {
                    cmd[strlen(cmd) - 1] = '\0'; //去除换行符
                }
                if (![@"0" isEqualToString:[NSString stringWithUTF8String:cmd]]) {
                    resultStr = [resultStr stringByAppendingFormat:@"%s", cmd];
                }
            }
//            fgets(cmd, sizeof(cmd), fp);
            pclose(fp);
        }
        
        //0 成功， 1 失败
        printf("resultStr is %s\n", [resultStr UTF8String]);
        return resultStr;
    }
    return @"";
}

@end
