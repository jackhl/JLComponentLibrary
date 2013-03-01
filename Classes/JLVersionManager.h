//
//  JLVersionManager.h
//  JLComponentLibrary_UnitTests
//
//  Created by Jack Lawrence on 1/11/13.
//  Copyright (c) 2013 Jack Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Helper class for application version migrations.
 
 JLVersionManager bases versioning off of the build number
 and the version number.
 
 ## Warnings
 
 JLVersionManager utilizes NSUserDefaults. Removing
 or modifying JLVersionManager data from NSUserDefaults 
 is not advised.
 */
@interface JLVersionManager : NSObject

/** @name Launch Conditions */

/**
 Determines whether or not the user is launching the
 application for the first time ever.
 
 @return Whether or not it is the first launch.
 */
+ (BOOL)isFirstLaunch;
/**
 Determines whether or not the user is launching the
 application for the first time under the current version.
 
 @return Whether or not it is the first launch this version.
 */
+ (BOOL)isFirstLaunchThisVersion;

/** @name Version Information */

/**
 Which version of the application the user updated from.
 
 The version string is in the following format: `<CFBundleShortVersionString> (<CFBundleVersion>)`
 
 Returns `nil` unless `-isFirstLaunchThisVersion` is true.
 
 @return The version of the application the user updated from.
 */
+ (NSString *)migratedFromVersion;
/**
 The current version of the application.
 
 The version string is in the following format: `<CFBundleShortVersionString> (<CFBundleVersion>)`
 */
+ (NSString *)currentVersion;

@end
