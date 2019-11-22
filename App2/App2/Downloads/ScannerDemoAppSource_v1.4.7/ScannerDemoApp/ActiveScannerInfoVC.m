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
 *  Description:  ActiveScannerInfoVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveScannerInfoVC.h"
#import "ActiveScannerVC.h"
#import "ConnectionManager.h"
#import "ScannerAppEngine.h"
#import "config.h"
#import "LedActionVC.h"
#import "BeeperActionVC.h"
#import "AssetDetailsVC.h"

typedef enum
{
    SECTION_ACTIONS = 0,
    SECTION_INFORMATION,
    SECTION_DISCONNECT,
    SECTION_CONNECTION,
    SECTION_TOTAL
} InfoSection;

@interface zt_ActiveScannerInfoVC ()

@end

@implementation zt_ActiveScannerInfoVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_IsBusy = NO;
    }
    return self;
}

- (void)dealloc
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    [m_AutoReconnectionSwitch release];
    [m_lblScannerName release];
    
    if (activityView != nil)
    {
        [activityView release];
    }

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    activityView = [[zt_AlertView alloc]init];
    
    // Initialize the connection manager
    [ConnectionManager sharedConnectionManager];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateUI];
}

- (void)updateUI
{
    BOOL animation = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NO : YES);
    if ([self.tabBarController isKindOfClass:[zt_ActiveScannerVC class]] == YES)
    {
        int scanner_id = [(zt_ActiveScannerVC*)self.tabBarController getScannerID];
        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scanner_id];
        if (scanner_info != nil)
        {
            switch ([scanner_info getConnectionType])
            {
                case SBT_CONNTYPE_MFI:
                    [m_lblScannerName setText:[NSString stringWithFormat:@"%@ (%@)", [scanner_info getScannerName], [[zt_ScannerAppEngine sharedAppEngine] getScannerModelName:[scanner_info getScannerModel]]]];
                    break;
                case SBT_CONNTYPE_BTLE:
                    [m_lblScannerName setText:[NSString stringWithFormat:@"%@ (%@)", [scanner_info getScannerName], [[zt_ScannerAppEngine sharedAppEngine] getScannerModelName:[scanner_info getScannerModel]]]];
                    break;
            }

            [m_AutoReconnectionSwitch setOn:[scanner_info getAutoCommunicationSessionReestablishment] animated:animation];
            
            return;
        }
    }
    [m_AutoReconnectionSwitch setOn:NO animated:animation];
    
}

- (IBAction)switchAutoReconnectionValueChanged:(id)sender
{
    SBT_RESULT result = NO;
    if ([self.tabBarController isKindOfClass:[zt_ActiveScannerVC class]] == YES)
    {
        int scanner_id = [(zt_ActiveScannerVC*)self.tabBarController getScannerID];

        result = [[zt_ScannerAppEngine sharedAppEngine] setAutoReconnectOption:scanner_id enableOption:[m_AutoReconnectionSwitch isOn]];
    }
    if(result == SBT_RESULT_SCANNER_NOT_CONNECT_STC && [(UISwitch *)sender isOn]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zebra Scanner Control"
                                                        message:@"This feature available for STC connected scanners only"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [sender setOn:NO animated:YES];
    }
    
}

- (void)terminateCommunicationSession
{
    if ([self.tabBarController isKindOfClass:[zt_ActiveScannerVC class]] == YES)
    {
        [[ConnectionManager sharedConnectionManager] disconnect];
    }

    m_IsBusy = NO;
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return SECTION_TOTAL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_DISCONNECT:
            return 1;
        case SECTION_INFORMATION:
            return 2;
        case SECTION_CONNECTION:
            return 1;
        case SECTION_ACTIONS:
        {
            int scanner_id = [(zt_ActiveScannerVC*)self.tabBarController getScannerID];
            SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scanner_id];
            if ([scanner_info getScannerModel] == SBT_DEVMODEL_SSI_RFD8500)
            {
                // only show Beeper controls for RFD8500
                return 1;
            }
            else
            {
                // show both Beeper and LED controls for all other devices
                return 2;
            }
        }

        default:
            return 0;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
/* ###################################################################### */
/* ########## Table View Delegate Protocol implementation ############### */
/* ###################################################################### */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */


    if ([indexPath section] == SECTION_ACTIONS) /* actions section */
    {
        if ([indexPath row] == 0) /* Beeper */
        {
            zt_BeeperActionVC *beeper_vc = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                beeper_vc = (zt_BeeperActionVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_BEEPER_ACTION_VC"];
            }
            else
            {
                /* iphone */
                beeper_vc = (zt_BeeperActionVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_BEEPER_ACTION_VC"];
            }
            
            if (beeper_vc != nil)
            {
                [beeper_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
                [self.navigationController pushViewController:beeper_vc animated:YES];
                /* beeper_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }
        else if ([indexPath row] == 1) /* LED */
        {
            zt_LedActionVC *led_vc = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                led_vc = (zt_LedActionVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_LED_ACTION_VC"];
            }
            else
            {
                /* iphone */
                led_vc = (zt_LedActionVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_LED_ACTION_VC"];
            }
            
            if (led_vc != nil)
            {
                [led_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
                [self.navigationController pushViewController:led_vc animated:YES];
                /* led_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }

        }
    }
    
    if (([indexPath section] == SECTION_DISCONNECT) && ([indexPath row] == 0)) /* Disconnect button */
    {
        if (NO == m_IsBusy)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnect?"
                                                            message:@"This will disconnect the application from the scanner, however the device will still be paired to the system."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Continue", nil];
            [alert show];
            [alert release];
        }
    }
    
    if ([indexPath section] == SECTION_INFORMATION && [indexPath row] == 1) {
        AssetDetailsVC *assets_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            assets_vc = (AssetDetailsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ASSET_DETAILS_VC"];
        }
        else
        {
            /* iphone */
            assets_vc = (AssetDetailsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ASSET_DETAILS_VC"];
        }
        
        if (assets_vc != nil)
        {
            SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
            [assets_vc setScanner_info:scanner_info];
            [self.navigationController pushViewController:assets_vc animated:YES];
        }
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //[cell setSelected:NO animated:YES];
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0: //"Cancel" pressed
            // don't do anything if user does not want to disconnect
            break;
            
        case 1: //"Continue" pressed, disconnect from scanner
            
            m_IsBusy = YES;
            
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(terminateCommunicationSession) withObject:nil withString:@"Disconnecting..."];

            break;
    }
}

@end
