// DataManager.m
#import "JLDataManager.h"

NSString * const JLDataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const JLDataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface JLDataManager ()

@property (nonatomic, readwrite, strong) NSManagedObjectModel *objectModel;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *mainThreadObjectContext;
@property (nonatomic, readwrite, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString*)sharedDocumentsPath;

@end

@implementation JLDataManager

NSString * const kDataManagerSQLiteNameType = @"sqlite";
NSString * const kDataManagerSQLiteNameResource = @"Model";
NSString * const kDataManagerSQLiteName = @"Model.sqlite";
NSString * const kCurrentThreadContextKey = @"JLDATAMANAGER_CURRENT_THREAD_CONTEXT";


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
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
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
    
	_mainThreadObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainThreadObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [_mainThreadObjectContext setUndoManager:nil];
    
	return _mainThreadObjectContext;
}

- (BOOL)save {
	if (![self.mainThreadObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.mainThreadObjectContext save:&error]) {
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
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    if (![[[NSThread currentThread] threadDictionary] objectForKey:kCurrentThreadContextKey]) {
        [[[NSThread currentThread] threadDictionary] setObject:ctx forKey:kCurrentThreadContextKey];
    }
    
	return ctx;
}

@end