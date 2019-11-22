//
//  UpdateFirmwareVC.h
//  ScannerSDKApp
//
//  Created by pqj647 on 6/19/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "config.h"
#import "AlertView.h"
#import "ScannerAppEngine.h"

@protocol FWFilesTableDelegate;

@interface UpdateFirmwareVC : UIViewController <IScannerAppEngineFWUpdateEventsDelegate, FWFilesTableDelegate,UIWebViewDelegate> {
    IBOutlet UITextField *selectedFileTxt;
    int m_ScannerID;
    ZT_INFO_UPDATE_FW commandTYpe;
    zt_AlertView *activityView;
    
    IBOutlet UIProgressView *progressBar;
    IBOutlet UIButton *browsBtn;
    IBOutlet UIButton *updateBtn;
    IBOutlet UIButton *abortBtn;
    IBOutlet UILabel *percentageLbl;
    IBOutlet UIView *updateFWView;
    IBOutlet UIImageView *scannerImage;
    
    BOOL fwUpdateDidStop;
    NSString *selectedFWFilePath;
    
    IBOutlet UILabel *headerLbl;
    IBOutlet UILabel *fwNameLbl;
    IBOutlet UILabel *releasedDateLbl;
    IBOutlet UITextView *releaseNotesTextView;
    IBOutlet UIView *helpView;
    IBOutlet UIWebView *helpWebView;
    IBOutlet UIButton *helpViewCloseBtn;
    IBOutlet UIScrollView *helpScrollView;
    IBOutlet UIView *helpScrollSuperView;
    
    //plugin mismatch views
    IBOutlet UIView *pluginMisMatchView;
    IBOutlet UILabel *pluginMisMatchLbl;
    IBOutlet UIWebView *pluginMisMatchWebView;
    IBOutlet UIButton *pluginMisMatchBtn;
    IBOutlet UILabel *releaseNotesLbl;
    IBOutlet UIView *releaseNotesSuperView;
    IBOutlet UIScrollView *superScrollView;
    IBOutlet UIView *contentView;
    IBOutlet UILabel *fwUpdateViewTitle;
    
    NSString *modelNumber;
    NSString *fwVersion;
}


- (IBAction)closeHelpView:(id)sender;

- (IBAction)selectDatFile:(id)sender;
- (IBAction)updateFW:(id)sender;
- (IBAction)abortFWUpdate:(id)sender;
- (IBAction)pluginMisMatchOkClicked:(id)sender;

- (void)setScannerID:(int)currentScannerID;
- (void)setCommandType:(ZT_INFO_UPDATE_FW)type;

- (void)setSelectedFWFilePath:(NSString*)path;
- (NSString*)getSelectedFWFilePath;

@end
