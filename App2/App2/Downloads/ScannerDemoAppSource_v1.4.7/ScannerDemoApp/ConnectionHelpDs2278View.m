//
//  ConnectionHelpDs2278View.m
//  ScannerSDKApp
//
//  Created by Nilusha Niwanthaka Wimalasena on 7/11/17.
//  Copyright © 2017 Alexei Igumnov. All rights reserved.
//

#import "ConnectionHelpDs2278View.h"
#import "BarcodeImage.h"

@implementation ConnectionHelpDs2278View

- (void)drawRect:(CGRect)rect {
    
    [self.resetFactoryDefaultsBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"92" withHeight:self.resetFactoryDefaultsBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
    
    [self.btleSsiBarcodeImage setImage:[BarcodeImage generateBarcodeImageUsingConfigCode:@"N017F17" withHeight:self.btleSsiBarcodeImage.frame.size.height andWidth:self.superview.frame.size.width]];
}

- (void)dealloc {
    [_resetFactoryDefaultsBarcodeImage release];
    [_btleSsiBarcodeImage release];
    [super dealloc];
}
@end
