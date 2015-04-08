//
//  ViewController.m
//  pathDir
//
//  Created by LamTsanFeng on 14/10/24.
//  Copyright (c) 2014年 lincf. All rights reserved.
//

#import "ViewController.h"
#import "FileManager.h"
#import "CommandManager.h"

#define pathName @"createMFile"
#define kErrorMsg @"文件错误或不存在！"
#define kCreateAFileName @"libXXX.a"

@implementation ViewController
{
    //文件管理器
    FileManager *fm;
    //获取所有文件的路径
    NSMutableArray *dirArray;
    
    // h文件名
    NSString *hFilename;
    // m文件名（根据h文件名转换）
    NSString *mFilename;
    // m文件路径（根据 isDesktop 生成位置）
    NSString *createMPath;
    
    BOOL isDesktop;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    //初始化文件管理器
    fm = [FileManager shareFileManager];
    
    dirArray = [[NSMutableArray alloc] init];
    // yes = m文件生成在桌面createMFile内; no ＝ m文件生成位置与h文件同路径
    isDesktop = YES;

}

- (void)viewDidDisappear
{
    exit(0);
}

#pragma mark - 点击选择文件事件
- (IBAction)hFileSelect:(id)sender {
    NSButton *button = sender;
    _showMsg.stringValue = @"";
    switch (button.tag) {
        case 1:
            self.hDirMsg.stringValue = @"";
            _hDir.stringValue = [self openFile:@"h"];
            break;
        case 2:
        {
            self.aDirFirstMsg.stringValue = @"";
            _aDirFirst.stringValue = [self openFile:@"a"];
            NSString *str = [CommandManager runSystemCommand:_aDirFirst.stringValue];
            self.aDirFirstMsg.stringValue = [[str componentsSeparatedByString:@":"] lastObject];
            break;
        }
        case 3:
        {
            self.aDirSecondMsg.stringValue = @"";
            _aDirSecond.stringValue = [self openFile:@"a"];
            NSString *str = [CommandManager runSystemCommand:_aDirSecond.stringValue];
            self.aDirSecondMsg.stringValue = [[str componentsSeparatedByString:@":"] lastObject];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - 点击生成事件
- (IBAction)CreateMFiles:(id)sender {
    NSString *documentDir = _hDir.stringValue;
    if (documentDir.length > 0) {
        //********************创建生成路径
        //在桌面创建文件夹pathDir
        NSString *tempPath;
        if (isDesktop) tempPath = [fm createPath:pathName];
        //********************判断路径是文件夹路径还是文件路径
        fileType isDir = [fm checkFilePath:documentDir suffix:nil];
        if (isDir == fileTypeIsFolder) {
            [fm ergodicFolder:documentDir list:dirArray];
            NSLog(@"Every Files in the dir:%@",dirArray);
        } else if(isDir == fileTypeIsFile) {
            [dirArray addObject:documentDir];
            NSLog(@"One File in the dir:%@",dirArray);
        } else if (isDir == fileTypeIsError) {
            self.hDirMsg.stringValue = kErrorMsg;
        }
        for (NSString *hFilePath in dirArray) {
            //********************创建m文件路径
            [self createMPath:hFilePath tempPath:tempPath];
            //********************读取h文件
            NSString *mFile = [self readHFileFormFilePath:hFilePath];
            //********************生成m文件
            NSError *error = nil;
            [mFile writeToFile:createMPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            NSString *errorMsg = [fm showError:[error localizedDescription]];
            if (errorMsg) {
                self.hDirMsg.stringValue = errorMsg;
            } else {
                self.showMsg.stringValue = [NSString stringWithFormat:@"生成m文件路径：%@", createMPath];
                [self showHelpMsg];
            }
            NSLog(@"生成m文件路径：%@", createMPath);
        }
        _hDir.stringValue = @"";
        [dirArray removeAllObjects];
    } else {
        self.hDirMsg.stringValue = @"文件不存在！";
    }
}

#pragma mark - 点击合并a文件
- (IBAction)appenAFile:(id)sender {
    NSString *aDirF = _aDirFirst.stringValue;
    NSString *aDirS = _aDirSecond.stringValue;
    NSArray *strings = [aDirF componentsSeparatedByString: @"/"];
    NSString *tempName  = [strings objectAtIndex:[strings count]-1];
    NSString *appenFilePath = [aDirF stringByReplacingOccurrencesOfString:tempName withString:@""];
    appenFilePath = [appenFilePath stringByAppendingString:kCreateAFileName];
    NSString *commond = [NSString stringWithFormat:@"lipo -create %@ %@ -output %@", aDirF, aDirS, appenFilePath];
    NSLog(@"%@", commond);
//    NSString *comm = @"lipo -info /Users/lincf/Downloads/ccpsdk/libccpapisdk.a";
    fileType aIsDirF = [fm checkFilePath:aDirF suffix:@".a"];
    fileType aIsDirS = [fm checkFilePath:aDirS suffix:@".a"];
    if ( aIsDirF == fileTypeIsFile && aIsDirS==fileTypeIsFile ) {
        if ([CommandManager execSystemResult:commond]) {
            _aDirFirst.stringValue = @"";
            _aDirSecond.stringValue = @"";
            _aDirFirstMsg.stringValue = @"";
            _aDirSecondMsg.stringValue = @"";
            NSLog(@"合成成功！");
            _showMsg.stringValue = [NSString stringWithFormat:@"生成a文件路径：%@", appenFilePath];
            NSLog(@"生成a文件路径：%@", appenFilePath);
        }else{
            _showMsg.stringValue = @"合成失败！";
            NSLog(@"合成失败！");
        }
    } else {
        if (aIsDirF == fileTypeIsError) {
            self.aDirFirstMsg.stringValue = kErrorMsg;
        } else if (aIsDirS == fileTypeIsError){
            self.aDirSecondMsg.stringValue = kErrorMsg;
        }
    }
}

#pragma mark - 根据返回类型替换
- (NSString *)methodReturnType:(int)type
{
    NSString *str;
    switch (type) {
        case methodType_void:
            str = [NSString stringWithFormat:@"\n{\n\n}\n\n"];
            break;
        case methodType_string:
            str = [NSString stringWithFormat:@"\n{\n    return 0;\n}\n\n"];
            break;
        default:
            break;
    }
    return str;
}

#pragma mark - 生成m文件路径
- (void)createMPath:(NSString *)hFilePath tempPath:(NSString *)tempPath
{
    //创建m文件
    NSArray *strings = [hFilePath componentsSeparatedByString: @"/"];
    hFilename  = [strings objectAtIndex:[strings count]-1];
    mFilename = [NSString stringWithFormat:@"%@%@", [hFilename substringToIndex:hFilename.length-@".h".length], @".m"];
    if (tempPath != nil) {
        createMPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", pathName, mFilename]];
    } else {
        //*********生成m文件路径与h文件相同
        NSString *mFilePath = [hFilePath stringByReplacingOccurrencesOfString:hFilename withString:@""];
        mFilePath = [mFilePath stringByAppendingString:mFilename];
        createMPath = mFilePath;
    }
}

#pragma mark - 读取文件夹路径下的h文件
- (NSString *)readHFileFormFilePath:(NSString *)hFilePath
{
    NSData* data = [[NSData alloc] init];
    data = [fm contentsAtPath:hFilePath];
    //生成m文件并处理import部分
    NSString *hFile = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableString *mFile = [[NSMutableString alloc] initWithFormat:@"#import \"%@\"", hFilename];
    [mFile appendString:@"\n\n"];
    
    //按行读取文件
    NSString *tmp;
    //按行拆分文件内容
    NSArray *lines = [hFile componentsSeparatedByString:@"\n"];
    NSEnumerator *nse = [lines objectEnumerator];
    //按行读取文件内容
    while(tmp = [nse nextObject]) {
        //处理m文件的@implementation部分
        if ([tmp hasPrefix:@"@interface"]) {
            tmp =  [tmp substringFromIndex:@"@interface".length];
            NSRange range = [tmp rangeOfString:@":"];
            tmp = [[tmp substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [mFile appendString:[NSString stringWithFormat:@"@implementation %@", tmp]];
            [mFile appendString:@"\n\n"];
        }
        //处理m文件的@end部分
        if ([tmp hasPrefix:@"@end"]) {
            [mFile appendString:tmp];
            [mFile appendString:@"\n\n"];
        }
        //判断是否方法
        if ([tmp hasPrefix:@"-"]) {
            //            NSLog(@"替换前tmp:%@", tmp);
            //判断是否有返回类型
            NSRange foundObj=[tmp rangeOfString:@"(void)" options:NSCaseInsensitiveSearch];
            if (foundObj.length > 0) {
                //没有返回类型
                tmp = [tmp stringByReplacingOccurrencesOfString:@";" withString:[self methodReturnType:methodType_void]];
            } else {
                //有返回类型
                tmp = [tmp stringByReplacingOccurrencesOfString:@";" withString:[self methodReturnType:methodType_string]];
            }
            //            NSLog(@"替换后tmp:%@", tmp);
            [mFile appendString:tmp];
        }
    }
    return mFile;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSString *)openFile:(NSString *)suffix{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    //允许打开目录
    [oPanel setCanChooseDirectories:YES];
    //不允许打开多个文件
    [oPanel setAllowsMultipleSelection:NO];
    //限制打开文件后缀名
    [oPanel setAllowedFileTypes:[NSArray arrayWithObject:suffix]];
    //可以打开文件
    [oPanel setCanChooseFiles:YES];
    //点击ok返回文件路径
    if ([oPanel runModal] == NSModalResponseOK)
    {
        return [[[oPanel URLs] objectAtIndex:0] path];
    }else {
        return @"";
    }
}
- (IBAction)selectIsDestop:(id)sender {
    NSButton *btn = (NSButton *)sender;
    isDesktop = (BOOL)[btn state];
}

- (void)showHelpMsg
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSInformationalAlertStyle;
    alert.messageText = @"帮助";
    alert.informativeText = @"目前暂不支持编译.a文件，需要自己编译项目得到";
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:nil];
}

@end
