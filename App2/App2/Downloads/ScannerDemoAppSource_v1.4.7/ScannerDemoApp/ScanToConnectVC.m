/******************************************************************************
 *
 *       Copyright Motorola Solutions, Inc. 2014
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Motorola Confidential Proprietary Information.
 *
 *
 *  Description:  ScanToConnectVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "ScanToConnectVC.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>
#import "config.h"
#import "AppSettingsVC.h"
#import "ScannerAppEngine.h"

@interface ScanToConnectVC ()

@end

@implementation ScanToConnectVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [[zt_ScannerAppEngine sharedAppEngine] addDevConnectionsDelegate:self];
    return self;
}

- (void)backPressed:(id)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animate
{
    [super viewWillAppear:animate];
    [self drawConnectionBarcode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        zt_AppSettingsVC *settings_vc = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            /* ipad */
            
            UINavigationController *detail_vc = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:1];
            
            if ([self.splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
                [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
            }
            
            settings_vc = (zt_AppSettingsVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_APP_SETTINGS_VC"];
            if (settings_vc != nil)
            {
                [detail_vc setViewControllers:[NSArray arrayWithObjects:settings_vc, nil] animated:NO];
            }
        }
    }
    [super viewWillDisappear:animated];
}

- (void)drawConnectionBarcode
{
    [[zt_ScannerAppEngine sharedAppEngine] setBluetoothAddress:self.blAddress];
    UIImage *generatedBarcodeImage = [[zt_ScannerAppEngine sharedAppEngine] sbtSTCPairingBarcode:self.barcodeType withComProtocol:self.comProtocol withSetDefaultStatus:self.setDefaultsStatus withBTAddress:self.blAddress withImageFrame:m_imgBarcode.frame];
    
    [m_imgBarcode setImage:generatedBarcodeImage];
}

#pragma mark - Flipside View

- (NSMutableAttributedString *)plainStringToAttributedUnits:(NSString *)string;
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    UIFont *smallFont = [UIFont systemFontOfSize:9.0f];
    [attString beginEditing];
    [attString addAttribute:NSFontAttributeName value:(font) range:NSMakeRange(0, 1)];
    [attString addAttribute:NSFontAttributeName value:(smallFont) range:NSMakeRange(1, 2)];
    [attString addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(1, 2)];
    [attString addAttribute:(NSString*)kCTForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 1)];
    [attString endEditing];
    return attString;
}

/* ###################################################################### */
/* ########## IScannerAppEngineDevConnectionsDelegate Protocol implementation ## */
/* ###################################################################### */
- (BOOL)scannerHasAppeared:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasDisappeared:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}

- (BOOL)scannerHasConnected:(int)scannerID
{
    // set autoReconnected flag enabled, when scanner is connected via STC
    [[zt_ScannerAppEngine sharedAppEngine] setAutoReconnectOptionAfterScannerConnected:scannerID];
    [self.navigationController popViewControllerAnimated:YES];
    return YES; /* we have processed the notification */
    
    
}

- (BOOL)scannerHasDisconnected:(int)scannerID
{
    /* does not matter */
    return NO; /* we have not processed the notification */
}


@end
