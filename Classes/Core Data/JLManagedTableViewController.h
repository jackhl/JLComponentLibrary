//  Created by Jack Lawrence on 8/2/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@class JLManagedTableViewController;

@protocol JLManagedTableViewControllerDelegate;
@protocol JLManagedTableViewControllerDataSource;

/** 
 A subclass of `UITableViewController` that allows easy integration with Core Data, including sorting, sections, deleting, and reordering.
 
 
 Remember to call `[[JLDataManager sharedInstance] save]` in the relevant `AppDelegate` methods.
 */
@interface JLManagedTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

/** @name Configurable Options */

/** 
 Whether or not you can delete cells and their corresponding Core Data entities using the edit button or swipe to delete.
 
 If `allowsCellDeletion` or allowsCellReordering is `YES` and the table view is in the context of a `UINavigationController`,
 an edit button will be shown on the left of the navigation bar.
 */
@property (nonatomic) BOOL allowsCellDeletion;
/** 
 Whether or not you can reorder cells. 
 
 If allowsCellDeletion or `allowsCellReordering` is `YES` and the table view is in the context of a `UINavigationController`,
 an edit button will be shown on the left of the navigation bar.
 */
@property (nonatomic) BOOL allowsCellReordering;
/** Whether or not section titles are shown. Section titles are based on the passed in `sectionNameKeyPath`. */
@property (nonatomic) BOOL showsSectionHeaderTitles;
/** Whether or not the quick-scroll bar is shown on the right. */
@property (nonatomic) BOOL showsSectionQuickScrollBar;

/** @name Data */

/** The fetched results controller containing the Core Data backing store. */
@property (nonatomic, readonly, strong) NSFetchedResultsController *fetchedResultsController;

/** @name Protocol Conforming Objects */

/** The controller's delegate. */
@property (nonatomic, weak) id <JLManagedTableViewControllerDelegate> delegate;
/** The controller's data source. */
@property (nonatomic, weak) id <JLManagedTableViewControllerDataSource> dataSource;

/** @name Initialization */

/** 
 Initializes the managed table view controller with a table view style and the minimum information required to fetch data from the data store 
 and populate the table view.
 
 @param style The table view's style, currently either plain or grouped.
 @param entityName The name of the model object in the data model.
 @param sortKeyPath The key-path on the model object to sort by. Sorts ascending.
 
 @return An initialized instance of `JLManagedTableViewController`.
 */
- (id)initWithStyle:(UITableViewStyle)style
         entityName:(NSString *)entityName
        sortKeyPath:(NSString *)sortKeyPath;

/**
 Initializes the managed table view controller with a table view style and the minimum information used to fetch data from the data store
 and populate the table view. Also provides more advanced sorting, filtering, and sections.
 
 @param style The table view's style, currently either plain or grouped.
 @param entityName The name of the model object in the data model.
 @param sortKeyPathOrNil The key-path on the model object to sort by. Sorts ascending. If nil, `sortDescriptorsOrNil` must not be nil.
 @param sortDescriptorsOrNil An array of NSSortDescriptor objects to sort the datastore by. If nil, `sortKeyPathOrNil` must not be nil.
 @param predicateOrNil The NSPredicate object to filter the data on.
 @param sectionNameKeyPathOrNil The key-path on the model object to break results into sections.
 
 @return An initialized instance of `JLManagedTableViewController`.
 */
- (id)initWithStyle:(UITableViewStyle)style
         entityName:(NSString *)entityName
        sortKeyPath:(NSString *)sortKeyPathOrNil
    sortDescriptors:(NSArray *)sortDescriptorsOrNil
    filterPredicate:(NSPredicate *)predicateOrNil
 sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil;

@end

/** Objects conforming to JLManagedTableViewControllerDelegate receive messages when events occur. */
@protocol JLManagedTableViewControllerDelegate <NSObject>

@optional
/**
 Informs the delegate after an object has been moved from one index path to another index path.
 
 @param tableController The sender.
 @param movedObject The Core Data entity that was moved.
 @param fromIndex The index path the entity was moved from.
 @param toIndex The index path the entity was moved to.
 */
- (void)managedTableViewController:(JLManagedTableViewController *)tableController
                     didMoveObject:(NSManagedObject *)movedObject
                     fromIndexPath:(NSIndexPath *)fromIndex
                       toIndexPath:(NSIndexPath *)toIndex;

/**
 Informs the delegate when an object pending deletion.
 
 @param tableController The sender.
 @param object The object pending deletion.
 */
- (void)managedTableViewController:(JLManagedTableViewController *)tableController willDeleteObject:(NSManagedObject *)object;
/**
 Informs the delegate when an object has been inserted.
 
 @param tableController The sender.
 @param object The object that has been inserted.
 */
- (void)managedTableViewController:(JLManagedTableViewController *)tableController didInsertObject:(NSManagedObject *)object;

@end

/** Objects conforming to JLManagedTableViewControllerDataSource are polled for data. */
@protocol JLManagedTableViewControllerDataSource <NSObject>

@optional
/**
 An alternative to `-[UITableViewController tableView:cellForRowAtIndexPath:]` that gives you a reference to the managed object in question.
 
 As a convenience, you should create a new pointer and re-cast the `managedObject` from its generic `NSManagedObject` type and give it its real
 entity type. You can also instead choose to implement `-[UITableViewController tableView:cellForRowAtIndexPath:]` and retrieve a reference to the
 entity through the property `fetchedResultsController` using `-[NSFetchedResultsController objectAtIndexPath:]`.
 
 @param tableController The sender.
 @param managedObject The managed object associated with the cell at the specified `indexPath`.
 @param indexPath The index path of the requested cell.
 */
- (UITableViewCell *)managedTableViewController:(JLManagedTableViewController *)tableController
                           cellForManagedObject:(NSManagedObject *)managedObject
                                    atIndexPath:(NSIndexPath *)indexPath;

@end

