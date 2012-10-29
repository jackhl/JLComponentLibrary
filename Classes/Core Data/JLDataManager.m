// DataManager.m
#import "JLDataManager.h"

NSString * const JLDataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const JLDataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface JLDataManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation JLDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;

NSString * const kDataManagerSQLiteNameType = @"sqlite";
NSString * const kDataManagerSQLiteNameResource = @"Model";
NSString * const kDataManagerSQLiteName = @"Model.sqlite";


+ (JLDataManager *)sharedInstance {
	static dispatch_once_t pred;
	static JLDataManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    
	return sharedInstance;
}

- (void)dealloc {
	[self save];
}

- (NSManagedObjectModel *)objectModel {
	if (_objectModel)
		return _objectModel;
    
    _objectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
	return _objectModel;
}

- (NSDictionary *)persistentStoreCoordinatorOptions {
    
    return @{NSMigratePersistentStoresAutomaticallyOption, @YES,
             NSInferMappingModelAutomaticallyOption,       @YES};
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
        
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:storePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:kDataManagerSQLiteNameResource ofType:kDataManagerSQLiteNameType];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	NSDictionary *options = [self persistentStoreCoordinatorOptions];
    
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
    
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainObjectContext {
	if (_mainObjectContext)
		return _mainObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainObjectContext;
	}
    
	_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [_mainObjectContext setUndoManager:nil];
    
	return _mainObjectContext;
}

- (BOOL)save {
	if (![self.mainObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.mainObjectContext save:&error]) {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
		[[NSNotificationCenter defaultCenter] postNotificationName:JLDataManagerDidSaveFailedNotification
                                                            object:error];
		return NO;
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:JLDataManagerDidSaveNotification object:nil];
	return YES;
}

- (NSString *)sharedDocumentsPath {
	static NSString *SharedDocumentsPath = nil;
	if (SharedDocumentsPath)
		return SharedDocumentsPath;
    
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}
    
	return SharedDocumentsPath;
}

- (NSManagedObjectContext *)managedObjectContext {
#if DEBUG
    NSLog(@"WARNING: CREATING MANAGED OBJECT CONTEXT. Are you sure you didn't mean to type mainObjectContext? There is no guarantee regarding which   \
          thread this context will be created on, and every call will result in a new, different context unless you retain. If you did mean to create \
          a new context, make sure you do not autorelease it because it will most likely immediately be deallocated after you're done using it to     \
          execute a fetch request. Managed objects would then be unable to fault on values, and your objects would essentially null all of their properties.");
#endif
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return ctx;
}

@end