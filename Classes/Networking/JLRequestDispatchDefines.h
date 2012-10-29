//  Created by Jack Lawrence on 10/14/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#ifndef JLRequestDispatchDefines_h
#define JLRequestDispatchDefines_h

@class JLRequestDispatchOperation;

/** @name Typedefs */

/**
 Block for request completion.
 
 Param 1: The data retrieved, if any.
 Param 2: The reported error, if any.
 */
typedef void (^JLRequestCompletion)(NSData *, NSError *);

/**
 Block for request processing.
 
 Param 1: The data retrieved, if any.
 Param 2: The reported error, if any.
 
 @return The processed data.
 */
typedef id (^JLRequestProcessing)(NSData *, NSError *);

/**
 Block for request ordered completion.
 
 Param 1: The processed data.
 */
typedef void (^JLRequestOrderedCompletion)(id);

/**
 Block for request progress.
 
 Param 1: The dispatch operation the request operated on.
 Param 2: The current length of the NSData object.
 Param 3: the _expected_ final length of the object. If the final length is 
 unknown or zero, passes RequestDispatchOperationUnknownLength for the final 
 parameter.
 */
typedef void (^JLRequestProgress)(JLRequestDispatchOperation *, NSUInteger, NSInteger);


#endif
