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
 *  Description:  BeeperActionVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "BeeperActionVC.h"
#import "RMDAttributes.h"
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"
#import "config.h"

@interface zt_BeeperActionVC ()

@end

@implementation zt_BeeperActionVC

/* default cstr for storyboard */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        m_BeeperActionValues = [[NSMutableArray alloc] init];
        m_BeeperActionNames = [[NSMutableArray alloc] init];
        m_SelectedBeeperActionIndex = -1;
        m_ScannerModel = SBT_DEVMODEL_INVALID;
        m_ScannerID = SBT_SCANNER_ID_INVALID;
        
    }
    return self;
}

- (void)dealloc
{
    if (m_BeeperActionNames != nil)
    {
        [m_BeeperActionNames removeAllObjects];
        [m_BeeperActionNames release];
    }
    if (m_BeeperActionValues != nil)
    {
        [m_BeeperActionValues removeAllObjects];
        [m_BeeperActionValues release];
    }
    
    if (activityView != nil)
    {
        [activityView release];
    }
    
    [m_ActionPicker release];
    [m_btnBeep release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Beeper Actions"];
	// Do any additional setup after loading the view.
    
    activityView = [[zt_AlertView alloc]init];
    
    if (m_SelectedBeeperActionIndex == -1)
    {
        int middle = (int)([m_BeeperActionValues count] / 2);
        
        [m_ActionPicker selectRow:middle inComponent:0 animated:YES];
        m_SelectedBeeperActionIndex = middle;
    }
    
    [self.view removeConstraints:self.view.constraints];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_ActionPicker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_btnBeep attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20.0];
    [self.view addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_ActionPicker attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0];
    [self.view addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_ActionPicker attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20.0];
    [self.view addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_ActionPicker attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20.0];
    [self.view addConstraint:c4];
    
    CGFloat ui_constant = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.0 : 20.0);
    NSLayoutConstraint *c5 = [NSLayoutConstraint constraintWithItem:m_btnBeep attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:ui_constant];
    [self.view addConstraint:c5];
    
    NSLayoutConstraint *c6 = [NSLayoutConstraint constraintWithItem:m_btnBeep attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20.0];
    [self.view addConstraint:c6];
    
    NSLayoutConstraint *c7 = [NSLayoutConstraint constraintWithItem:m_btnBeep attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20.0];
    [self.view addConstraint:c7];
    
    NSLayoutConstraint *c8 = [NSLayoutConstraint constraintWithItem:m_btnBeep attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.0];
    [self.view addConstraint:c8];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (IBAction)btnBeepPressed:(id)sender
{
    if (m_SelectedBeeperActionIndex != -1)
    {
        NSNumber * action_val = (NSNumber*)[m_BeeperActionValues objectAtIndex:m_SelectedBeeperActionIndex];

        NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-int>%d</arg-int></cmdArgs></inArgs>", m_ScannerID, [action_val intValue]];
        
        // CS4070 firmware does not support SET ACTION commands to control beeper. Use SSI commands instead.
        if (m_ScannerModel == SBT_DEVMODEL_SSI_CS4070)
        {
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performBeeperControl:) withObject:action_val withString:nil];
        }
        else
        {
            [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performBeeperAction:) withObject:in_xml withString:nil];
        }
    }
}

- (void)setScannerID:(int)scanner_id
{
    m_ScannerID = scanner_id;
    
    m_ScannerModel = [[[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID] getScannerModel];
    
    // CS4070 firmware does not support SET ACTION commands to control beeper. Use SSI commands instead.
    if (m_ScannerModel == SBT_DEVMODEL_SSI_CS4070)
    {
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_HIGH_1]];
        [m_BeeperActionNames addObject:@"One high short beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_HIGH_2]];
        [m_BeeperActionNames addObject:@"Two high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_HIGH_3]];
        [m_BeeperActionNames addObject:@"Three high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_HIGH_4]];
        [m_BeeperActionNames addObject:@"Four high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_HIGH_5]];
        [m_BeeperActionNames addObject:@"Five high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_LOW_1]];
        [m_BeeperActionNames addObject:@"One low short beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_LOW_2]];
        [m_BeeperActionNames addObject:@"Two low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_LOW_3]];
        [m_BeeperActionNames addObject:@"Three low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_LOW_4]];
        [m_BeeperActionNames addObject:@"Four low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SHORT_LOW_5]];
        [m_BeeperActionNames addObject:@"Five low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_HIGH_1]];
        [m_BeeperActionNames addObject:@"One high long beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_HIGH_2]];
        [m_BeeperActionNames addObject:@"Two high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_HIGH_3]];
        [m_BeeperActionNames addObject:@"Three high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_HIGH_4]];
        [m_BeeperActionNames addObject:@"Four high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_HIGH_5]];
        [m_BeeperActionNames addObject:@"Five high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_LOW_1]];
        [m_BeeperActionNames addObject:@"One low long beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_LOW_2]];
        [m_BeeperActionNames addObject:@"Two low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_LOW_3]];
        [m_BeeperActionNames addObject:@"Three low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_LOW_4]];
        [m_BeeperActionNames addObject:@"Four low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_LONG_LOW_5]];
        [m_BeeperActionNames addObject:@"Five low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_FAST_WARBLE]];
        [m_BeeperActionNames addObject:@"Fast warble beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_SLOW_WARBLE]];
        [m_BeeperActionNames addObject:@"Slow warble beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_MIX1_HIGH_LOW]];
        [m_BeeperActionNames addObject:@"High-low beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_MIX2_LOW_HIGH]];
        [m_BeeperActionNames addObject:@"Low-high beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_MIX3_HIGH_LOW_HIGH]];
        [m_BeeperActionNames addObject:@"High-low-high beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:SBT_BEEPCODE_MIX4_LOW_HIGH_LOW]];
        [m_BeeperActionNames addObject:@"Low-high-low beep"];
    }
    else
    {
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_SHORT_BEEP_1]];
        [m_BeeperActionNames addObject:@"One high short beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_SHORT_BEEP_2]];
        [m_BeeperActionNames addObject:@"Two high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_SHORT_BEEP_3]];
        [m_BeeperActionNames addObject:@"Three high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_SHORT_BEEP_4]];
        [m_BeeperActionNames addObject:@"Four high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_SHORT_BEEP_5]];
        [m_BeeperActionNames addObject:@"Five high short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_SHORT_BEEP_1]];
        [m_BeeperActionNames addObject:@"One low short beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_SHORT_BEEP_2]];
        [m_BeeperActionNames addObject:@"Two low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_SHORT_BEEP_3]];
        [m_BeeperActionNames addObject:@"Three low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_SHORT_BEEP_4]];
        [m_BeeperActionNames addObject:@"Four low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_SHORT_BEEP_5]];
        [m_BeeperActionNames addObject:@"Five low short beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_LONG_BEEP_1]];
        [m_BeeperActionNames addObject:@"One high long beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_LONG_BEEP_2]];
        [m_BeeperActionNames addObject:@"Two high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_LONG_BEEP_3]];
        [m_BeeperActionNames addObject:@"Three high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_LONG_BEEP_4]];
        [m_BeeperActionNames addObject:@"Four high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_LONG_BEEP_5]];
        [m_BeeperActionNames addObject:@"Five high long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_LONG_BEEP_1]];
        [m_BeeperActionNames addObject:@"One low long beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_LONG_BEEP_2]];
        [m_BeeperActionNames addObject:@"Two low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_LONG_BEEP_3]];
        [m_BeeperActionNames addObject:@"Three low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_LONG_BEEP_4]];
        [m_BeeperActionNames addObject:@"Four low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_LONG_BEEP_5]];
        [m_BeeperActionNames addObject:@"Five low long beeps"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_FAST_WARBLE_BEEP]];
        [m_BeeperActionNames addObject:@"Fast warble beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_SLOW_WARBLE_BEEP]];
        [m_BeeperActionNames addObject:@"Slow warble beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_LOW_BEEP]];
        [m_BeeperActionNames addObject:@"High-low beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_HIGH_BEEP]];
        [m_BeeperActionNames addObject:@"Low-high beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_HIGH_LOW_HIGH_BEEP]];
        [m_BeeperActionNames addObject:@"High-low-high beep"];
        [m_BeeperActionValues addObject:[NSNumber numberWithInt:RMD_ATTR_VALUE_ACTION_LOW_HIGH_LOW_BEEP]];
        [m_BeeperActionNames addObject:@"Low-high-low beep"];
    }
}

- (void)performBeeperAction:(NSString*)param
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_SET_ACTION aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
            ^{
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:ZT_SCANNER_APP_NAME
                                      message:@"Cannot perform beeper action"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        );
    }
}

- (void)performBeeperControl:(NSNumber*)beepCode
{
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] beepControl:[beepCode intValue] forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot perform beeper action"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                           [alert release];
                       }
                       );
    }
}

/* ###################################################################### */
/* ########## UIPickerViewDataSource Protocol implementation ############ */
/* ###################################################################### */

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [m_BeeperActionNames count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return (NSString*)[m_BeeperActionNames objectAtIndex:row];
}

/* ###################################################################### */
/* ########## UIPickerViewDelegate Protocol implementation ############## */
/* ###################################################################### */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    m_SelectedBeeperActionIndex = row;
}
@end
