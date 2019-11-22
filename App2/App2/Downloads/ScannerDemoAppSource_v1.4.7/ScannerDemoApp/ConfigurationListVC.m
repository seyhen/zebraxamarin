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
 *  Description:  ConfigurationListVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ConfigurationListVC.h"
#import "ScannerConfiguration.h"
#import "ConfigurationSingleVC.h"

@interface zt_ConfigurationListVC ()

@end

@implementation zt_ConfigurationListVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_SelectedIndex = -1;
        
        m_SupportedConfigurations = [[NSMutableArray alloc] init];
        
        zt_ScannerConfiguration *cfg;
        
        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"MFi mode" withCode:@"N017F12"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];
        
        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"BTLE mode" withCode:@"N017F14"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];
        
        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"Set Factory Defaults" withCode:@"92"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];
        
        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"Battery Off" withCode:@"BATTOFF"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];
        
        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"Cradle Host" withCode:@"N017F0C"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"SPP Client" withCode:@"N017F0E"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"SPP Server" withCode:@"N017F0F"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"HID Server" withCode:@"N017F10"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"Low Beeper Volume" withCode:@"2050802"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"Medium Beeper Volume" withCode:@"2050801"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

        cfg = [[zt_ScannerConfiguration alloc] initWithName:@"High Beeper Volume" withCode:@"2050800"];
        [m_SupportedConfigurations addObject:cfg];
        [cfg release];

    }
    return self;
}

- (void)dealloc
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    if (m_SupportedConfigurations != nil)
    {
        [m_SupportedConfigurations removeAllObjects];
        [m_SupportedConfigurations release];
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"Scanner Configurations"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        /* ipad */
        /* for iPad only: we should select some row in master view to show smth in
         detail view of split view controller */
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            [[self tableView] selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            
            /* delegate event is not triggered when selecting row programatically */
            
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
    return [m_SupportedConfigurations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScannerConfigurationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[m_SupportedConfigurations objectAtIndex:[indexPath row]] getConfigurationName];
    
    return cell;
}

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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        /* iphone - clear all selections */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([indexPath row] == m_SelectedIndex)
        {
            /* do not represent already presented VC */
            return;
        }
    }
    
    m_SelectedIndex = [indexPath row];
    
    zt_ConfigurationSingleVC *cfg_single_vc = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        /* ipad */
        cfg_single_vc = (zt_ConfigurationSingleVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_CONFIGURATION_SINGLE_VC"];
    }
    else
    {
        /* iphone */
        cfg_single_vc = (zt_ConfigurationSingleVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_CONFIGURATION_SINGLE_VC"];
    }
    
    if (cfg_single_vc != nil)
    {
        [cfg_single_vc setConfiguration:[m_SupportedConfigurations objectAtIndex:[indexPath row]]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
            [detail_vc setViewControllers:[NSArray arrayWithObjects:cfg_single_vc, nil] animated:NO];
        }
        else
        {
            /* iphone */
            [self.navigationController pushViewController:cfg_single_vc animated:YES];
        }
        
        /* cfg_single_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
    }

}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
