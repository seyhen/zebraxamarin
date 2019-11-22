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
 *  Description:  TabletMainSplitVCDelegate.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>

@interface zt_TabletMainSplitVCDelegate : NSObject <UISplitViewControllerDelegate>
{
    UISplitViewController *m_SplitViewController;
}

-(void)setSplitViewController:(UISplitViewController*)controller;

@end
