//
//  AppDelegate.m
//  handbooklite
//
//  Created by bao_wsfk on 12-8-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "BookShelfViewController.h"
#import "Config.h"
#import "TokenUtil.h"
#import "DBUtils.h"
#import "JSONKit.h"
#import "Book.h"



@implementation AppDelegate

@synthesize window = _window;
@synthesize bookShelfViewController = _bookShelfViewController;
@synthesize navigationController = _navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  int cacheSizeMemory = 4*1024*1024; // 4MB
  int cacheSizeDisk = 32*1024*1024; // 32MB
  NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
  [NSURLCache setSharedURLCache:sharedCache];
  
  
  /**
  timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                    target:self
                                                  selector:@selector(onTimer:)
                                                  userInfo:nil
                                                   repeats:YES];
  **/
    //注册推送通知
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    if (launchOptions) {
        NSDictionary *pushNotificationKey =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //通知下载
        NSDictionary *aps =[pushNotificationKey objectForKey:@"aps"];
        
        [self performSelector:@selector(sendNotification:) withObject:aps afterDelay:0.5];
        application.applicationIconBadgeNumber = 0;
    }else{
        CCLog(@"launchOptions空");
    }
    
    
    //初始化基础数据
    [self initBaseData];
    
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
    
//    NSArray *familyNames =[UIFont familyNames];
//    for (NSString *familyName in familyNames) {
//        CCLog(@"------\n%@",familyNames);
//        NSArray *fontNames =[UIFont fontNamesForFamilyName:familyName];
//        for (NSString *fontName in fontNames) {
//            CCLog(@"------\n%@",fontName);
//        }
//    }
    
    [iConsole sharedConsole].delegate = self;
    [iConsole sharedConsole].logLevel = iConsoleLogLevelWarning;
    [iConsole sharedConsole].logSubmissionEmail = @"hanbing.cn@gmail.com";
    
    self.window = [[InterceptorWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    // Override point for customization after application launch.
   
    _bookShelfViewController = [[BookShelfViewController alloc]
                                    initWithNibName:@"BookShelfViewController"
                                    bundle:nil];
    
    _navigationController = [[UINavigationController alloc]initWithRootViewController:_bookShelfViewController];
    self.window.rootViewController = _navigationController;
    
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)onTimer:(id)sender
{
  NSLog(@"使用 %f 剩余 %f",[self usedMemory],[self availableMemory]);
}

- (void)sendNotification:(NSDictionary *)aps{
    
    NSString *message =[(NSDictionary *)[aps objectForKey:@"alert"] objectForKey:@"body"];
    NSString *downnum =[aps objectForKey:@"downnum"];
    NSMutableDictionary *pushData =[[NSMutableDictionary alloc] init];
    [pushData setObject:message forKey:@"message"];
    [pushData setObject:downnum forKey:@"downnum"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"push_notification" object:pushData];
}

//实现推送回调函数
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *tt = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *myDeviceToken = [[tt substringWithRange:NSMakeRange(1, [tt length]-2)]stringByReplacingOccurrencesOfString:@" " withString:@""];
    
//    CCLog(@"deviceToken:%@",myDeviceToken);
    //更新本地token
    [TokenUtil updateLocalToken:myDeviceToken];
}

//在线接收推送回调函数
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    //接收推送
    NSDictionary *aps =[userInfo objectForKey:@"aps"];
    NSString *message =[(NSDictionary *)[aps objectForKey:@"alert"] objectForKey:@"body"];
    NSString *downnum =[aps objectForKey:@"downnum"];
    NSMutableDictionary *pushData =[[NSMutableDictionary alloc] init];
    [pushData setObject:message forKey:@"message"];
    [pushData setObject:downnum forKey:@"downnum"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"push_notification" object:pushData];
    application.applicationIconBadgeNumber = 0;
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //click to HOME exit(0)
    //exit(0);
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
     // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initBaseData{
    NSFileManager *fm =[NSFileManager defaultManager];
    //判断caches中是否存在books目录 不存在就从本地拷贝
    NSString *books_resource_path =[RESOURCE_PATH stringByAppendingPathComponent:@"books"];
    NSString *books_cache_path =[CACHE_PATH stringByAppendingPathComponent:@"books"];
    
    if (![fm fileExistsAtPath:books_cache_path]) {
        BOOL result =[fm copyItemAtPath:books_resource_path toPath:books_cache_path error:nil];
        if (result) {
            CCLog(@"books拷贝成功");
        }else {
            CCLog(@"books拷贝失败");
        }
    }else{
        //判断是否存在db.sqlite3文件
        if (![fm fileExistsAtPath:[books_cache_path stringByAppendingPathComponent:@"db.sqlite3"]]) {
            
            [fm copyItemAtPath:[books_resource_path stringByAppendingPathComponent:@"db.sqlite3"] toPath:[books_cache_path stringByAppendingPathComponent:@"db.sqlite3"] error:nil];
            [self copyJsonDataToDb:fm resourcePath:books_resource_path cachePath:books_cache_path];
            
        }
    }
}

//拷贝json数据到数据库中
- (void)copyJsonDataToDb:(NSFileManager *)fm resourcePath:(NSString *)resourcePath cachePath:(NSString *)cachePath{
    
    //判断是否存在 books.json文件
    if ([fm fileExistsAtPath:[cachePath stringByAppendingPathComponent:@"books.json"]] &&
        [fm fileExistsAtPath:[cachePath stringByAppendingPathComponent:@"downnum.json"]]) {
        
        NSArray *books =[(NSDictionary *)[[NSData dataWithContentsOfFile:
                                           [cachePath stringByAppendingPathComponent:@"books.json"]] objectFromJSONData] objectForKey:@"books"];
        NSArray *downnums =[[[NSData dataWithContentsOfFile:
                            [cachePath stringByAppendingPathComponent:@"downnum.json"]]
                             objectFromJSONData] objectForKey:@"downnums"];
        
        for (NSString *downnum in downnums) {
            NSDictionary *bookDic =[self bookByDownNum:downnum fromBooks:books];
            Book *book =[[Book alloc] init];
            [book setName:[bookDic objectForKey:@"name"]];
            [book setDir:[bookDic objectForKey:@"dir"]];
            [book setDownnum:downnum];
            [book setBookId:@"null"];
            [book setIcon:[bookDic objectForKey:@"icon"]];
            [book setZip:[bookDic objectForKey:@"zip"]];
            [DBUtils insertBook:book];
            
        }
        //删除books.json 和downnum.json文件
        [fm removeItemAtPath:[cachePath stringByAppendingPathComponent:@"books.json"] error:nil];
        [fm removeItemAtPath:[cachePath stringByAppendingPathComponent:@"downnum.json"] error:nil];
    }
    
    
}

- (NSDictionary *)bookByDownNum:(NSString *)downnum fromBooks:(NSArray *)books{
    
    for (NSDictionary *book in books) {
        /**
         ["123":{"icon":"icon.jpg","name","时尚家居","dir":"123"}]
         */
        if ([book objectForKey:downnum] !=nil) {
            return [book objectForKey:downnum];
        }
    }
    return nil;
}

- (void)showWaitting{
    
    if (!_waitAlert) {
        _waitAlert =[[WaitAlertView alloc] init];
    }
    [_waitAlert show];
}

- (void)dismissWaitting{
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
}

- (void)dismiss{
    if (_waitAlert) {
        [_waitAlert dismiss],_waitAlert =nil;
    }
}

//MARK: 可用内存
- (double)availableMemory
{
  vm_statistics_data_t vmStats;
  mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
  kern_return_t kernReturn = host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vmStats,&infoCount);
  if(kernReturn != KERN_SUCCESS)
  {
    return NSNotFound;
  }
  return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}


//MARK: 已使用内存
- (double)usedMemory
{
  task_basic_info_data_t taskInfo;
  mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
  kern_return_t kernReturn = task_info(mach_task_self(),
                                       TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
  if(kernReturn != KERN_SUCCESS) {
    return NSNotFound;
  }
  return taskInfo.resident_size / 1024.0 / 1024.0;
}

#pragma --mark iConsole delegate
- (void)handleConsoleCommand:(NSString *)command
{
	if ([command isEqualToString:@"version"])
	{
		[iConsole info:@"%@ version %@",
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
		 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	}
	else
	{
		[iConsole error:@"unrecognised command, try 'version' instead"];
	}
}

-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application{
  [iConsole log:@"===> applicationDidReceiveMemoryWarning"];
   [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
