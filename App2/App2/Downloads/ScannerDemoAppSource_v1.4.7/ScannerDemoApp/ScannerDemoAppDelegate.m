/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  ScannerUIDemoAppDelegate.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ConnectionManager.h"
#import "ScannerDemoAppDelegate.h"
#import "ScannerAppEngine.h"
#import "AppSettingsKeys.h"
#import "config.h"
#import "UpdateFirmwareVC.h"
#import "ScannerAppEngine.h"
#import "ConnectionManager.h"
#import "RMDAttributes.h"

@implementation zt_ScannerDemoAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef SST_SKIP_BACKGROUND_DETECTION_TASK
    m_BackgroundHelperTask = UIBackgroundTaskInvalid;
#endif /* SST_SKIP_BACKGROUND_DETECTION_TASK */
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        /* ipad */
        if (m_SplitVCDelegate == nil)
        {
            m_SplitVC = (zt_TabletMainSplitVC*)self.window.rootViewController;
            m_SplitVCDelegate = [[zt_TabletMainSplitVCDelegate alloc] init];
            [m_SplitVC setDelegate:m_SplitVCDelegate];
        }
    }
    else
    {
        /* iphone */
        m_NavigationVC = (UINavigationController*)self.window.rootViewController;
    }

    // Override point for customization after application launch.
    
    /* initialize the engine */
    [zt_ScannerAppEngine sharedAppEngine];
    [[ConnectionManager sharedConnectionManager] initializeConnectionManager];
    
    /* the application is really started by notification, not just switched
     from backround to foreground */
    UILocalNotification *bg_notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (bg_notification)
    {
        [[zt_ScannerAppEngine sharedAppEngine] processBackroundNotification:bg_notification];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }
    
    // Extend the splash screen for 1.75 seconds.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.75]];
    
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *workDir = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    [self createDir:workDir];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
    {
        UINavigationController *navController = nil;
        zt_TabletMainSplitVC *splitVC = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            splitVC = (zt_TabletMainSplitVC*)self.window.rootViewController;
            navController = (UINavigationController*)[[splitVC viewControllers] objectAtIndex:1];
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            /* iphone */
            navController = (UINavigationController*)self.window.rootViewController;
        }
        if (navController != nil) {
            if ([navController.topViewController isKindOfClass:[UpdateFirmwareVC class]]) {
                return;
            }
        }
        
        [[zt_ScannerAppEngine sharedAppEngine] processBackroundNotification:notification];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
#ifndef SST_SKIP_BACKGROUND_DETECTION_TASK
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int op_mode = [settings integerForKey:ZT_SETTING_OPMODE];
    BOOL scanner_detection = [settings boolForKey:ZT_SETTING_SCANNER_DETECTION];

    if ((YES == scanner_detection) && (op_mode == DCSSDK_OPMODE_BTLE || op_mode == DCSSDK_OPMODE_ALL))
    {
        m_BackgroundHelperTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            if (m_BackgroundHelperTask != UIBackgroundTaskInvalid)
            {
                NSLog(@"Expiration handler: end background network detection task");
                [[UIApplication sharedApplication] endBackgroundTask:m_BackgroundHelperTask];
                m_BackgroundHelperTask = UIBackgroundTaskInvalid;
            }
        }];
        
        
        NSLog(@"BG task: wait for next step of LE detection procedure");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            /* do nothing */
            
            /* waiting for online and kill background task if
             sign in procedure was successfull. otherwise task will be killed
             in expiration handler */
            int timeout = 0;
            while ([[UIApplication sharedApplication] backgroundTimeRemaining] > 0)
            {
                usleep(1*1000*1000); // 1 second
                timeout++;
                if (timeout >= 30) /* 30 seconds; TBD: shall be configured in accordance with timeouts of DcsSdkConfig.h */
                {
                    NSLog(@"BG task has been executed for more than 30 seconds; stop");
                    [[UIApplication sharedApplication] endBackgroundTask:m_BackgroundHelperTask];
                    m_BackgroundHelperTask = UIBackgroundTaskInvalid;
                    return;
                }
            }
        });
    }
#endif /* SST_SKIP_BACKGROUND_DETECTION_TASK */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
#ifndef SST_SKIP_BACKGROUND_DETECTION_TASK
    if (m_BackgroundHelperTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:m_BackgroundHelperTask];
        m_BackgroundHelperTask = UIBackgroundTaskInvalid;
    }
#endif /* SST_SKIP_BACKGROUND_DETECTION_TASK */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    /* TBD: close communication sessions ? */
}

- (void)createDir:(NSString*)rootDir {
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootDir isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:rootDir
                                  withIntermediateDirectories:YES
                                                   attributes:attr
                                                        error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
}

@end
