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
 *  Description:  TabletMainSplitVCDelegate.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "TabletMainSplitVCDelegate.h"

@implementation zt_TabletMainSplitVCDelegate

-(id)init
{
    self = [super init];
	if (self != nil)
    {
        m_SplitViewController = nil;
    }
    return self;
}

-(void)dealloc
{
    /* deallocation */
    if (m_SplitViewController != nil)
    {
        [m_SplitViewController release];
    }
    [super dealloc];
}

-(void)setSplitViewController:(UISplitViewController*)controller
{
    m_SplitViewController = controller;
}

/* ###################################################################### */
/* ########## UISplitViewController Delegate Protocol implementation #### */
/* ###################################################################### */
- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
}

@end
