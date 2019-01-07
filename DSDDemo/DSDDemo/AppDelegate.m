//
//  AppDelegate.m
//  DSDDemo
//
//  Created by Leong on 18/1/13.
//  Copyright (c) 2013 Leong. All rights reserved.
//

#import "AppDelegate.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "ModeSelectionViewController.h"
#import "DSDMainController.h"


@implementation AppDelegate

- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    NSString *platform = [self platform];
//
//    if ([platform isEqualToString:@"iPad6,8"] || [platform isEqualToString:@"iPad6,7"]) {
//
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_Pro" bundle:nil];
//        ModeSelectionViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"model"];
//        self.window.rootViewController = rootViewController;
//
//    }

    DSDMainController *rootVC = [DSDMainController controller];
    self.window.rootViewController = rootVC;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
