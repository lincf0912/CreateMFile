//
//  FileManager.m
//  CreateMFile
//
//  Created by LamTsanFeng on 14/12/11.
//  Copyright (c) 2014年 lincf. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

static FileManager *shared = nil;

+ (id)shareFileManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
        [shared initFileManager];
    });
    return shared;
}

- (void)initFileManager
{
    //初始化文件管理器
    fm = [NSFileManager defaultManager];
}

#pragma mark - 创建文件路径
- (NSString *)createPath:(NSString *)pathName
{
    NSError *error = nil;
    NSString* tempPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject];
    //创建目录
    [fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", tempPath, pathName] withIntermediateDirectories:YES attributes:nil error:&error];
    //第一个参数是路径，第二个参数表示是否创建缺失的中间路径，如果传NO，如果有缺失的中间路径，如Middle，则创建失败报错。如果传入YES则自动补全缺失的中间路径。第三个参数表示文件或目录的属性，传入nil，表示默认属性。一般使用默认属性就可以了。
    [self showError:[error localizedDescription]];
    NSLog(@"创建目录成功 路径：%@/%@", tempPath, pathName);
    return tempPath;
}

- (BOOL)copyAtPath:(NSString *)atPath toPath:(NSString *)toPath
{
    NSError *error = nil;
    BOOL isOK = [fm copyItemAtPath:atPath toPath:toPath error:&error];
    [self showError:[error localizedDescription]];
    
    return isOK;
}

#pragma mark - 判断路径是文件夹路径还是文件路径
- (fileType)checkFilePath:(NSString *)path suffix:(NSString *)suffix
{
    BOOL isDir,isPath;
    //检查路径是否正确
    isPath = [fm fileExistsAtPath:path isDirectory:&isDir];
    if (isPath) {
        //判断路径是文件夹还是文件
        if (isDir) {
            //文件夹
            return fileTypeIsFolder;
        } else {
            if ( suffix.length ) {
                if ( [path hasSuffix:suffix] ) {
                    return fileTypeIsFile;
                } else {
                    NSLog(@"没有匹配文件");
                    return fileTypeIsOther;
                }
            }
            return fileTypeIsFile;
        }
    } else {
        NSLog(@"文件不存在");
        return fileTypeIsError;
    }
}

#pragma mark - 遍历文件夹内的文件，将所有子目录的文件找出
- (void)ergodicFolder:(NSString *)documentDir complete:(void (^)(NSString *filePath, BOOL *stop))complete
{
    if (complete == nil) return;
    NSError *error = nil;
    BOOL stop = NO;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fm contentsOfDirectoryAtPath:documentDir error:&error];
    [self showError:[error localizedDescription]];
    fileType isDir;
    //在上面那段程序中获得的fileList中列出文件夹名
    for (NSString *file in fileList) {
        NSString *path = [documentDir stringByAppendingPathComponent:file];
        isDir = [self checkFilePath:path suffix:nil];
        if (isDir == fileTypeIsFolder && ![[path lowercaseString] hasSuffix:@"framework"]) {
            [self ergodicFolder:path complete:complete];
        } else if(isDir == fileTypeIsFile || [[path lowercaseString] hasSuffix:@"framework"]) {
            complete(path, &stop);
            if (stop) {
                break;
            }
        }
    }
}
- (void)ergodicFolderWithHFile:(NSString *)documentDir list:(NSMutableArray *)dirArray
{
    [self ergodicFolder:documentDir complete:^(NSString *filePath, BOOL *stop) {
        //对文件路径进行筛选
        if ([filePath hasSuffix:@".h"] && ![filePath hasPrefix:@"."]) {
            [dirArray addObject:filePath];
        }
    }];
}

#pragma mark - 读取文件的数据
- (NSData *)contentsAtPath:(NSString *)path
{
    return [fm contentsAtPath:path];
}

#pragma mark - 返回错误信息
- (NSString *)showError:(NSString *)error
{
    if(error){
        NSLog(@"%@", error);
        return error;
    }
    return nil;
}

@end
