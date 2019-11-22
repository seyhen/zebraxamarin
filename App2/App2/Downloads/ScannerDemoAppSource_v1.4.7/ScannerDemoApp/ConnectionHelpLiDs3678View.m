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
 *  Description:  ConnectionHelpLiDs3678View.h
 *
 *  Notes: UIView used to display LI/DS3678 connection instructions
 *
 ******************************************************************************/

#import "ConnectionHelpLiDs3678View.h"
#import "BarcodeImage.h"

@interface zt_ConnectionHelpLiDs3678View()

@property (nonatomic,retain) IBOutlet UIImageView *resetFactoryDefaultsBarcodeImage;
@property (nonatomic,retain) IBOutlet UIImageView *btleSsiBarcodeImage;

@end

@implementation zt_ConnectionHelpLiDs3678View

- (void)drawRect:(CGRect)rect {
    
    [self.resetFactoryDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"92" withHeight:self.resetFactoryDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
    
    [self.btleSsiBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"N017F17" withHeight:self.btleSsiBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
}

@end

