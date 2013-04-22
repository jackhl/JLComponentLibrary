// DataManager.m
#import "JLDataManager.h"

NSString * const JLDataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const JLDataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface JLDataManager ()

@property (nonatomic, readwrite, strong) NSManagedObjectModel *objectModel;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *mainThreadObjectContext;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// State needed for resets.
// Holds all of the contexts assigned to a thread for resetPersistentStoreCoordinator.
@property (nonatomic, strong) NSMutableArray *threadSpecificContexts;

- (NSString *)sharedDocumentsPath;

@end

@implementation JLDataManager

NSString * const kDataManagerSQLiteNameType = @"sqlite";
NSString * const kDataManagerSQLiteNameResource = @"Model";
NSString * const kDataManagerSQLiteName = @"Model.sqlite";
NSString * const kCurrentThreadContextKey = @"JLDATAMANAGER_CURRENT_THREAD_CONTEXT";


- (id)init
{
    self = [super init];
    if (self) {
        [self setThreadSpecificContexts:[NSMutableArray array]];
    }
    return self;
}

+ (JLDataManager *)sharedManager {
	static dispatch_once_t pred;
	static JLDataManager *sharedManager = nil;
    
	dispatch_once(&pred, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setConcurrencyType:NSConfinementConcurrencyType];
    });
    
	return sharedManager;
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
    
    return @{NSMigratePersistentStoresAutomaticallyOption: @YES,
             NSInferMappingModelAutomaticallyOption:       @YES};
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
        [NSException raise:@"com.jackhl.JLDataManager.CoreDataStackCreationException"
                    format:@"Fatal error while creating persistent store: %@", error];
	}
    
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainThreadObjectContext {
	if (_mainThreadObjectContext)
		return _mainThreadObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainThreadObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainThreadObjectContext;
	}
    
	_mainThreadObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	[_mainThreadObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [_mainThreadObjectContext setUndoManager:nil];
    
	return _mainThreadObjectContext;
}

- (BOOL)save {
	if (![self.mainThreadObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.mainThreadObjectContext save:&error]) {
        // Support crashlytics logging if available, otherwise NSLog(). Doesn't work in static lib compilation.
#ifdef CLS_LOG
        CLS_LOG(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
#else
        NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
#endif
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
		if (error) {
            [NSException raise:@"com.jackhl.JLDataManager.CoreDataStackCreationException"
                        format:@"Error creating directory at path: %@", [error localizedDescription]];
        }
	}
    
	return SharedDocumentsPath;
}

- (NSManagedObjectContext *)currentThreadObjectContext {
    if ([NSThread isMainThread]) {
        return [self mainThreadObjectContext];
    }
    NSManagedObjectContext *context = [[[NSThread currentThread] threadDictionary] objectForKey:kCurrentThreadContextKey];
    if (!context) {
        return [self managedObjectContext];
    }
    else {
        return context;
    }
}

- (NSManagedObjectContext *)managedObjectContext {
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:[self concurrencyType]];
    [ctx setParentContext:[self mainThreadObjectContext]];
    
    if (![[[NSThread currentThread] threadDictionary] objectForKey:kCurrentThreadContextKey]) {
        [[[NSThread currentThread] threadDictionary] setObject:ctx forKey:kCurrentThreadContextKey];
        [[self threadSpecificContexts] addObject:ctx];
    }
    
	return ctx;
}

- (void)resetPersistentStoreCoordinator {
    NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    NSError *removeStoreError;
    NSPersistentStore *storeToRemove = [[self persistentStoreCoordinator] persistentStoreForURL:storeURL];
    if ([[self persistentStoreCoordinator] removePersistentStore:storeToRemove error:&removeStoreError]) {
        NSError *fileDeleteError;
        if (![[NSFileManager defaultManager] removeItemAtPath:storePath error:&fileDeleteError]) {
            [NSException raise:@"com.jackhl.JLDataManager.UnitTestingException"
                        format:@"Failed to remove the SQLite store from disk: %@", fileDeleteError];
        }
        [self setPersistentStoreCoordinator:nil];
        [self setMainThreadObjectContext:nil];
        [[self threadSpecificContexts] makeObjectsPerformSelector:@selector(reset)];
        [[self threadSpecificContexts] makeObjectsPerformSelector:@selector(setParentContext:) withObject:[self mainThreadObjectContext]];
    }
    else {
        [NSException raise:@"com.jackhl.JLDataManager.UnitTestingException"
                    format:@"Failed to remove the persistent store from the persistent store coordinator: %@", removeStoreError];
    }
}

@end