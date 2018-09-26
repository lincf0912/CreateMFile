//
//  FileManager.h
//  CreateMFile
//
//  Created by LamTsanFeng on 14/12/11.
//  Copyright (c) 2014年 lincf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, fileType) {
    /*! 文件 */
    fileTypeIsFile = 0,
    /*! 文件夹 */
    fileTypeIsFolder,
    /*! 其他 */
    fileTypeIsOther,
    /*! 错误 */
    fileTypeIsError
};

@interface FileManager : NSObject
{
    //文件管理器
    NSFileManager * fm;
}

+ (id)shareFileManager;

//! 创建文件路径
- (NSString *)createPath:(NSString *)pathName;

//! 复制文件路径
- (BOOL)copyAtPath:(NSString *)atPath toPath:(NSString *)toPath;

//! 判断路径是文件夹路径还是文件路径
- (fileType)checkFilePath:(NSString *)path suffix:(NSString *)suffix;

//! 遍历文件夹内的文件，将所有子目录的文件找出
- (void)ergodicFolder:(NSString *)documentDir complete:(void (^)(NSString *filePath, BOOL *stop))complete;
- (void)ergodicFolderWithHFile:(NSString *)documentDir list:(NSMutableArray *)dirArray;

//! 读取文件的数据
- (NSData *)contentsAtPath:(NSString *)path;

//! 返回错误信息
- (NSString *)showError:(NSString *)error;
@end
