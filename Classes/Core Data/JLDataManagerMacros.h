//  Created by Jack Lawrence on 8/2/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#ifndef JLDataManagerMacros_h
#define JLDataManagerMacros_h

#define MainThreadManagedObjectForClass(class) [[class alloc] initWithEntity:[NSEntityDescription entityForName:[NSString stringWithUTF8String:#class]   \
                                                      inManagedObjectContext:[[JLDataManager sharedInstance] mainObjectContext]]                         \
                                              insertIntoManagedObjectContext:[[JLDataManager sharedInstance] mainObjectContext]];

#endif
