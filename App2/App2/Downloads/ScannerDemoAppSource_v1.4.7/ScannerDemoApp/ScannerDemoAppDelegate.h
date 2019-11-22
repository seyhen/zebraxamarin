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
 *  Description:  ScannerUIDemoAppDelegate.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TabletMainSplitVC.h"
#import "TabletMainSplitVCDelegate.h"

/* 
 undef to enable starting BTLE discovery procedure on
 transition to a background mode 
 note: shall be aligned with DCSSDK_CFG_BTLE_BACKGROUND_DETECTION_DISABLED (DcsSdkConfig.h) 
 */
#define SST_SKIP_BACKGROUND_DETECTION_TASK

@interface zt_ScannerDemoAppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *m_NavigationVC;
    zt_TabletMainSplitVC *m_SplitVC;
    zt_TabletMainSplitVCDelegate *m_SplitVCDelegate;
#ifndef SST_SKIP_BACKGROUND_DETECTION_TASK    
    UIBackgroundTaskIdentifier m_BackgroundHelperTask;
#endif /* SST_SKIP_BACKGROUND_DETECTION_TASK */
}

@property (strong, nonatomic) UIWindow *window;

@end
