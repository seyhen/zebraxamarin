//
//  UpdateFirmwareVC.m
//  ScannerSDKApp
//
//  Created by pqj647 on 6/19/16.
//  Copyright © 2016 Alexei Igumnov. All rights reserved.
//

#import "UpdateFirmwareVC.h"
#import "SbtSdkDefs.h"
#import "FWFilesTableVC.h"
#import "AppSettingsKeys.h"
#import "FWUpdateModel.h"
#import "PFWModelContentReader.h"
#import "PluginFileContentReader.h"
#import "RMDAttributes.h"
#import "DGActivityIndicatorView.h"
#import "ScannerAppEngine.h"
#import "ActiveScannerVC.h"
#import "ConnectionManager.h"
#import "ScannersTableVC.h"
#import "TabletNoticeVC.h"
#import "ScannerAppVC.h"

static BOOL isFWUpdatingDAT = NO;
static BOOL isFWUpdatingPLUGIN = NO;
static float fwUpdateAmount = 0.0f;
DGActivityIndicatorView *activityIndicatorView;


@interface UpdateFirmwareVC ()
{
    NSLayoutConstraint *scrollViewBottomInset;
    NSLayoutConstraint *webViewHeightConstraint;
    BOOL fwUpdateDidAbort;
    UIView *temporyView;
}

@end

@implementation UpdateFirmwareVC

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [[zt_ScannerAppEngine sharedAppEngine] addFWUpdateEventsDelegate:self];
    }
    
    return self;
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    fwUpdateAmount = progressBar.progress;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getAvailableFWFile];
    updateFWView.layer.borderColor = [UIColor blackColor].CGColor;
    updateFWView.layer.borderWidth = 2.0f;
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
    fwUpdateDidAbort = NO;
}

- (void)dealloc
{
    [[zt_ScannerAppEngine sharedAppEngine] removeFWUpdateEventsDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideFWUpdateView];
    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
}

- (void)orientationChanged:(NSNotification *)notification
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)  {
        [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    
    [helpWebView loadHTMLString:[self getHelpString] baseURL:nil];
    helpWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    [pluginMisMatchWebView loadHTMLString:[self getPluginMisMatchString] baseURL:nil];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation
{
    [temporyView setNeedsLayout];
    [temporyView setNeedsDisplay];
    float bottomOffset = 50.0;
    float height = 300;
    bottomOffset = (self.view.frame.size.height-helpScrollSuperView.frame.size.height)/2;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                height = 300;
            }
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            height = 210;
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
    
    if (webViewHeightConstraint != nil) {
        [self.view removeConstraint:webViewHeightConstraint];
    }
    webViewHeightConstraint = [NSLayoutConstraint constraintWithItem:helpScrollSuperView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    
    [self.view addConstraint:webViewHeightConstraint];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
     
     
    if (scrollViewBottomInset != nil) {
        [self.view removeConstraint:scrollViewBottomInset];
    }
    scrollViewBottomInset = [NSLayoutConstraint constraintWithItem:helpScrollSuperView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-bottomOffset];
    [self.view addConstraint:scrollViewBottomInset];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
}

+(UIColor*)getAppColor:(ZT_BG_COLOURS)clr
{
    switch (clr) {
        case BG_COLOUR_BLUE:
            return UIColorFromRGB(0x007CB0);
            break;
        case BG_COLOUR_YELLOW:
            return UIColorFromRGB(0xFFD200);
            break;
        case BG_COLOUR_FONT_COLOUR:
            return UIColorFromRGB(0x333D47);
            break;
        case BG_COLOUR_DARK_GRAY:
            return UIColorFromRGB(0x333D47);
            break;
        case BG_COLOUR_MEDIUM_GRAY:
            return UIColorFromRGB(0x7E868C);
            break;
        case BG_COLOUR_LIGHT_GRAY:
            return UIColorFromRGB(0xDBD8D6);
            break;
        case BG_COLOUR_TBL_LOW_GRAY:
            return UIColorFromRGB(0xDBD9D6);
            break;
        case BG_COLOUR_WHITE:
            return UIColorFromRGB(0xFFFFFF);
            break;
        case BG_COLOUR_INACTIVE_BACKGROUND:
            return UIColorFromRGB(0xF2F2F2);
            break;
        case BG_COLOUR_INACTIVE_TEXT:
            return UIColorFromRGB(0x7E868C);
            break;
        case BG_COLOUR_DEFAULT_BTN_CLR:
            return [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    superScrollView.contentSize=CGSizeMake(320,758);
    superScrollView.contentInset=UIEdgeInsetsMake(1.0,0.0,140.0,0.0);
    
    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
    dispatch_async(dispatch_get_main_queue(), ^{
        updateBtn.hidden =  YES;
    });
    [self removeActivityIndicatorForReebooting];
    activityView = [[zt_AlertView alloc]init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)  {
        [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    UIImage *image = [[UIImage imageNamed:@"help"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(clickRightBtn:)];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem = rightButton;
    // Do any additional setup after loading the view.
    [self adjustHelpViewVisibility:YES];
    modelNumber = nil;
    [self adjustPluginVisibility:YES];
    [self adjustViewVisibilityForPluginMisMatchView:NO];
    [self setBorders];
    //[self setBackgroundColoursAndBtnColour];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getScannerInfo];
    });
    updateBtn.layer.cornerRadius = 3.0;
    updateBtn.layer.borderWidth = 2.0;
    
    headerLbl.textAlignment = NSTextAlignmentCenter;
    id<PFWModelContentReader> contentReader = [[PluginFileContentReader alloc] init];
    [activityView show:self.view];
    [contentReader readPluginFileData:^(FWUpdateModel *model) {
        CFTimeInterval startTime = CACurrentMediaTime();
        CFTimeInterval elapsedTime = 0;
        while (modelNumber == nil && elapsedTime < 20) {
            [NSThread sleepForTimeInterval:0.1];
            elapsedTime = CACurrentMediaTime() - startTime;
        }
        NSArray *supportedModelArray = model.supportedModels;
        BOOL isPluginMatcing = NO;
        for (NSString *scannerName in supportedModelArray) {
            if ([scannerName isEqualToString:modelNumber]) {
                isPluginMatcing = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateBtn.hidden =  NO;
                });
                if (isPluginMatcing == YES) {
                    break;
                }
            }
        }
        
        if (isPluginMatcing == NO) {
            //check for dat files now
            NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *dwnLoad = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
            //first look for plugins
            NSArray *datFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:dwnLoad];
            if (datFileArray != nil && datFileArray.count>0) {
                [self setCommandType:ZT_INFO_UPDATE_FROM_DAT];
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateBtn.hidden =  NO;
                });
            } else {
                [self adjustPluginVisibility:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityView hide];
                });
                return;
            }
        } else {
            [self setCommandType:ZT_INFO_UPDATE_FROM_PLUGIN];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            CFTimeInterval startTime = CACurrentMediaTime();
            CFTimeInterval elapsedTime = 0;
            while (model.releaseNotes == nil && fwVersion == nil && elapsedTime < 10) {
                [NSThread sleepForTimeInterval:0.1];
                elapsedTime = CACurrentMediaTime() - startTime;
            }
            
            fwNameLbl.text = [NSString stringWithFormat:@"%@ %@", @"From:", fwVersion];
            [fwNameLbl.superview bringSubviewToFront:fwNameLbl];
            updateBtn.hidden =  NO;
            [releaseNotesTextView setText:model.releaseNotes];
            [headerLbl setText:model.plugFamily];
            [releasedDateLbl setText:[self processReleasedDateLblString:model.plugInRev withDate:model.releasedDate withFWName:model.firmwareNameArray]];
            scannerImage.image = [UIImage imageWithData:model.imgData];
            [releaseNotesTextView.superview bringSubviewToFront:releaseNotesTextView];
            [activityView hide];
            [self setBackgroundColoursAndBtnColour];
        });
    }];
    
    helpScrollView.contentSize = CGSizeMake(helpScrollView.frame.size.width, 300);
    helpScrollView.pagingEnabled = YES;
    
    superScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 300);
    
    pluginMisMatchWebView.opaque = NO;
    pluginMisMatchWebView.backgroundColor = [UIColor clearColor];
    [self setElementTitles];
    helpWebView.delegate = self;
}

- (void)setElementTitles
{
    fwUpdateViewTitle.text = ZT_UPDATE_FW_VIEW_TITLE_UPDATING;
}

- (void)setBorders
{
    dispatch_async(dispatch_get_main_queue(), ^{
        helpScrollSuperView.layer.borderColor = [UIColor blackColor].CGColor;
        helpScrollSuperView.layer.borderWidth = 2.0f;
        updateFWView.layer.borderColor = [UIColor blackColor].CGColor;
        updateFWView.layer.borderWidth = 2.0f;
        pluginMisMatchView.layer.borderColor = [UIColor blackColor].CGColor;
        pluginMisMatchView.layer.borderWidth = 2.0f;
    });
}

- (void)setBackgroundColoursAndBtnColour
{
    dispatch_async(dispatch_get_main_queue(), ^{
        releaseNotesTextView.backgroundColor = [UpdateFirmwareVC getAppColor:BG_COLOUR_LIGHT_GRAY];
        [updateBtn setTitleColor:[UpdateFirmwareVC getAppColor:BG_COLOUR_WHITE] forState:UIControlStateNormal];
        helpScrollSuperView.backgroundColor = [UpdateFirmwareVC getAppColor:BG_COLOUR_WHITE];
        
        if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
            [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
    
            NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
            zt_TabletNoticeVC *tableNoticeVC = nil;
            zt_ScannersTableVC *tableVC = nil;
            UpdateFirmwareVC *updateFWVC = nil;
            zt_ScannerAppVC *scannerAppVC = nil;
            for(UIViewController *vc in navigationArray) {
                if ([vc isKindOfClass:[zt_ScannersTableVC class]] ) {
                    tableVC = vc;
                } else if ([vc isKindOfClass:[UpdateFirmwareVC class]] ) {
                    updateFWVC = vc;
                }
                else if ([vc isKindOfClass:[zt_TabletNoticeVC class]] ) {
                    tableNoticeVC = vc;
                }
                else if ([vc isKindOfClass:[zt_ScannerAppVC class]] ) {
                    scannerAppVC = vc;
                }
            }
           
            dispatch_async(dispatch_get_main_queue(), ^{
                updateBtn.hidden =  NO;
                updateBtn.backgroundColor = [UIColor greenColor];
                [updateBtn setTitle:ZT_UPDATE_FW_BTN_TITLE_UPDATED forState:UIControlStateNormal];
                updateBtn.userInteractionEnabled = NO;
            });
            zt_ActiveScannerVC *active_vc = nil;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                active_vc = (zt_ActiveScannerVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard-iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ACTIVE_SCANNER_VC"];
            }
            else
            {
                active_vc = (zt_ActiveScannerVC*)[[UIStoryboard storyboardWithName:@"ScannerDemoAppStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ID_ACTIVE_SCANNER_VC"];
            }
            
            if (active_vc != nil)
            {
                [active_vc setScannerID:[[ConnectionManager sharedConnectionManager] getConnectedScannerId]];
                [active_vc showSettingsPage];
                
            }
            
            [navigationArray removeAllObjects];
            if (scannerAppVC != nil) {
                [navigationArray addObject:scannerAppVC];
            }
            if (tableVC != nil) {
                [navigationArray addObject:tableVC];
            } else if (tableNoticeVC != nil) {
                [navigationArray addObject:tableNoticeVC];
            }
            [navigationArray addObject:active_vc];
            [navigationArray addObject:updateFWVC];
            self.navigationController.viewControllers = navigationArray;
            fwNameLbl.text = @"";
        } else {
            [updateBtn setTitle:ZT_UPDATE_FW_BTN_TITLE forState:UIControlStateNormal];
            updateBtn.backgroundColor = [UpdateFirmwareVC getAppColor:BG_COLOUR_BLUE];
            updateBtn.userInteractionEnabled = YES;
        }
    });
}

- (void)clickRightBtn:(id)btn
{
    [self adjustHelpViewVisibility:NO];
    [helpWebView.superview bringSubviewToFront:helpWebView];
    [helpWebView loadHTMLString:[self getHelpString] baseURL:nil];
}

- (void)adjustHelpViewVisibility:(BOOL)isVisible
{
    dispatch_async(dispatch_get_main_queue(), ^{
        helpView.hidden = isVisible;
        helpWebView.hidden = isVisible;
        helpViewCloseBtn.hidden = isVisible;
        helpScrollView.hidden = isVisible;
        helpScrollSuperView.hidden = isVisible;
        
        if (isVisible == NO) {
            [helpWebView.superview bringSubviewToFront:helpWebView];
            [helpWebView.superview bringSubviewToFront:helpWebView];
            [helpViewCloseBtn.superview bringSubviewToFront:helpViewCloseBtn];
            [helpScrollView.superview bringSubviewToFront:helpScrollView];
            [helpScrollSuperView.superview bringSubviewToFront:helpScrollSuperView];
        }
    });
}

- (void)adjustPluginVisibility:(BOOL)isVisible
{
    dispatch_async(dispatch_get_main_queue(), ^{
        pluginMisMatchView.hidden = isVisible;
        pluginMisMatchLbl.hidden = isVisible;
        pluginMisMatchWebView.hidden = isVisible;
        pluginMisMatchBtn.hidden = isVisible;
        
        if (isVisible == NO) {
            [pluginMisMatchView.superview bringSubviewToFront:pluginMisMatchView];
            [pluginMisMatchLbl.superview bringSubviewToFront:pluginMisMatchLbl];
            [pluginMisMatchWebView.superview bringSubviewToFront:pluginMisMatchWebView];
            [pluginMisMatchBtn.superview bringSubviewToFront:pluginMisMatchBtn];
            if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
                [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
            }
            [pluginMisMatchWebView loadHTMLString:[self getPluginMisMatchString] baseURL:nil];
            
            //make other views disappear
            [self adjustViewVisibilityForPluginMisMatchView:YES];
        }
    });
}

- (void)adjustViewVisibilityForPluginMisMatchView:(BOOL)visibilityStatus
{
    updateBtn.hidden = visibilityStatus;
    releaseNotesTextView.hidden = visibilityStatus;
    releaseNotesSuperView.hidden = visibilityStatus;
    fwNameLbl.hidden = visibilityStatus;
    releasedDateLbl.hidden = visibilityStatus;
    releaseNotesLbl.hidden = visibilityStatus;
}

- (void)getScannerInfo {
    NSString *in_xml = nil;
    /**
     Model, MFD and serial no does not chage. So we need get the values for those variables only in the first time
     ***/
    
    SbtScannerInfo *scannerInfo = [[zt_ScannerAppEngine sharedAppEngine] getScannerByID:m_ScannerID];
    if([scannerInfo getScannerModel] == SBT_DEVMODEL_SSI_RFD8500) {
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, 20012];
        [self getRFID8500Info:20012 withXML:in_xml withAssignedVal:fwVersion];
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, RMD_ATTR_MODEL_NUMBER];
        [self getRFID8500Info:RMD_ATTR_MODEL_NUMBER withXML:in_xml withAssignedVal:modelNumber];
    } else {
        in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-xml><attrib_list>%d,%d</attrib_list></arg-xml></cmdArgs></inArgs>", m_ScannerID, 20012, RMD_ATTR_MODEL_NUMBER];
        
        NSMutableString *result = [[NSMutableString alloc] init];
        [result setString:@""];
        
        SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
        
        if (SBT_RESULT_SUCCESS != res) {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               UIAlertView *alert = [[UIAlertView alloc]
                                                     initWithTitle:ZT_SCANNER_APP_NAME
                                                     message:@"Cannot retrieve asset information from the device"
                                                     delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
                               [alert show];
                           }
                           );
            return;
            
        }
        
        BOOL success = FALSE;
        
        do {
            NSString* res_str = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString* tmp = @"<attrib_list><attribute>";
            NSRange range = [res_str rangeOfString:tmp];
            NSRange range2;
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            res_str = [res_str substringFromIndex:(range.location + range.length)];
            
            tmp = @"</attribute></attrib_list>";
            range = [res_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range.length = [res_str length] - range.location;
            
            res_str = [res_str stringByReplacingCharactersInRange:range withString:@""];
            
            NSArray *attrs = [res_str componentsSeparatedByString:@"</attribute><attribute>"];
            
            if ([attrs count] == 0)
            {
                break;
            }
            
            NSString *attr_str;
            
            int attr_id;
            int attr_val;
            
            for (NSString *pstr in attrs)
            {
                attr_str = pstr;
                
                tmp = @"<id>";
                range = [attr_str rangeOfString:tmp];
                if ((range.location != 0) || (range.length != [tmp length]))
                {
                    break;
                }
                attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
                
                tmp = @"</id>";
                
                range = [attr_str rangeOfString:tmp];
                
                if ((range.location == NSNotFound) || (range.length != [tmp length]))
                {
                    break;
                }
                
                range2.length = [attr_str length] - range.location;
                range2.location = range.location;
                
                NSString *attr_id_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
                
                attr_id = [attr_id_str intValue];
                
                
                range2.location = 0;
                range2.length = range.location + range.length;
                
                attr_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
                
                tmp = @"<value>";
                range = [attr_str rangeOfString:tmp];
                if ((range.location == NSNotFound) || (range.length != [tmp length]))
                {
                    break;
                }
                attr_str = [attr_str substringFromIndex:(range.location + range.length)];
                
                tmp = @"</value>";
                
                range = [attr_str rangeOfString:tmp];
                
                if ((range.location == NSNotFound) || (range.length != [tmp length]))
                {
                    break;
                }
                
                range.length = [attr_str length] - range.location;
                
                attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
                
                attr_val = [attr_str intValue];
                
                if (RMD_ATTR_FRMWR_VERSION == attr_id)
                {
                    fwVersion = attr_str;
                }
                else if (RMD_ATTR_MODEL_NUMBER == attr_id)
                {
                    modelNumber = attr_str;
                }
            }
            
            success = TRUE;
            
        } while (0);
        
        if (FALSE == success)
        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               UIAlertView *alert = [[UIAlertView alloc]
                                                     initWithTitle:ZT_SCANNER_APP_NAME
                                                     message:@"Error"
                                                     delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
                               [alert show];
                           }
                           );
            return;
        }
    }
}

- (void)getRFID8500Info:(int)attrID withXML:(NSString*)in_xml withAssignedVal:(NSString*)value
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result setString:@""];
    
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_RSM_ATTR_GET aInXML:in_xml aOutXML:&result forScanner:m_ScannerID];
    
    if (SBT_RESULT_SUCCESS != res) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot retrieve asset information from the device"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                       }
                       );
        return;
        
    }
    
    BOOL success = FALSE;
    
    do {
        NSString* res_str = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString* tmp = @"<attrib_list><attribute>";
        NSRange range = [res_str rangeOfString:tmp];
        NSRange range2;
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        res_str = [res_str substringFromIndex:(range.location + range.length)];
        
        tmp = @"</attribute></attrib_list>";
        range = [res_str rangeOfString:tmp];
        
        if ((range.location == NSNotFound) || (range.length != [tmp length]))
        {
            break;
        }
        
        range.length = [res_str length] - range.location;
        
        res_str = [res_str stringByReplacingCharactersInRange:range withString:@""];
        
        NSArray *attrs = [res_str componentsSeparatedByString:@"</attribute><attribute>"];
        
        if ([attrs count] == 0)
        {
            break;
        }
        
        NSString *attr_str;
        
        int attr_id;
        int attr_val;
        
        for (NSString *pstr in attrs)
        {
            attr_str = pstr;
            
            tmp = @"<id>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location != 0) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
            
            tmp = @"</id>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range2.length = [attr_str length] - range.location;
            range2.location = range.location;
            
            NSString *attr_id_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            attr_id = [attr_id_str intValue];
            
            
            range2.location = 0;
            range2.length = range.location + range.length;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range2 withString:@""];
            
            tmp = @"<value>";
            range = [attr_str rangeOfString:tmp];
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            attr_str = [attr_str substringFromIndex:(range.location + range.length)];
            
            tmp = @"</value>";
            
            range = [attr_str rangeOfString:tmp];
            
            if ((range.location == NSNotFound) || (range.length != [tmp length]))
            {
                break;
            }
            
            range.length = [attr_str length] - range.location;
            
            attr_str = [attr_str stringByReplacingCharactersInRange:range withString:@""];
            
            attr_val = [attr_str intValue];
            
            if (20012 == attr_id)
            {
                fwVersion = attr_str;
            }
            else if (RMD_ATTR_MODEL_NUMBER == attr_id)
            {
                modelNumber = attr_str;
            }
        }
        
        success = TRUE;
        
    } while (0);
    
    if (FALSE == success)
    {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Error"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                       }
                       );
        return;
    }
}


- (NSString*)getHelpString
{
    NSString *intialString = @"<div style=\"";
    NSString *fontSize = @"font-size:14px;";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontSize = @"font-size:16px;";
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = @"font-size:14px;";
    }
    NSString *restString =  @"font-family: \"SourceSansPro-Regular\";padding: 8px 10px;\"> <meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>  <label style=\"display: block; margin-bottom: 10px; font-size:17px\"> <b>%@</b></label><label style=\"display: block; margin-bottom: 1px;\"></label><ul><li>%@</li><ol><li>%@<br><a href=%@>%@</a>   </li><li>%@</li><li>%@</li></ol></li><li>%@</li></ul></div>";
    NSString *rsltString = [NSString stringWithFormat:@"%@%@%@", intialString, fontSize, restString];
    return [NSString stringWithFormat:rsltString,FW_PAGE_CONTENT_ONE, FW_PAGE_CONTENT_ONE_SECOND, FW_PAGE_CONTECT_THREE, FW_PAGE_CONTECT_THREE_URL_REAL, FW_PAGE_CONTECT_THREE_URL,FW_PAGE_CONTECT_FOUR, FW_PAGE_CONTECT_FIVE, FW_PAGE_CONTECT_SIX];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none'; document.body.style.KhtmlUserSelect='none'"];
}

- (BOOL)webView:(UIWebView *)view shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)type
{
    if ([[request URL] isEqual:[request mainDocumentURL]])
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return YES;
    }
    else
    {
        return YES;
    }
}

- (NSString*)getPluginMisMatchString
{
    NSString *intialString = @"<div style=\"";
    NSString *fontSize = @"font-size:14px;";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fontSize = @"font-size:16px;";
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontSize = @"font-size:14px;";
    }
    NSString *restString =  @"font-family: \"SourceSansPro-Regular\";padding: 8px 10px;\"> <meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'><ol><li>%@</li><li>%@</li></li></ol></div>";
    NSString *rsltString = [NSString stringWithFormat:@"%@%@%@", intialString, fontSize, restString];
    return [NSString stringWithFormat:rsltString,FW_PAGE_PLUGIN_MISMATCH_CONTENT_ONE, FW_PAGE_PLUGIN_MISMATCH_CONTENT_TWO];
}

-(NSString*)processReleasedDateLblString:(NSString*)revision withDate:(NSString*)date withFWName:(NSMutableArray*)fwNameArray
{
    if (date == nil && revision == nil && date == nil) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:date];
    
    if (dateFromString == nil) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        dateFromString = [dateFormatter dateFromString:date];
    }
    
    [dateFormatter setDateFormat:@"yyyy.dd.MM"];
    NSString *formattedDate = [dateFormatter stringFromDate:dateFromString];
    if (revision == nil) {
        revision = @"";
    }
    if (formattedDate == nil) {
        formattedDate = @"";
    }
    NSString *fwName = [self getCorrectFWName:fwNameArray];
    if (fwName == nil) {
        fwName = @"";
    }
    
    if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
        return [NSString stringWithFormat:@"Current: Release %@ - %@ (%@)", revision,formattedDate, fwVersion];
    } else {
        return [NSString stringWithFormat:@"To: Release %@ - %@ (%@)", revision,formattedDate, fwName];
    }
}

- (NSString*)getCorrectFWName:(NSMutableArray*)fwNameArray
{
    NSString *matchingFWName = nil;
    CFTimeInterval startTime = CACurrentMediaTime();
    CFTimeInterval elapsedTime = 0;
    while (fwVersion == nil && elapsedTime < 20) {
        [NSThread sleepForTimeInterval:0.1];
        elapsedTime = CACurrentMediaTime() - startTime;
    }
    
    for (NSString *fwNameString in fwNameArray) {
        if ([fwNameString isEqualToString:fwVersion]) {
            matchingFWName = fwNameString;
            break;
        }
    }
    
    if (matchingFWName == nil) {
        for (NSString *fwNameString in fwNameArray) {
            if (fwNameString.length > 3 && [[fwNameString substringToIndex:3] isEqualToString:[fwVersion substringToIndex:3]]) {
                matchingFWName = fwNameString;
                break;
            }
        }
    }
    
    return matchingFWName;
}

- (FWUpdateModel*)getFWFileModel:(NSString*)pluginName
{
    FWUpdateModel *model = [[FWUpdateModel alloc] init];
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dwnLoadDir = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    NSString *pluginDir = [dwnLoadDir stringByAppendingPathComponent:pluginName];
    
    NSArray *releaseNotes = [self findFiles:ZT_RELEASE_NOTES_FILE_EXTENTION fromPath:pluginDir];
    //read release notes if availale
    NSError *error;
    if (releaseNotes.count > 0) {
        NSString *strFileContent = [NSString stringWithContentsOfFile:[pluginDir stringByAppendingPathComponent:releaseNotes[0]] encoding:NSUTF8StringEncoding error:&error];
        
        if(error) {
        }
        //model.releaseNotes = strFileContent;
        
        //contentReader setMetaDataFilePath:(NSString *)
    }
    
}

- (NSString*)getAvailableFWFile
{
    selectedFWFilePath = nil;
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dwnLoad = [docDir stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    //first look for plugins
    NSArray *pluginArray = [self findFiles:ZT_PLUGIN_FILE_EXTENTION fromPath:dwnLoad];
    if (pluginArray.count == 0) {
        NSArray *fwFileArray = [self findFiles:ZT_FW_FILE_EXTENTION fromPath:dwnLoad];
        if (fwFileArray.count == 0) {
        } else {
            commandTYpe = ZT_INFO_UPDATE_FROM_DAT;
            selectedFWFilePath = (NSString*)[dwnLoad stringByAppendingPathComponent:(NSString*)fwFileArray[0]];
        }
    } else {
        commandTYpe = ZT_INFO_UPDATE_FROM_PLUGIN;
        selectedFWFilePath = (NSString*)[dwnLoad stringByAppendingPathComponent:(NSString*)pluginArray[0]];
    }
    
    return selectedFWFilePath;
}

- (NSString*)getSelectedFWFilePath
{
    return selectedFWFilePath;
}

- (void)setSelectedFWFilePath:(NSString*)path
{
    selectedFileTxt.text = [path lastPathComponent];
    if ([[path pathExtension] isEqualToString:@"DAT"]) {
        commandTYpe = ZT_INFO_UPDATE_FROM_DAT;
    } else if ([[path pathExtension] isEqualToString:@"SCNPLG"]){
        commandTYpe = ZT_INFO_UPDATE_FROM_PLUGIN;
    }
    
    NSRange equalRange = [path rangeOfString:@"Documents" options:NSBackwardsSearch];
    if (equalRange.location != NSNotFound) {
        NSString *relativePath = [path substringFromIndex:equalRange.location+equalRange.length];
        [[NSUserDefaults standardUserDefaults] setObject:relativePath
                                                  forKey:ZT_SETTING_SAVE_FW_PATH];
    }
    selectedFWFilePath = path;
}

- (NSArray *)findFiles:(NSString *)extension fromPath:(NSString*)path
{
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *item;
    NSArray *contents = [manager contentsOfDirectoryAtPath:path error:nil];
    for (item in contents)
    {
        if ([[item pathExtension]isEqualToString:extension])
        {
            [matches addObject:item];
        }
    }
    
    return matches;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScannerID:(int)currentScannerID
{
    m_ScannerID = currentScannerID;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)closeHelpView:(id)sender {
    [self adjustHelpViewVisibility:YES];
}

- (IBAction)selectDatFile:(id)sender
{
    [self invokeFileSelector];
}

- (void)invokeFileSelector
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    FWFilesTableVC *startingVC = [[FWFilesTableVC alloc] initWithPath:documentsDirectory];
    
    [self.navigationController pushViewController:startingVC animated:YES];
}

- (void)showFWUPdateView
{
    [self adjustFWUpdateViewVisibility:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // iphone
        
        // the top view controller is on top of the navigation controller's stack
        UINavigationController *updateVC = (UINavigationController*)[[self.splitViewController viewControllers] objectAtIndex:0];
        
        // the top view controller is on top of the detail view controller's stack
        UIViewController *topVc = [updateVC topViewController];
        topVc.view.userInteractionEnabled = NO;
        updateVC.view.userInteractionEnabled = NO;
    }
}

- (void)hideFWUpdateView
{
    [self adjustFWUpdateViewVisibility:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        for (UINavigationController *nav in [self.splitViewController viewControllers]) {
            nav.view.userInteractionEnabled = YES;
            NSArray *vb2 = [nav viewControllers];
            for (UIViewController *vc in [nav viewControllers]) {
                vc.view.userInteractionEnabled = YES;
            }
        }
    }
}

- (void)adjustFWUpdateViewVisibility:(BOOL)hiddenStatus
{
    updateFWView.hidden = hiddenStatus;
    if (hiddenStatus == NO) {
        [updateFWView.superview bringSubviewToFront:updateFWView];
    } else {
        [updateFWView.superview sendSubviewToBack:updateFWView];
    }
    progressBar.hidden = hiddenStatus;
}

- (void)setUpTemporyView
{
    temporyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIView *superViewToTmpView = nil;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        superViewToTmpView = superScrollView;
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        superViewToTmpView = self.view;
    }
    [superViewToTmpView addSubview:temporyView];
    temporyView.backgroundColor = [[UpdateFirmwareVC getAppColor:BG_COLOUR_INACTIVE_BACKGROUND]  colorWithAlphaComponent:0.5];
    [superViewToTmpView bringSubviewToFront:temporyView];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    [abortBtn.superview bringSubviewToFront:abortBtn];
    [superViewToTmpView bringSubviewToFront:updateFWView];
    temporyView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c1];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c2];
    
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c3];
    
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:temporyView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superViewToTmpView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [superViewToTmpView addConstraint:c4];
}

- (void)removeTemporyView
{
    if (temporyView != nil) {
        [temporyView removeFromSuperview];
        temporyView = nil;
    }
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (IBAction)updateFW:(id)sender
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self showFWUPdateView];
    [self setUpTemporyView];
    
    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDON];
    
    fwUpdateDidAbort = NO;
    progressBar.progress = 0.0;
    
    [sender setUserInteractionEnabled:NO];
    fwUpdateDidStop = NO;
    NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID><cmdArgs><arg-string>%@</arg-string></cmdArgs></inArgs>", m_ScannerID, selectedFWFilePath];
    int command = 0;
    if (commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
        command = SBT_UPDATE_FIRMWARE;
    } else {
        command = SBT_UPDATE_FIRMWARE_FROM_PLUGIN;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:command aInXML:in_xml aOutXML:nil forScanner:m_ScannerID];
        [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        if (fwUpdateDidAbort == YES) {
            return;
        }
        else if (res != SBT_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                fwUpdateDidStop = YES;
                progressBar.progress = 0.0;
                [progressBar setNeedsDisplay];
                fwUpdateAmount = 0.0f;
            });
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               UIAlertView *alert = [[UIAlertView alloc]
                                                     initWithTitle:ZT_SCANNER_APP_NAME
                                                     message:@"Firmware update Failed"
                                                     delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
                               [alert show];
                               [self hideFWUpdateView];
                               [self resetProgressBar];
                               [self removeTemporyView];
                               if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
                                   [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
                               }
                           }
                           );
        } else {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               percentageLbl.text = @"";
                               NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
                               [activityView showAlertWithView:self.view withTarget:self withMethod:@selector(performStartNewFirmware:) withObject:in_xml withString:nil];
                               [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:YES];
                               [[zt_ScannerAppEngine sharedAppEngine] previousScannerpreviousScanner:m_ScannerID];
                               [self resetProgressBar];
                           }
                           );
        }
        [updateBtn setUserInteractionEnabled:YES];
    });
}

- (void)disableNavigateBack
{
    
}

- (void)resetProgressBar
{
    fwUpdateDidStop = YES;
    progressBar.progress = 0.0;
    [progressBar setNeedsDisplay];
    fwUpdateAmount = 0.0f;
}

- (void)performStartNewFirmware:(NSString*)param
{
    [self addActivityIndicatorForReebooting];
    fwUpdateViewTitle.text = ZT_UPDATE_FW_VIEW_TITLE_REBOOTING;
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_START_NEW_FIRMWARE aInXML:param aOutXML:nil forScanner:m_ScannerID];
    
    if (res != SBT_RESULT_SUCCESS)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *alert = [[UIAlertView alloc]
                                                 initWithTitle:ZT_SCANNER_APP_NAME
                                                 message:@"Cannot perform [Start new firmware] action"
                                                 delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                           [alert show];
                       }
                       );
    } else {
        [self removeTemporyView];
    }
}

- (IBAction)abortFWUpdate:(id)sender
{
    [[zt_ScannerAppEngine sharedAppEngine] blinkLEDOff];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self hideFWUpdateView];
    [self removeTemporyView];
    [updateBtn setUserInteractionEnabled:YES];
    fwUpdateDidStop = YES;
    if (commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
        isFWUpdatingDAT = NO;
    }
    if (commandTYpe == ZT_INFO_UPDATE_FROM_PLUGIN) {
        isFWUpdatingPLUGIN = NO;
    }
    
    NSString *in_xml = [NSString stringWithFormat:@"<inArgs><scannerID>%d</scannerID></inArgs>", m_ScannerID];
    
    SBT_RESULT res = [[zt_ScannerAppEngine sharedAppEngine] executeCommand:SBT_DEVICE_ABORT_UPDATE_FIRMWARE aInXML:in_xml aOutXML:nil forScanner:m_ScannerID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (res != SBT_RESULT_SUCCESS)
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               UIAlertView *alert = [[UIAlertView alloc]
                                                     initWithTitle:ZT_SCANNER_APP_NAME
                                                     message:@"Firmware update Abort Failed"
                                                     delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
                               [alert show];
                           }
                           );
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                fwUpdateDidAbort = YES;
                progressBar.progress = 0.0;
                [progressBar setNeedsDisplay];
                fwUpdateAmount = 0.0f;
                percentageLbl.text = [NSString stringWithFormat:@"%i%%",0];
            });
        }
        [NSThread sleepForTimeInterval:5.0];
    });
}

- (IBAction)pluginMisMatchOkClicked:(id)sender {
    [self adjustPluginVisibility:YES];
    if([[zt_ScannerAppEngine sharedAppEngine] firmwareDidUpdate]) {
        [[zt_ScannerAppEngine sharedAppEngine] setFirmwareDidUpdate:NO];
    }
    //[self.navigationController popViewControllerAnimated:YES];

}

- (void)setCommandType:(ZT_INFO_UPDATE_FW)type;
{
    commandTYpe = type;
}


// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)updateUI:(FirmwareUpdateEvent*)event
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (fwUpdateDidStop == NO) {
            progressBar.progress = (float)event.currentRecord/event.maxRecords;
            if ((int)(float)event.currentRecord/event.maxRecords*100 < 10) {
                percentageLbl.text = [NSString stringWithFormat:@"%i%%",(int)((float)event.currentRecord/event.maxRecords*100)];
            } else {
                percentageLbl.text = [NSString stringWithFormat:@"%i%%",(int)((float)event.currentRecord/event.maxRecords*100+1)];
            }
            
            if (progressBar.progress == 0 || progressBar.progress == 100) {
                if (commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
                    isFWUpdatingDAT = NO;
                }
                if (commandTYpe == ZT_INFO_UPDATE_FROM_PLUGIN) {
                    isFWUpdatingPLUGIN = NO;
                }
                
                fwUpdateAmount = 0;
            } else {
                if (commandTYpe == ZT_INFO_UPDATE_FROM_DAT) {
                    isFWUpdatingDAT = YES;
                }
                if (commandTYpe == ZT_INFO_UPDATE_FROM_PLUGIN) {
                    isFWUpdatingPLUGIN = YES;
                }
            }
        }
    });
}

- (void)addActivityIndicatorForReebooting
{
    activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeThreeDots tintColor:[UIColor grayColor]];
    
    activityIndicatorView.frame = CGRectMake(0,progressBar.frame.origin.y-20, progressBar.frame.size.width, 100);
    [updateFWView addSubview:activityIndicatorView];
    
    [activityIndicatorView.superview bringSubviewToFront:activityIndicatorView];
    [activityIndicatorView startAnimating];

}

- (void)removeActivityIndicatorForReebooting
{
    if (activityIndicatorView != nil) {
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
        activityIndicatorView = nil;
    }
}

@end
