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
 *  Description:  ConnectionHelpCs4070View.h
 *
 *  Notes: UIView used to display CS4070 connection instructions
 *
 ******************************************************************************/

#import "ConnectionHelpCs4070View.h"
#import "BarcodeImage.h"

@interface zt_ConnectionHelpCs4070View()

@property (nonatomic,retain) IBOutlet UIImageView *resetFactoryDefaultsBarcodeImage;
@property (nonatomic,retain) IBOutlet UIImageView *bluetoothMfiSsiBarcodeImage;

@end

@implementation zt_ConnectionHelpCs4070View

- (void)drawRect:(CGRect)rect {

    [self.resetFactoryDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"L01" withHeight:self.resetFactoryDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
    
    [self.bluetoothMfiSsiBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"N051704" withHeight:self.bluetoothMfiSsiBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
}

@end
