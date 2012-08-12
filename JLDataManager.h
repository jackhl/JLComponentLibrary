// DataManager.h
// Based on http://nachbaur.com/blog/smarter-core-data
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const JLDataManagerDidSaveNotification;
extern NSString * const JLDataManagerDidSaveFailedNotification;

@interface JLDataManager : NSObject

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (JLDataManager *)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext *)managedObjectContext;

@end