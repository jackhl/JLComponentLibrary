//  Created by Jack Lawrence on 8/2/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#ifndef JLDataManagerMacros_h
#define JLDataManagerMacros_h

#define MainThreadManagedObjectForClass(class) [[class alloc] initWithEntity:[NSEntityDescription entityForName:[NSString stringWithUTF8String:#class]   \
                                                      inManagedObjectContext:[[JLDataManager sharedManager] mainThreadObjectContext]]                    \
                                              insertIntoManagedObjectContext:[[JLDataManager sharedManager] mainThreadObjectContext]];

#define ManagedObjectForClassInContext(class, context) [[class alloc] initWithEntity:[NSEntityDescription entityForName:[NSString stringWithUTF8String:#class]   \
                                                              inManagedObjectContext:context]                                                                    \
                                                      insertIntoManagedObjectContext:context];


#endif
