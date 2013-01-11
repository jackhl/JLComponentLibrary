//
//  JLVersionManager.h
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 1/11/13.
//  Copyright (c) 2013 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLVersionManager : NSObject

// Launch
+ (BOOL)isFirstLaunch;
+ (BOOL)isFirstLaunchThisVersion;

// Version
+ (NSString *)migratingFromVersion;
+ (NSString *)currentVersion;

@end
