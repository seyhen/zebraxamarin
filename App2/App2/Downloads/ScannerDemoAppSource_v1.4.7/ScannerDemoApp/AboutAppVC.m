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
 *  Description:  AboutAppVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AboutAppVC.h"
#import "config.h"
#import "ScannerAppEngine.h"

@interface zt_AboutAppVC ()

@end

@implementation zt_AboutAppVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [m_lblVersion release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:@"About"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:m_lblVersion attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:60.0];
        [self.view addConstraint:c1];
        
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:m_lblVersion attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20.0];
        [self.view addConstraint:c2];
        
        NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:m_lblVersion attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20.0];
        [self.view addConstraint:c3];
        
        NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:m_lblVersion attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0];
        [self.view addConstraint:c4];
        
        NSLayoutConstraint *c5 = [NSLayoutConstraint constraintWithItem:m_lblVersion attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.2 constant:0.0];
        [self.view addConstraint:c5];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [m_lblVersion setText:[NSString stringWithFormat:@"%@ v.%@\n%@ v.%@\n\nCopyright %@ %@", ZT_INFO_SCANNER_APP_NAME, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], ZT_INFO_SCANNER_SDK_NAME, [[zt_ScannerAppEngine sharedAppEngine] getSDKVersion],  ZT_INFO_COPYRIGHT_YEAR, ZT_INFO_COPYRIGHT_TEXT]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
