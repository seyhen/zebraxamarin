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
 *  Description:  AppSettingsBackgroundVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AppSettingsBackgroundVC.h"
#import "AppSettingsKeys.h"

@interface zt_AppSettingsBackgroundVC ()

@end

@implementation zt_AppSettingsBackgroundVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    [m_swNotificationAvailable release];
    [m_swNotificationActive release];
    [m_swNotificationBarcode release];
    [m_swNotificationImage release];
    [m_swNotificationVideo release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"Notifications"];
    
    BOOL animation = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NO : YES);

    [m_swNotificationAvailable setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_AVAILABLE] animated:animation];
    [m_swNotificationActive setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_ACTIVE] animated:animation];
    [m_swNotificationBarcode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_BARCODE] animated:animation];
    [m_swNotificationImage setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_IMAGE] animated:animation];
    [m_swNotificationVideo setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_VIDEO] animated:animation];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)switchNotificationAvailableValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[m_swNotificationAvailable isOn] forKey:ZT_SETTING_NOTIFICATION_AVAILABLE];
}

- (IBAction)switchNotificationActiveValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[m_swNotificationActive isOn] forKey:ZT_SETTING_NOTIFICATION_ACTIVE];
}

- (IBAction)switchNotificationBarcodeValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[m_swNotificationBarcode isOn] forKey:ZT_SETTING_NOTIFICATION_BARCODE];
}

- (IBAction)switchNotificationImageValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[m_swNotificationImage isOn] forKey:ZT_SETTING_NOTIFICATION_IMAGE];
}

- (IBAction)switchNotificationVideoValueChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[m_swNotificationVideo isOn] forKey:ZT_SETTING_NOTIFICATION_VIDEO];
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
            return 5;
        default:
            return 0;
    }
    return 0;
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //[cell setSelected:NO animated:YES];
    }
}

@end
