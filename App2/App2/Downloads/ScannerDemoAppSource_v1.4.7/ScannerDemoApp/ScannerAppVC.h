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
 *  Description:  ScannerAppVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ActiveScannerVC.h"
#import "ScannerAppEngine.h"

@interface zt_ScannerAppVC : UITableViewController <IScannerAppEngineDevEventsDelegate>

@property (nonatomic, retain) zt_ActiveScannerVC *activeScannerVc;

@end
