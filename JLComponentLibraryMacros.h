//
//  JLComponentLibraryMacros.h
//  JLComponentLibrary
//
//  Created by Jack Lawrence on 8/2/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#ifndef JLComponentLibrary_JLComponentLibraryMacros_h
#define JLComponentLibrary_JLComponentLibraryMacros_h

#define MainThreadManagedObjectForClass(class) [[class alloc] initWithEntity:[NSEntityDescription entityForName:[NSString stringWithUTF8String:#class]   \
                                                      inManagedObjectContext:[[JLDataManager sharedInstance] mainObjectContext]]                         \
                                              insertIntoManagedObjectContext:[[JLDataManager sharedInstance] mainObjectContext]];

#endif
