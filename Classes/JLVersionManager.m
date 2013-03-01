//
//  JLVersionManager.m
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 1/11/13.
//  Copyright (c) 2013 Jack Lawrence. All rights reserved.
//

#import "JLVersionManager.h"

static NSString * const JLVersionManagerCurrentVersionKey = @"JL_VERSION_MANAGER_CURRENT_VERSION";

static NSString *CurrentVersion;
static NSString *MigratedFromVersion;

static BOOL IsFirstLaunch = NO;
static BOOL IsFirstLaunchThisVersion = NO;

@implementation JLVersionManager

+ (void)initialize {
    CurrentVersion = [NSString stringWithFormat:@"%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    NSString *savedVersion = [[NSUserDefaults standardUserDefaults] stringForKey:JLVersionManagerCurrentVersionKey];
    
    if (!savedVersion) {
        IsFirstLaunch = YES;
    }
    
    if (![savedVersion isEqualToString:CurrentVersion]) {
        IsFirstLaunchThisVersion = YES;
        MigratedFromVersion = savedVersion;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:CurrentVersion forKey:JLVersionManagerCurrentVersionKey];

}

+ (BOOL)isFirstLaunch {
    return IsFirstLaunch;
}

+ (BOOL)isFirstLaunchThisVersion {
    return IsFirstLaunchThisVersion;
}

+ (NSString *)migratedFromVersion {
    return MigratedFromVersion;
}

+ (NSString *)currentVersion {
    return CurrentVersion;
}



@end
