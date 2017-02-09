/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

#import "YoikScreenOrientation.h"
#import "CDVViewController+UpdateSupportedOrientations.h"

@implementation YoikScreenOrientation

-(void)screenOrientation:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{

        if(self.originalSupportedOrientations == nil) {
            self.originalSupportedOrientations = [self.viewController valueForKey:@"supportedOrientations"];
        }

        NSArray* arguments = command.arguments;
        NSString* orientationIn = [arguments objectAtIndex:1];

        if ([orientationIn isEqual: @"unlocked"]) {
            [(CDVViewController*)self.viewController updateSupportedOrientations:self.originalSupportedOrientations];
            self.originalSupportedOrientations = nil;
            return;
        }
        
        // grab the device orientation so we can pass it back to the js side.
        NSString *orientation;
        switch ([[UIDevice currentDevice] orientation]) {
            case UIDeviceOrientationLandscapeLeft:
                orientation = @"landscape-secondary";
                break;
            case UIDeviceOrientationLandscapeRight:
                orientation = @"landscape-primary";
                break;
            case UIDeviceOrientationPortrait:
                orientation = @"portrait-primary";
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                orientation = @"portrait-secondary";
                break;
            default:
                orientation = @"portait";
                break;
        }

        // we send the result prior to the view controller presentation so that the JS side
        // is ready for the unlock call.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
            messageAsDictionary:@{@"device":orientation}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
        if ([orientationIn rangeOfString:@"portrait"].location != NSNotFound) {
            [(CDVViewController*)self.viewController updateSupportedOrientations:@[[NSNumber numberWithInt:UIInterfaceOrientationPortrait]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            });
            
        } else if([orientationIn rangeOfString:@"landscape"].location != NSNotFound) {
            [(CDVViewController*)self.viewController updateSupportedOrientations:@[[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft], [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight]]];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            });
        }
    }];
}

@end
