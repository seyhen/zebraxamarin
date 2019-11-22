//
//  ScannerDetailsVC.m
//  ScannerSDKApp
//
//  Created by pqj647 on 11/25/15.
//  Copyright © 2015 Alexei Igumnov. All rights reserved.
//

#import "ScannerDetailsVC.h"
#import "config.h"

@interface ScannerDetailsVC ()

@end

@implementation ScannerDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    activityView = [[zt_AlertView alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Hide the standard back button
    [self.navigationItem setHidesBackButton:YES];
    
    // Add the custom back button
    backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(confirmCancel)];
    self.navigationItem.leftBarButtonItem =backBarButton;
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self operationComplete];
}

- (void) operationComplete
{
    /**
    Restore the standard back button
    **/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.navigationItem.hidesBackButton) {
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:NO];
        }
    });
    

}

- (void)confirmCancel
{
    if (alert) {
        if (alert.visible) {
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
    if (didStartDataRetrieving) {
        alert = [[UIAlertView alloc] initWithTitle:ZT_SCANNER_APP_NAME
                                           message:@"Are you sure that you want to go back?"
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"Continue", nil];
        [alert show];
    } else {
        didStartDataRetrieving = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0: //"Cancel" pressed
            //
            break;
            
        case 1: //"Continue" pressed
            didStartDataRetrieving = NO;
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
