/*
    The MIT License (MIT)
    Copyright (c) 2013 - 2014 Vlad Stirbu
    
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <Cordova/CDV.h>
#import "CDVInstagramPlugin.h"

#define IS_IOS13orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)

static NSString *InstagramId = @"com.burbn.instagram";

@implementation CDVInstagramPlugin

@synthesize toInstagram;
@synthesize callbackId;
@synthesize interactionController;

-(void)isInstalled:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
    
}


// - (void)share:(CDVInvokedUrlCommand*)command {
//     self.callbackId = command.callbackId;
//     self.toInstagram = FALSE;
//     NSString    *objectAtIndex0 = [command argumentAtIndex:0];
//     NSString    *caption = [command argumentAtIndex:1];
    
//     CDVPluginResult *result;
    
//     NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
//     if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
//         NSLog(@"open in instagram");
        
//         NSData *imageObj = [[NSData alloc] initWithBase64EncodedString:objectAtIndex0 options:0];
//         NSString *tmpDir = NSTemporaryDirectory();
//         NSString *path;
//         if (IS_IOS13orHIGHER) {
//             path = [tmpDir stringByAppendingPathComponent:@"instagram.ig"];
//         } else {
//             path = [tmpDir stringByAppendingPathComponent:@"instagram.igo"];
//         }
//         [imageObj writeToFile:path atomically:true];
        
//         self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
//         if (IS_IOS13orHIGHER) {
//             self.interactionController .UTI = @"com.instagram.photo";
//         } else {
//             self.interactionController .UTI = @"com.instagram.exclusivegram";
//         }
//         if (caption) {
//             self.interactionController .annotation = @{@"InstagramCaption" : caption};
//         }
//         self.interactionController .delegate = self;
//         [self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.webView animated:YES];
        
//     } else {
//         result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
//         [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
//     }
// }


// - (void)share:(CDVInvokedUrlCommand*)command {
//     self.callbackId = command.callbackId;

//     NSString *objectAtIndex0 = [command argumentAtIndex:0];
//     NSData *imageObj = [[NSData alloc] initWithBase64EncodedString:objectAtIndex0 options:0];
        
//     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
//     [library writeImageDataToSavedPhotosAlbum:imageObj metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
//         NSURL *instagramURL = [NSURL URLWithString:
//                                [NSString stringWithFormat:@"instagram://library?AssetPath=%@",
//                                 [[assetURL absoluteString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]]]];
        
//         if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
//             [[UIApplication sharedApplication] openURL:instagramURL];
//         } else {
//             CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
//             [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
//         }
//     }];
// }

- (void)shareAsset:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    NSData *pngData = [command argumentAtIndex:0];
    NSData *data = [[NSData alloc]initWithBase64EncodedString:pngData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:data];
    [self saveImageToCameraRoll:image];
}

- (void)saveImageToCameraRoll:(UIImage *)image
{
   __block PHAssetChangeRequest *_mChangeRequest = nil;
   __block PHObjectPlaceholder *placeholder;

   [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

       _mChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];

       placeholder = _mChangeRequest.placeholderForCreatedAsset;

   } completionHandler:^(BOOL success, NSError *error) {

       if (success) {
           [self shareLibrary:[placeholder localIdentifier]];
       }
       else {
           NSLog(@"write error : %@",error);
       }
   }];
}

- (void)shareLibrary:(NSString *)imageLocalID {
        CDVPluginResult *result;
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
            NSLog(@"open asset in instagram");
            
//            NSString *localIdentifierEscaped = [imageLocalID stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSURL *instagramShareURL   = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", imageLocalID]];
            
            [[UIApplication sharedApplication] openURL:instagramShareURL];

            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
            
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
            [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
        }
    }


- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application {
    if ([application isEqualToString:InstagramId]) {
        self.toInstagram = TRUE;
    }
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller {
    CDVPluginResult *result;
    
    if (self.toInstagram) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

@end
