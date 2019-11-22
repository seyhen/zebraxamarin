//
//  ScannerDetailsVC.h
//  ScannerSDKApp
//
//  Created by pqj647 on 11/25/15.
//  Copyright © 2015 Alexei Igumnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertView.h"

@interface ScannerDetailsVC : UITableViewController {
    BOOL didStartDataRetrieving;
    UIAlertView *alert;
    zt_AlertView *activityView;
    UIBarButtonItem *backBarButton;
}

// remove cancel button and restore back button
- (void) operationComplete;

@end
