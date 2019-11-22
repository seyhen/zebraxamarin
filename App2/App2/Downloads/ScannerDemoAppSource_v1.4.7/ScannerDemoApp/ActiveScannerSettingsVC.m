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
 *  Description:  ActiveScannerSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ActiveScannerSettingsVC.h"
#import "SymbologiesVC.h"
#import "config.h"
#import "ScannerAppEngine.h"
#import "ActiveScannerVC.h"
#import "BeeperSettingsVC.h"
#import "UpdateFirmwareVC.h"

@interface zt_ActiveScannerSettingsVC ()

@end

@implementation zt_ActiveScannerSettingsVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_ScannerID = -1;
        m_HideBeeperSettings = NO;
    }
    return self;
}

- (void)dealloc
{
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (m_ScannerID == -1)
    {
        m_ScannerID = [(zt_ActiveScannerVC*)self.tabBarController getScannerID];
        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID];
        if ([scanner_info getScannerModel] == SBT_DEVMODEL_SSI_CS4070)
        {
            m_HideBeeperSettings = YES;
        }
    }
}

- (void)performActionScanEnable:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_SCAN_ENABLE aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot perform [Scan Enable] action"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                           [alert release];
                       }
                       );
    }
}

- (void)performActionScanDisable:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_SCAN_DISABLE aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot perform [Scan Disable] action"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                           [alert release];
                       }
                       );
    }
}
- (void)performActionAimON:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_AIM_ON aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot perform [Aim On] action"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                           [alert release];
                       }
                       );
    }
}

- (void)performActionAimOFF:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_AIM_OFF aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot perform [Aim Off] action"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                           [alert release];
                       }
                       );
    }
}

- (void)performActionVibrationFeedBack:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_VIBRATION_FEEDBACK aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot perform [Vibration Feedback] action"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                           [alert release];
                       }
                       );
    }
}

#pragma mark - Table view data source
/* ###################################################################### */
/* ########## Table View Data Source Delegate Protocol implementation ### */
/* ###################################################################### */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return 8;// - (m_HideBeeperSettings == YES ? 1 : 0);
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
    if ([indexPath section] == 0)
    {
        if ([indexPath row] == 0) /* Symbologies */
        {
            zt_SymbologiesVC *symbologies_vc = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                symbologies_vc = (zt_SymbologiesVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_SYMBOLOGIES_VC"];
            }
            else
            {
                /* iphone */
                symbologies_vc = (zt_SymbologiesVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_SYMBOLOGIES_VC"];
            }
            
            if (symbologies_vc != nil)
            {
                [symbologies_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
                [self.navigationController pushViewController:symbologies_vc animated:YES];
                 /* symbologies_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }

        }
        else if ([indexPath row] == 1 /*&& NO == m_HideBeeperSettings*/) /* Beeper*/
        {
            zt_BeeperSettingsVC *beeper_vc = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                beeper_vc = (zt_BeeperSettingsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_BEEPER_VC"];
            }
            else
            {
                /* iphone */
                beeper_vc = (zt_BeeperSettingsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_BEEPER_VC"];
            }
            
            if (beeper_vc != nil)
            {
                [beeper_vc setScannerID:[(zt_ActiveScannerVC*)self.tabBarController getScannerID]];
                [self.navigationController pushViewController:beeper_vc animated:YES];
                /* beeper_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }

        }
        /*
        else if ([indexPath row] == 2) // FW Upgrade
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:MOT_SCANNER_APP_NAME
                                  message:@"Firmware upgrade functions are not supported"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        */
        else if ([indexPath row] == 2 /*(1 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 3 */) /* enable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionScanEnable:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 3 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionScanDisable:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 4 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionAimON:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 5 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionAimOFF:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 6 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performActionVibrationFeedBack:) withObject:in_xml withString:nil];
        }
        else if ([indexPath row] == 7 /*(2 + (m_HideBeeperSettings == YES ? 0 : 1))*/ /* 4 */) /* disable scanning */
        {
            UpdateFirmwareVC *updateFW_vc = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                updateFW_vc = (UpdateFirmwareVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_FWUPDATE_DAT_VC"];
            }
            else
            {
                /* iphone */
                updateFW_vc = (UpdateFirmwareVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNER_FWUPDATE_DAT_VC"];
            }
            
            if (updateFW_vc != nil)
            {
                [updateFW_vc setScannerID:m_ScannerID];
                [self.navigationController pushViewController:updateFW_vc animated:YES];
            }
        }

    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //[cell setSelected:NO animated:YES];
    }
}

@end
