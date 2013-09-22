//
//  AppDelegate.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/15.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Document.h"
#import "Connector.h"
#import "AppDelegate.h"

@interface AppDelegate ()
- (void)_updateNetworkActivity;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBGMSG(@"%s", __func__);
    [[Document sharedDocument] load];
    [[Connector sharedConnector] addObserver:self
                                  forKeyPath:@"networkAccessing"
                                     options:0
                                     context:NULL];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBGMSG(@"%s", __func__);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    DBGMSG(@"%s", __func__);
    [[Document sharedDocument] save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DBGMSG(@"%s", __func__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DBGMSG(@"%s", __func__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DBGMSG(@"%s", __func__);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DBGMSG(@"%s", __func__);
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    DBGMSG(@"%s", __func__);
    return NO;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    DBGMSG(@"%s", __func__);
    return NO;
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if ([keyPath isEqualToString:@"networkAccessing"]) {
        [self _updateNetworkActivity];
    }
}

- (void)_updateNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = [Connector sharedConnector].networkAccessing;
}

@end
