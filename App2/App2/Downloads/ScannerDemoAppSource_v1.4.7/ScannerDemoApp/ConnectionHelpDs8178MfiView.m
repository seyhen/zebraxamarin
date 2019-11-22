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
 *  Description:  ConnectionHelpDs8178View.h
 *
 *  Notes: UIView used to display DS8178 MFi connection instructions
 *
 ******************************************************************************/

#import "ConnectionHelpDs8178MfiView.h"
#import "BarcodeImage.h"

@interface zt_ConnectionHelpDs8178MfiView()

@property (nonatomic,retain) IBOutlet UIImageView *resetFactoryDefaultsBarcodeImage;
@property (nonatomic,retain) IBOutlet UIImageView *bluetoothMfiSsiBarcodeImage;

@end

@implementation zt_ConnectionHelpDs8178MfiView

- (void)drawRect:(CGRect)rect {

    [self.resetFactoryDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"92" withHeight:self.resetFactoryDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
    
    [self.bluetoothMfiSsiBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"N017F13" withHeight:self.bluetoothMfiSsiBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
}

@end
