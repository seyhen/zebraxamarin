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

#import "ConnectionHelpDs8178.h"
#import "ConnectionInstructionsVC.h"

typedef enum
{
    INSTR_INDEX_BTLE = 0,
    INSTR_INDEX_MFI,
    INSTR_TOTAL
    
} Instruction_Index;

@interface zt_ConnectionHelpDs8178VC ()

@end

@implementation zt_ConnectionHelpDs8178VC

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

- (void) viewWillAppear:(BOOL)animated
{
    [self setTitle:@"Pair DS8178"];
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
    
    if ([indexPath row] == INSTR_INDEX_BTLE)
    {
        [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_DS8178_BTLE];
        
    }
    else if ([indexPath row] == INSTR_INDEX_MFI)
    {
        [connectionInstructions loadInstructionsFor:INSTRUCTION_PAIR_DS8178_MFI];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
