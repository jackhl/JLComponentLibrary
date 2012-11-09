// DataManager.h
// Based on http://nachbaur.com/blog/smarter-core-data
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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
@property (nonatomic, readonly, strong) NSManagedObjectContext *mainObjectContext;
/** The global persistent store coordinator. */
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/** 
 Retrive the shared data manager. You should use this method to retreive the singleton object and avoid
 instantiating multiple data managers as sqlite3 has thread safety issues.
 
 @return The shared data manager.
 */
+ (JLDataManager *)sharedInstance;

/**
 Reconciles changes made in the main thread managed object context to disk.
 
 @return Success or failure.
 */
- (BOOL)save;
/**
 Creates a new managed object context on the caller's current thread.
 
 @return A new managed object context.
 */
- (NSManagedObjectContext *)managedObjectContext;

/**
 Retreives the options the persistent store should use when migrating and retrieving the data store.
 
 Subclass this method to provide your own options.
 
 @return The options the persistent store should use when migrating and retrieving the data store.
 */
- (NSDictionary *)persistentStoreCoordinatorOptions;

@end