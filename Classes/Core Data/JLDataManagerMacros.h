//  Created by Jack Lawrence on 8/2/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#ifndef JLDataManagerMacros_h
#define JLDataManagerMacros_h

#define MainThreadManagedObjectForClass(class) [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithUTF8String:#class] \
                                                                             inManagedObjectContext:[[JLDataManager sharedManager] mainThreadObjectContext]];

#define ManagedObjectForClassInContext(class, context) [NSEntityDescription insertNewObjectForEntityForName:[NSString stringWithUTF8String:#class] \
                                                                                     inManagedObjectContext:context];


#endif
