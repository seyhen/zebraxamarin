/******************************************************************************
 *
 *       Copyright Motorola Solutions, Inc. 2014
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Motorola Confidential Proprietary Information.
 *
 *
 *  Description:  ScanToConnectVC.h
 *
 *  Notes:
 *
 ******************************************************************************/
#import "SbtSdkDefs.h"
#import "ScannerAppEngine.h"

@protocol BLAddressStatus <NSObject>

- (void)notifyNoBLAddressStatus;

@end

@interface ScanToConnectVC : UIViewController <IScannerAppEngineDevConnectionsDelegate>
{
    IBOutlet UIImageView *m_imgBarcode;
    CGFloat m_initialImageWidth;
    
    UITapGestureRecognizer *m_TapGestureRecognizer;
    NSLayoutConstraint* m_cstImageWidth;
    NSLayoutConstraint* m_cstImageCenterY;
    NSLayoutConstraint* m_cstInfoNoticeTop;
    NSLayoutConstraint* m_cstUpInfoNoticeHeight;
    NSLayoutConstraint* m_cstDownInfoNoticeHeight;
    UIPinchGestureRecognizer* m_PinchGectureRecognizer;
}

@property BARCODE_TYPE barcodeType;
@property STC_COM_PROTOCOL comProtocol;
@property SETDEFAULT_STATUS setDefaultsStatus;
@property NSString *blAddress;


- (void)drawConnectionBarcode;
- (void)configureAppearance;
- (void)pinchGestureActivated;
- (void) tapGestureActivated;

- (void)setPrintButtonVisiblity:(BOOL)status;
- (IBAction)invokePrintDialog:(id)sender;

@end
