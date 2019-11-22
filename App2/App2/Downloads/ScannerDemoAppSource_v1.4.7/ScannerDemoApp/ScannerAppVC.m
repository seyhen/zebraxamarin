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
 *  Description:  ScannerAppVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ScannerAppVC.h"
#import "ActiveScannerVC.h"
#import "AppSettingsVC.h"
#import "AboutAppVC.h"
#import "TabletNoticeVC.h"
#import "ScannersTableVC.h"
#import "config.h"
#import "ConnectionHelpVC.h"

typedef enum
{
    MENU_INDEX_CONNECTION = 0,
    MENU_INDEX_CONNECTION_HELP,
    MENU_INDEX_APP_SETTINGS,
    MENU_INDEX_ABOUT,
    MENU_INDEX_TOTAL
    
} MainMenuIndex;

@interface zt_ScannerAppVC ()

@end

@implementation zt_ScannerAppVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [[zt_ScannerAppEngine sharedAppEngine] addDevEventsDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    [[zt_ScannerAppEngine sharedAppEngine] removeDevEventsDelegate:self];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:ZT_SCANNER_APP_NAME];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [back autorelease];
    self.navigationItem.backBarButtonItem = back;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /* for iPad only: we should select some row in master view to show smth in
     detail view of split view controller */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        /* ipad */
        [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        /* delegate event is not triggered when selecting row programatically */
        
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayBarcodeFromScannerId:(int)scannerId
{
    // when a barcode is processed, automatically open the active scanner view controller
    // and show the barcode screen. this will happen no matter what screen the user is on.
    // this function will setup the view controllers to display the barcode information.
    
    // check if the active scanner vc is on top of the navigation stack.
    
    UIViewController *topVc;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        // iphone
        
        // the top view controller is on top of the navigation controller's stack
        topVc = [self.navigationController topViewController];
    }
    else
    {
        // ipad
        
        // get the detail view controller (right side of split view controller)
        UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
        
        // the top view controller is on top of the detail view controller's stack
        topVc = [detail_vc topViewController];
    }
    
    // is this view controller the active scanner vc?
    if ([topVc isKindOfClass:[zt_ActiveScannerVC class]] == YES)
    {
        // is this active scanner vc for the current scanner id?
        if ([(zt_ActiveScannerVC*)topVc getScannerID] == scannerId)
        {
            // yes it is, show the barcode information
            [(zt_ActiveScannerVC*)topVc showBarcode];
        }
    }
    else
    {
        // the top view controller is not the active scanner vc
        
        // pop out the view controllers, and only include the scanner's vc
        // and the active scanner vc corresponding to the scanner id.
        
        UINavigationController *mainNavVc;
        zt_ScannersTableVC *scanners_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            mainNavVc = self.navigationController;
            
            scanners_vc = (zt_ScannersTableVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNERS_TABLE_VC"];
        }
        else
        {
            // the main navigation vc is on the left of the split view
            mainNavVc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:0];
            
            scanners_vc = (zt_ScannersTableVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNERS_TABLE_VC"];
        }
        
        // pop to root view controller
        [mainNavVc popToRootViewControllerAnimated:NO];
        
        if (scanners_vc != nil)
        {
            [mainNavVc pushViewController:scanners_vc animated:NO];
            [scanners_vc showActiveScannerVC:[NSNumber numberWithInt:scannerId] aBarcodeView:YES aAnimated:NO];
        }
    }
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevEventsDelegate Protocol implementation ## */
/* ###################################################################### */


- (void)scannerBarcodeEvent:(NSData*)barcodeData barcodeType:(int)barcodeType fromScanner:(int)scannerID
{
    [self displayBarcodeFromScannerId:scannerID];
}

- (void)showScannerRelatedUI:(int)scannerID barcodeNotification:(BOOL)barcode
{
    /* do not update UI for barcode notification. the UI update to handle this
       is already accounted for in the barcode event callback */
    if (barcode == NO)
    {
        /* check whether particular scanner is available, active or disappeared */
        SbtScannerInfo *scanner_info = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:scannerID];
        
        UINavigationController *main_navigation_vc = nil;
        UIViewController *root_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            /* iphone */
            
            main_navigation_vc = self.navigationController;
            root_vc = self.navigationController;
        }
        else
        {
            /* ipad */
            main_navigation_vc = [[self.splitViewController viewControllers] objectAtIndex:0];
            root_vc = self.splitViewController;
        }
        
        /* check appearance of modal barcode event vc and destroy it */
         if (([root_vc presentedViewController] != nil) && ([[root_vc presentedViewController] isKindOfClass:[UINavigationController class]] == YES))
         {
             [root_vc dismissViewControllerAnimated:NO completion:nil];
         }
             
        /* restore initial app state -> pop to root controller */
        if ([[main_navigation_vc viewControllers] count] > 1)
        {
            /* if there are more than 1 vc in navigation stack than
             main app vc isn't a top controller */

            [main_navigation_vc popToRootViewControllerAnimated:NO];
        }
        
        /* push to scanner table vc */
        zt_ScannersTableVC *scanners_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            scanners_vc = (zt_ScannersTableVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNERS_TABLE_VC"];
        }
        else
        {
            /* iphone */
            scanners_vc = (zt_ScannersTableVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNERS_TABLE_VC"];
        }

        [main_navigation_vc pushViewController:scanners_vc animated:NO];
        
        if (scanner_info != nil)
        {
            /* particular scanner is alive, either as active or available */
            if ([scanner_info isActive] == YES)
            {
                [scanners_vc showActiveScannerVC:[NSNumber numberWithInt:scannerID] aBarcodeView:barcode aAnimated:NO];
            }
        }
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
    return MENU_INDEX_TOTAL;
}

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

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        /* do not clear selection for ipad */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            //[cell setSelected:NO animated:YES];
        }
    }
    
    if (MENU_INDEX_CONNECTION == [indexPath row])
    {
        /* iphone - pop in navigation controller */
        /* ipad - show as master view for split view controller */
        
        zt_ScannersTableVC *scanners_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            scanners_vc = (zt_ScannersTableVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNERS_TABLE_VC"];
            
            if (scanners_vc != nil)
            {
                UINavigationController *master_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:0];
                [master_vc pushViewController:scanners_vc animated:YES];
                /* scanners_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }
        else
        {
            /* iphone */
            scanners_vc = (zt_ScannersTableVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_SCANNERS_TABLE_VC"];
            
            if (scanners_vc != nil)
            {
                [self.navigationController pushViewController:scanners_vc animated:YES];
                
                /* scanners_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }

    }
    else if (MENU_INDEX_APP_SETTINGS == [indexPath row])
    {
        /* iphone - pop in navigation controller */
        /* ipad - show as detail/master view for split view controller */
        
        zt_AppSettingsVC *settings_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            
            UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
            
            /* do NOT represent already presented VC */
            if (([[detail_vc viewControllers] count] > 0) && ([[[detail_vc viewControllers] objectAtIndex:0] isKindOfClass:[zt_AppSettingsVC class]] == YES))
            {
                return;
            }
            
            settings_vc = (zt_AppSettingsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_SETTINGS_VC"];
            if (settings_vc != nil)
            {
                [detail_vc setViewControllers:[NSArray arrayWithObjects:settings_vc, nil] animated:NO];
                
                //self.splitViewController.viewControllers = [NSArray arrayWithObjects:[self.splitViewController.viewControllers objectAtIndex:0], settings_vc, nil];
                /* settings_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }
        else
        {
            /* iphone */
            settings_vc = (zt_AppSettingsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_SETTINGS_VC"];
            if (settings_vc != nil)
            {
                [self.navigationController pushViewController:settings_vc animated:YES];
                
                /* settings_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }
    }
    else if (MENU_INDEX_CONNECTION_HELP == [indexPath row])
    {
        /* iphone - pop in navigation controller */
        /* ipad - show as detail view for split view controller */
        
        zt_ConnectionHelpVC *connectionHelpVc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            connectionHelpVc = (zt_ConnectionHelpVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_CONNECTION_HELP_VC"];
            
            if (connectionHelpVc != nil)
            {
                UINavigationController *master_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:0];
                [master_vc pushViewController:connectionHelpVc animated:YES];
            }
            
            zt_TabletNoticeVC *notice_vc = (zt_TabletNoticeVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_NOTICE_VC"];
            if (notice_vc != nil)
            {
                [notice_vc setNotice:@"Select device on left for instructions on connecting your scanner." withTitle:@"Instructions"];
                
                UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
                [detail_vc setViewControllers:[NSArray arrayWithObjects:notice_vc, nil] animated:NO];
                
            }
        }
        else
        {
            /* iphone */
            connectionHelpVc = (zt_ConnectionHelpVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_CONNECTION_HELP_VC"];
            if (connectionHelpVc != nil)
            {
                [self.navigationController pushViewController:connectionHelpVc animated:YES];
                /* connectionHelpVc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }
    }
    else if (MENU_INDEX_ABOUT == [indexPath row]) /* About Action */
    {
        /* iphone - pop in navigation controller */
        /* ipad - show as detail view for split view controller */
        
        zt_AboutAppVC *about_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            
            UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
            
            /* do NOT represent already presented VC */
            if (([[detail_vc viewControllers] count] > 0) && ([[[detail_vc viewControllers] objectAtIndex:0] isKindOfClass:[zt_AboutAppVC class]] == YES))
            {
                return;
            }
            
            about_vc = (zt_AboutAppVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_ABOUT_VC"];
            if (about_vc != nil)
            {
                [detail_vc setViewControllers:[NSArray arrayWithObjects:about_vc, nil] animated:NO];
                /* about_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }
        else
        {
            /* iphone */
            about_vc = (zt_AboutAppVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_ABOUT_VC"];
            if (about_vc != nil)
            {
                [self.navigationController pushViewController:about_vc animated:YES];
                /* about_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }
        }
    }
}

@end
