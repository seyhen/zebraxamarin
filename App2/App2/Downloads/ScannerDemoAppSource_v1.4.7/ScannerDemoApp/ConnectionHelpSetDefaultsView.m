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
 *  Description:  ConnectionHelpSetDefaultsView.h
 *
 *  Notes: UIView used to display Set Defaults instructions
 *
 ******************************************************************************/

#import "ConnectionHelpSetDefaultsView.h"
#import "BarcodeImage.h"

@interface zt_ConnectionHelpSetDefaultsView()

@property (nonatomic,retain) IBOutlet UIImageView *setDefaultsBarcodeImage;

@end

@implementation zt_ConnectionHelpSetDefaultsView

- (void)drawRect:(CGRect)rect {

    [self.setDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"91" withHeight:self.setDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
}

@end
