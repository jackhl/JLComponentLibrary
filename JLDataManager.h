// DataManager.h
// Based on http://nachbaur.com/blog/smarter-core-data
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const JLDataManagerDidSaveNotification;
extern NSString * const JLDataManagerDidSaveFailedNotification;

@interface JLDataManager : NSObject

@property (nonatomic, readonly, strong) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (JLDataManager *)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext *)managedObjectContext;

@end