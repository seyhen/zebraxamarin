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
 *  Description:  AppSettingsVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AppSettingsVC.h"
#import "AppSettingsKeys.h"
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "AppSettingsBackgroundVC.h"
#import "config.h"
#import "ScanToConnectVC.h"
#import "SbtSdkDefs.h"

// This flag is used to hide the "image event" and "video event" rows in the
// "background notifications" section of the settings table.
//
// Comment out this #define to show the "image event" and "video event" rows.
//
#define LOCAL_CONFIG_HIDE_IMAGE_VIDEO_EVENT_SWITCHES
#define SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG

typedef enum
{
    SECTION_COMM_MODE = 0,
    SECTION_EVENTS,
    SECTION_BG_MODE,
    SECTION_DETECTION,
    SECTION_STC,
    SECTION_TOTAL
    
} SettingsSection;

@interface zt_AppSettingsVC ()
{
    UIButton *restoreBtn;
}

@end

@implementation zt_AppSettingsVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_BTAddress = [[NSMutableString alloc] init];
        if ([[NSUserDefaults standardUserDefaults] stringForKey:BLADDRESS_SETTINGS_KEY] != nil) {
            [m_BTAddress setString:[[NSUserDefaults standardUserDefaults] stringForKey:BLADDRESS_SETTINGS_KEY]];
        }
    }
    return self;
}

- (void)dealloc
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    [m_cellOpModeBTLE release];
    [m_cellOpModeMFI release];
    [m_cellOpModeBoth release];
    [m_swScannerDetection release];
    [m_swNotificationAvailable release];
    [m_swNotificationActive release];
    [m_swNotificationBarcode release];
    [m_swNotificationImage release];
    [m_swNotificationVideo release];
    [restoreBtn release];
    [barcodeType release];
    [comProtocol release];
    [bluetoothAddress release];
    [m_stDfltsSwitch release];
    if (m_BTAddress != nil) {
        [m_BTAddress release];
    }
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:@"App Settings"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:bluetoothAddress];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setTitle:@"Back"];
    if (YES == [self checkBTAddress:[bluetoothAddress text] aFullAdress:YES])
    {
        [[zt_ScannerAppEngine sharedAppEngine] setBluetoothAddress:bluetoothAddress.text];
        [[NSUserDefaults standardUserDefaults] setObject:[bluetoothAddress text] forKey:BLADDRESS_SETTINGS_KEY];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:ZT_SCANNER_APP_NAME
                              message:@"Bluetooth address is not valid"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"App Settings"];
    [bluetoothAddress setText:m_BTAddress];
    
    [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryNone];
    [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryNone];
    [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryNone];
    
    [self displayCurrentOpmode];

    BOOL animation = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NO : YES);
    [m_swScannerDetection setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_SCANNER_DETECTION]  animated:animation];
    
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [m_swNotificationAvailable setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_AVAILABLE] animated:animation];
    [m_swNotificationActive setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_ACTIVE] animated:animation];
    [m_swNotificationBarcode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_BARCODE] animated:animation];
    [m_swNotificationImage setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_IMAGE] animated:animation];
    [m_swNotificationVideo setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_NOTIFICATION_VIDEO] animated:animation];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [m_swNotificationAvailable setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_AVAILABLE] animated:animation];
    [m_swNotificationActive setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_ACTIVE] animated:animation];
    [m_swNotificationBarcode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_BARCODE] animated:animation];
    [m_swNotificationImage setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_IMAGE] animated:animation];
    [m_swNotificationVideo setOn:[[NSUserDefaults standardUserDefaults] boolForKey:ZT_SETTING_EVENT_VIDEO] animated:animation];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self createListBox];
    
    [self resstoreSTCComponents];
    [m_stDfltsSwitch addTarget:self action:@selector(m_stDfltsSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    bluetoothAddress.delegate = self;
    [self addResetToDefaultsButton];
}


/* UITextFieldDelegate */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [bluetoothAddress resignFirstResponder];
    return YES;
}

- (void)m_stDfltsSwitchToggled:(UISwitch*)switchEle
{
    NSNumber *switchVal = [NSNumber numberWithBool:switchEle.on];
    [[NSUserDefaults standardUserDefaults] setObject:switchVal forKey:SETDEFAULTS_SETTINGS_KEY];
    [self setRestoreBtnStatus];
}

- (void)resstoreSTCComponents
{
    [self restoreBarcodeTypeStatus];
    [self restoreComProtocolPickerStatus];
    [self restoreSetDefaultsStatus];
    [self restoreBLAddressStatus];
}

- (void)createListBox
{
    NSMutableArray* comProtocolList = [[NSMutableArray alloc] init];
    [comProtocolList addObject:SSIMFI];
    [comProtocolList addObject:SSIBLE];
    [comProtocolList addObject:SSIHID];
    [comProtocolList addObject:NOPROTOCOL];
    
    NSMutableArray* barcodeList = [[NSMutableArray alloc] init];
    [barcodeList addObject:STC];
    [barcodeList addObject:LEGACY];
    
    comProtocolPicker = [[DownPicker alloc] initWithTextField:comProtocol withData:comProtocolList];
    [comProtocolPicker addTarget:self
                          action:@selector(dpSelectedComProtocol:)
                forControlEvents:UIControlEventValueChanged];
    barcodeTypePicker = [[DownPicker alloc] initWithTextField:barcodeType withData:barcodeList];
    [barcodeTypePicker addTarget:self
                          action:@selector(dpSelectedBracodeType:)
                forControlEvents:UIControlEventValueChanged];
}

-(void)dpSelectedComProtocol:(id)dp
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)(comProtocolPicker.selectedIndex)] forKey:COMPROTOCOL_SETTINGS_KEY];
    [self setRestoreBtnStatus];
}

-(void)dpSelectedBracodeType:(id)dp
{
    if ([barcodeTypePicker.text isEqualToString:LEGACY]) {
        comProtocolPicker.userInteractionEnabled = NO;
        comProtocol.userInteractionEnabled = NO;
        comProtocolPicker.selectedIndex = 3;
        didNoProtocolShown = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)(comProtocolPicker.selectedIndex)] forKey:COMPROTOCOL_SETTINGS_KEY];
    } else {
        comProtocolPicker.userInteractionEnabled = YES;
        comProtocol.userInteractionEnabled = YES;
        if (didNoProtocolShown) {
            comProtocolPicker.selectedIndex = 1;
            didNoProtocolShown = NO;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)(barcodeTypePicker.selectedIndex)] forKey:BARCODETYPE_SETTINGS_KEY];
    [self setRestoreBtnStatus];
}

- (void)restoreComProtocolPickerStatus
{
    NSNumber *savedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:COMPROTOCOL_SETTINGS_KEY];
    if (savedIndex != nil) {
        comProtocolPicker.selectedIndex = savedIndex.intValue;
    } else {
        comProtocolPicker.selectedIndex = 1;
    }
    [self setRestoreBtnStatus];
}

- (void)restoreBarcodeTypeStatus
{
    NSNumber *savedIndex = [[NSUserDefaults standardUserDefaults] objectForKey:BARCODETYPE_SETTINGS_KEY];
    if (savedIndex != nil) {
        barcodeTypePicker.selectedIndex = savedIndex.intValue;
    } else {
        barcodeTypePicker.selectedIndex = 0;
    }
    
    if (barcodeTypePicker.selectedIndex == 1) {
        didNoProtocolShown = YES;
    }
}

- (void)restoreSetDefaultsStatus
{
    NSNumber *savedNumber = [[NSUserDefaults standardUserDefaults] objectForKey:SETDEFAULTS_SETTINGS_KEY];
    if (savedNumber != nil) {
        if ([savedNumber boolValue] == NO) {
            [m_stDfltsSwitch setOn:NO];
        } else {
            [m_stDfltsSwitch setOn:YES];
        }
    } else {
        [m_stDfltsSwitch setOn:NO];
    }
}

- (void)restoreBLAddressStatus
{
    NSString *savedAddress = [[NSUserDefaults standardUserDefaults] stringForKey:BLADDRESS_SETTINGS_KEY];
    if (savedAddress != nil) {
        bluetoothAddress.text = savedAddress;
    } else {
        bluetoothAddress.text = @"00:00:00:00:00:00";
    }
}


- (void) addResetToDefaultsButton
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    
    self.tableView.tableHeaderView = headerView;
    restoreBtn = [[UIButton alloc] init];
    restoreBtn.backgroundColor = headerView.backgroundColor;
    [restoreBtn addTarget:self action:@selector(restoreToDefaultValues) forControlEvents:UIControlEventTouchUpInside];
    [restoreBtn setTitle:@" Reset Defaults " forState:UIControlStateNormal];
    [headerView addSubview:restoreBtn];
    
    restoreBtn.layer.cornerRadius = 3.0;
    restoreBtn.layer.borderWidth = 2.0;
    
    restoreBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *restoreBtnWidth = [NSLayoutConstraint constraintWithItem:restoreBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    
    NSLayoutConstraint *restoreBtnCenter = [NSLayoutConstraint constraintWithItem:restoreBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *restoreBtnConsTop = [NSLayoutConstraint constraintWithItem:restoreBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0];
    
    [headerView addConstraint:restoreBtnWidth];
    [headerView addConstraint:restoreBtnCenter];
    [headerView addConstraint:restoreBtnConsTop];
    [self setRestoreBtnStatus];
    
    [headerView release];
}

- (void) enableResetToDefaultsButton
{
    UIColor *enabledColor = [UIColor colorWithRed:(3.0/255.0f) green:(125.0/255.0f) blue:(179.0/255.0f) alpha:1.0];
    
    [restoreBtn setTitleColor:enabledColor forState:UIControlStateNormal];
    restoreBtn.layer.borderColor = [enabledColor CGColor];
    restoreBtn.enabled = YES;
    restoreBtn.userInteractionEnabled = YES;
}

- (void) disableResetToDefaultsButton
{
    UIColor *disabledColor = [UIColor lightGrayColor];
    
    [restoreBtn setTitleColor:disabledColor forState:UIControlStateNormal];
    restoreBtn.layer.borderColor = [disabledColor CGColor];
    restoreBtn.enabled = NO;
    restoreBtn.userInteractionEnabled = NO;
}

- (void)restoreToDefaultValues
{
    m_swScannerDetection.on = YES;
    m_swNotificationAvailable.on = YES;
    m_swNotificationActive.on = YES;
    m_swNotificationBarcode.on = NO;
    m_stDfltsSwitch.on = NO;
    
    [self setOpModeValue:SBT_OPMODE_ALL];
    [[zt_ScannerAppEngine sharedAppEngine] configureOperationalMode:SBT_OPMODE_ALL];
    
    [self switchScannerDetectionValueChanged:m_swScannerDetection];
    [self switchNotificationAvailableValueChanged:m_swNotificationAvailable];
    [self switchNotificationActiveValueChanged:m_swNotificationActive];
    [self switchNotificationBarcodeValueChanged:m_swNotificationBarcode];
    [self m_stDfltsSwitchToggled:m_stDfltsSwitch];
    
    comProtocolPicker.selectedIndex = 1;
    barcodeTypePicker.selectedIndex = 0;
    
    comProtocolPicker.userInteractionEnabled = YES;
    comProtocol.userInteractionEnabled = YES;
}

- (BOOL)didChangeDefaults
{
    if (m_swScannerDetection.on == YES && m_swNotificationAvailable.on == YES && m_swNotificationActive.on == YES && m_swNotificationBarcode.on == NO && m_cellOpModeBoth.accessoryType == UITableViewCellAccessoryCheckmark && m_stDfltsSwitch.on == NO && [comProtocol.text isEqualToString:SSIBLE] && [barcodeType.text isEqualToString:STC]) {
        return false;
    } else {
        return true;
    }
}

- (void)setRestoreBtnStatus
{
    if ([self didChangeDefaults]) {
        [self enableResetToDefaultsButton];
    } else {
        [self disableResetToDefaultsButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)opModeValueChanged:(NSInteger)opmode
{
    [[NSUserDefaults standardUserDefaults] setInteger:opmode forKey:ZT_SETTING_OPMODE];
    [self setRestoreBtnStatus];
}

- (void)displayCurrentOpmode
{
    NSInteger op_mode = [[NSUserDefaults standardUserDefaults] integerForKey:ZT_SETTING_OPMODE];
    [self setOpModeValue:op_mode];
}

- (void)setOpModeValue:(NSInteger)opmode
{
    switch (opmode)
    {
        case SBT_OPMODE_MFI:
            [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryCheckmark];
            [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryNone];
            break;
        case SBT_OPMODE_BTLE:
            [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryCheckmark];
            [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryNone];
            break;
        case SBT_OPMODE_ALL:
            [m_cellOpModeMFI setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBTLE setAccessoryType:UITableViewCellAccessoryNone];
            [m_cellOpModeBoth setAccessoryType:UITableViewCellAccessoryCheckmark];
            break;
    }
    
    if (opmode != [[NSUserDefaults standardUserDefaults] integerForKey:ZT_SETTING_OPMODE]) {
        [self opModeValueChanged:opmode];
    }
}

- (IBAction)switchScannerDetectionValueChanged:(id)sender
{
    BOOL value = [m_swScannerDetection isOn];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_SCANNER_DETECTION];
    [[zt_ScannerAppEngine sharedAppEngine] enableScannersDetection:value];
    [self setRestoreBtnStatus];
}


- (IBAction)switchNotificationAvailableValueChanged:(id)sender
{
    BOOL value = [m_swNotificationAvailable isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_AVAILABLE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_AVAILABLE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationAvailable:value];
    if (value == YES)
    {
        /* 
         to raise notifications that were missed due to disabled notification
         (see description in zt_ScannerAppEngine::raiseDeviceNotificationsIfNeeded)
        */
        [[zt_ScannerAppEngine sharedAppEngine] raiseDeviceNotificationsIfNeeded];
    }
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [self setRestoreBtnStatus];
}

- (IBAction)switchNotificationActiveValueChanged:(id)sender
{
    BOOL value = [m_swNotificationActive isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_ACTIVE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_ACTIVE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationActive:value];
    if (value == YES)
    {
        /*
         to raise notifications that were missed due to disabled notification
         (see description in zt_ScannerAppEngine::raiseDeviceNotificationsIfNeeded)
         */
        [[zt_ScannerAppEngine sharedAppEngine] raiseDeviceNotificationsIfNeeded];
    }
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [self setRestoreBtnStatus];
}

- (IBAction)switchNotificationBarcodeValueChanged:(id)sender
{
    BOOL value = [m_swNotificationBarcode isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_BARCODE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_BARCODE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationBarcode:value];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [self setRestoreBtnStatus];
}

- (IBAction)switchNotificationImageValueChanged:(id)sender
{
    BOOL value = [m_swNotificationImage isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_IMAGE];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_IMAGE];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationImage:value];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
}

- (IBAction)switchNotificationVideoValueChanged:(id)sender
{
    BOOL value = [m_swNotificationVideo isOn];
#ifdef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_NOTIFICATION_VIDEO];
#else /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:ZT_SETTING_EVENT_VIDEO];
    [[zt_ScannerAppEngine sharedAppEngine] configureNotificationVideo:value];
#endif /* SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG */
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
    // Return the number of rows in the section.
    switch (section)
    {
        case SECTION_COMM_MODE:
            return 3;
        case SECTION_DETECTION:
            return 1;
        case SECTION_EVENTS:
#ifdef LOCAL_CONFIG_HIDE_IMAGE_VIDEO_EVENT_SWITCHES
            return 3;
#else
            return 5;
#endif
        case SECTION_BG_MODE:
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
            return 1;
#else
            return 0;
#endif
        case SECTION_STC:
            return 5;
        default:
            return 0;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_COMM_MODE: /* opmode */
            return @"Communication mode";
        case SECTION_DETECTION: /* detection */
            return @"Scanner detection";
        case SECTION_EVENTS: /* events  */
            return @"Background Notifications";
        case SECTION_STC:
            return @"Scan To Connect";
        case SECTION_BG_MODE: /* background mode */
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
            return @"Background mode";
#else
            return nil;
#endif
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(section == SECTION_BG_MODE)
    {
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
        return [super tableView:tableView heightForHeaderInSection:section];
#else
        return 0.1;
#endif
        
    }
    else
    {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if(section == SECTION_BG_MODE)
    {
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
        return [super tableView:tableView heightForHeaderInSection:section];
#else
        return 0.1;
#endif
    }
    else
    {
        return [super tableView:tableView heightForFooterInSection:section];
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
    
    if ([indexPath section] == SECTION_COMM_MODE) /* op mode section */
    {
        /* TBD: set op mode for particular scanner */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell != nil)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            int op_mode = 0;
            if ([cell isEqual:m_cellOpModeMFI] == YES)
            {
                op_mode = SBT_OPMODE_MFI;
            }
            else if ([cell isEqual:m_cellOpModeBTLE] == YES)
            {
                op_mode = SBT_OPMODE_BTLE;
            }
            else if ([cell isEqual:m_cellOpModeBoth] == YES)
            {
                op_mode = SBT_OPMODE_ALL;
            }
            
            [self setOpModeValue:op_mode];
            [[zt_ScannerAppEngine sharedAppEngine] configureOperationalMode:op_mode];
        } 
        for (int idx = 0; idx < 3; idx++)
        {
            if (idx != [indexPath row])
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                if (cell != nil)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
    
#ifndef SST_CFG_SKIP_SDK_EVENTS_SUBSCRIBTION_CFG
    if ([indexPath section] == SECTION_BG_MODE)
    {
        if ([indexPath row] == 0)
        {
            /* Background notifications */
            zt_AppSettingsBackgroundVC *notifications_vc = nil;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                notifications_vc = (zt_AppSettingsBackgroundVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_SETTINGS_BACKGROUND_VC"];
            }
            else
            {
                /* iphone */
                notifications_vc = (zt_AppSettingsBackgroundVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_SETTINGS_BACKGROUND_VC"];
            }
            
            if (notifications_vc != nil)
            {
                [self.navigationController pushViewController:notifications_vc animated:YES];
                /* notifications_vc is autoreleased object returned by instantiateViewControllerWithIdentifier */
            }

        }
    }
#endif
    ScanToConnectVC *stcVC = nil;
    if ([indexPath section] == SECTION_STC) {
        if (indexPath.row == 4) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
            stcVC = (ScanToConnectVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"STC_VC"];
            } else {
                stcVC = (ScanToConnectVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"STC_VC_IPHONE"];
            }
        }
        if (stcVC != nil)
        {
            NSString *_str_bt = [bluetoothAddress text];
            if (YES == [self checkBTAddress:_str_bt aFullAdress:YES])
            {
                [[NSUserDefaults standardUserDefaults] setObject:_str_bt forKey:BLADDRESS_SETTINGS_KEY];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:ZT_SCANNER_APP_NAME
                                      message:@"Bluetooth address is not valid"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                if ([self.splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
                    [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModePrimaryHidden];
                }
            }
            stcVC.blAddress = bluetoothAddress.text;
            stcVC.barcodeType = [self getCurrentBarCodeType];
            stcVC.comProtocol = [self getCurrentcomProtocol];
            stcVC.setDefaultsStatus = [self setDefaultStatus];
            [self.navigationController pushViewController:stcVC animated:YES];
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //[cell setSelected:NO animated:YES];
    }
}

- (BOOL)checkBTAddress:(NSString*)address aFullAdress:(BOOL)full;
{
    BOOL _valid_address = NO;
    unsigned char _ch = 0;
    if (([address length] > 0) || ([address length] <= 18))
    {
        _valid_address = YES;
        for (int i = 0; i < [address length]; i++)
        {
            _ch = [address characterAtIndex:i];
            if (0 == ((i + 1) % 3))
            {
                if (_ch != ':')
                {
                    _valid_address = NO;
                    break;
                }
            }
            else
            {
                if ((_ch < 48) || ((_ch > 57) && (_ch < 65)) || (_ch > 70))
                {
                    _valid_address = NO;
                    break;
                }
            }
        }
    }
    
    if (YES == _valid_address)
    {
        if (YES == full)
        {
            if ([address length] != 17)
            {
                _valid_address = NO;
            }
        }
    }
    
    return _valid_address;
}

- (BOOL)checkBTAddressInput:(NSString*)address
{
    BOOL _valid_address_input = YES;
    unsigned char _ch = 0;
    for (int i = 0; i < [address length]; i++)
    {
        _ch = [address characterAtIndex:i];
        /* :, 0 .. 9, A .. F */
        if ((_ch < 48) || ((_ch > 58) && (_ch < 65)) || (_ch > 70))
        {
            _valid_address_input = NO;
            break;
        }
    }
    return _valid_address_input;
}

- (void)handleTextFieldChanged:(NSNotification *)notif
{
    NSMutableString *_input = [[NSMutableString alloc] init];
    [_input setString:[[bluetoothAddress text] uppercaseString]];
    
    if ([self checkBTAddressInput:_input] == YES)
    {
        [m_BTAddress setString:_input];
        if ([m_BTAddress isEqualToString:[bluetoothAddress text]] == NO)
        {
            [bluetoothAddress setText:m_BTAddress];
        }
    }
    else
    {
        /* restore previous one */
        [bluetoothAddress setText:m_BTAddress];
        /* clear undo stack as we have restored previous stack (i.e. user's action
         had no effect) */
        [[bluetoothAddress undoManager] removeAllActions];
    }
    
    [_input release];
    
    
}

- (BARCODE_TYPE)getCurrentBarCodeType
{
    switch (barcodeTypePicker.selectedIndex) {
        case 0:
            return BARCODE_TYPE_STC;
        case 1:
            return BARCODE_TYPE_LEGACY;
    }
}

- (STC_COM_PROTOCOL)getCurrentcomProtocol
{
    switch (comProtocolPicker.selectedIndex) {
        case 0:
            return STC_SSI_MFI;
        case 1:
            return STC_SSI_BLE;
        case 2:
            return SBT_SSI_HID;
        default:
            return NO_COM_PROTOCOL;
    }
}

- (SETDEFAULT_STATUS)setDefaultStatus
{
    if (m_stDfltsSwitch.isOn) {
        return SETDEFAULT_YES;
    } else {
        return SETDEFAULT_NO;
    }
}

@end
