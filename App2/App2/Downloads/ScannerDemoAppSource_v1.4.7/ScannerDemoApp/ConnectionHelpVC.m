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
 *  Description:  ConnectionHelpVC.h
 *
 *  Notes: Table View controller used to navigate connection help screen
 *         for supported devices.
 *
 ******************************************************************************/

#import "ConnectionHelpVC.h"
#import "ConnectionInstructionsVC.h"

typedef enum
{
    INSTR_INDEX_CS4070 = 0,
    INSTR_INDEX_RFD8500,
    INSTR_INDEX_LI3678,
    INSTR_INDEX_DS8178,
    INSTR_INDEX_DS2278,
    INSTR_INDEX_SET_DEFAULTS,
    INSTR_TOTAL
    
} Instruction_Index;

@interface zt_ConnectionHelpVC ()

@end

@implementation zt_ConnectionHelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [back autorelease];
    self.navigationItem.backBarButtonItem = back;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return INSTR_TOTAL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] != INSTR_INDEX_DS8178)
    {
        zt_ConnectionInstructionsVC *connectionInstructions = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            connectionInstructions = (zt_ConnectionInstructionsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_CONNECTION_INSTRUCTIONS_VC"];
        }
        else
        {
            /* iphone */
            connectionInstructions = (zt_ConnectionInstructionsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_CONNECTION_INSTRUCTIONS_VC"];
        }
        
        if ([indexPath row] == INSTR_INDEX_CS4070)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_CS4070];
            
        }
        else if ([indexPath row] == INSTR_INDEX_RFD8500)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_RFD8500];
        }
        else if ([indexPath row] == INSTR_INDEX_LI3678)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_LI_DS3678];
        }
        else if ([indexPath row] == INSTR_INDEX_DS2278)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_DS2278];
        }
        else if ([indexPath row] == INSTR_INDEX_SET_DEFAULTS)
        {
            [connectionInstructions loadInstructionsFor:INSTRUCTION_SET_DEFAULTS];
        }
        
        if (connectionInstructions != nil)
        {
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                /* ipad */
                UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
                
                [detail_vc setViewControllers:[NSArray arrayWithObjects:connectionInstructions, nil] animated:NO];
            }
            else
            {
                [self.navigationController pushViewController:connectionInstructions animated:YES];
            }
        }
    }
}


@end
