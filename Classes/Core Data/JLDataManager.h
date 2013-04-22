// DataManager.h
// Based on http://nachbaur.com/blog/smarter-core-data
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JLDataManagerMacros.h"

/** NSNotification posted when the data manager successfully reconciles changes in the main thread managed object context to disk. */
extern NSString * const JLDataManagerDidSaveNotification;
/** NSNotification posted when the data manager fails to reconcile changes in the main thread managed object context to disk. */
extern NSString * const JLDataManagerDidSaveFailedNotification;

/** 
 JLDataManager manages the entire Core Data stack, much of which is simply boilerplate code. 
 JLDataManager manages a single NSManagedObjectContext that lives on the main thread while 
 also allowing the class consumer to instantiate more instances with the same core data stack
 on different (or the same) threads. This makes keeping a reference to the object context much
 easier when you’re working with objects on the UI thread.
 */
@interface JLDataManager : NSObject

/** The object model the persistent store coordinator uses. */
@property (nonatomic, readonly, strong) NSManagedObjectModel *objectModel;
/** The managed object context that JLDataManager retains on the main thread. */
@property (nonatomic, readonly, strong) NSManagedObjectContext *mainThreadObjectContext;
/** The global persistent store coordinator. */
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
/**
 The `NSManagedObjectContextConcurrencyType` that managed object contexts retreived from
 `-[JLDataManager managedObjectContext]` and `-[JLDataManager currentThreadObjectContext]` will use.
 Defaults to `NSConfinementConcurrencyType`.
 
 You should set this property as soon as possible after launch to ensure that the concurrency type
 is consistently applied to all managed object contexts.
 
 @note If `-[JLDataManager currentThreadObjectContext]` is called from the main thread, the context
 it returns will use `NSMainQueueConcurrencyType`.
 */
@property (nonatomic) NSManagedObjectContextConcurrencyType concurrencyType;


/** 
 Retrive the shared data manager. You should use this method to retreive the singleton object and avoid
 instantiating multiple data managers as sqlite3 has thread safety issues.
 
 @return The shared data manager.
 */
+ (JLDataManager *)sharedManager;

/**
 Reconciles changes made in the main thread managed object context to disk.
 
 @return Success or failure.
 */
- (BOOL)save;
/**
 Creates a new managed object context on the caller's current thread.
 
 @note The first time you call this method on a particular thread,
 the managed object context that is returned is also set as the
 current thread object context.
 
 @return A new managed object context.
 */
- (NSManagedObjectContext *)managedObjectContext;

/**
 Retreives the current thread's context.
 
 @return The current thread's managed object context.
 */
- (NSManagedObjectContext *)currentThreadObjectContext;

/**
 Retreives the options the persistent store should use when migrating and retrieving the data store.
 
 Subclass `JLDataManager` and override this method to provide your own options.
 
 @return The options the persistent store should use when migrating and retrieving the data store.
 */
- (NSDictionary *)persistentStoreCoordinatorOptions;

/**
 Resets the main thread managed object context and deletes the backing SQLite store. Useful for
 unit testing.
 
 @warn During and after invoking this method you must refrain from using any existing references you 
 have to `NSManagedObjectContext` instances and model objects from any thread.
 */
- (void)resetPersistentStoreCoordinator;

@end