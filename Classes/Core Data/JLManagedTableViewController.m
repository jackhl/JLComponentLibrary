//
//  JLManagedTableViewController.m
//  JLComponentLibrary
//
//  Created by Jack Lawrence on 8/2/12.
//  Copyright (c) 2012 Jack Lawrence. All rights reserved.
//

#import "JLManagedTableViewController.h"

#import "JLDataManager.h"
#import "JLDataManagerMacros.h"

@interface JLManagedTableViewController ()

@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, strong) NSPredicate *filterPredicate;
@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, copy) NSString *sectionNameKeyPath;

@property (nonatomic, readwrite, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation JLManagedTableViewController

@synthesize allowsCellDeletion = _allowsCellDeletion;
@synthesize allowsCellReordering = _allowsCellReordering;
@synthesize showsSectionHeaderTitles = _showsSectionHeaderTitles;
@synthesize showsSectionQuickScrollBar = _showsSectionQuickScrollBar;

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

@synthesize entityName = _entityName;
@synthesize filterPredicate = _filterPredicate;
@synthesize sortDescriptors = _sortDescriptors;
@synthesize sectionNameKeyPath = _sectionNameKeyPath;

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName sortKeyPath:(NSString *)sortKeyPath
{
    return [self initWithStyle:style entityName:entityName sortKeyPath:sortKeyPath sortDescriptors:nil filterPredicate:nil sectionNameKeyPath:nil];
}

- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName sortKeyPath:(NSString *)sortKeyPathOrNil sortDescriptors:(NSArray *)sortDescriptorsOrNil filterPredicate:(NSPredicate *)predicateOrNil sectionNameKeyPath:(NSString *)sectionNameKeyPathOrNil
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        [self setEntityName:entityName];
        [self setFilterPredicate:predicateOrNil];
        if (sortDescriptorsOrNil) {
            [self setSortDescriptors:sortDescriptorsOrNil];
        }
        else if (sortKeyPathOrNil) {
            [self setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortKeyPathOrNil ascending:YES]]];
        }
        else if (sectionNameKeyPathOrNil) {
            [self setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sectionNameKeyPathOrNil ascending:YES]]];
        }
        else {
            [NSException raise:@"NSInvalidArgumentException" format:@"JLManagedTableViewController: At least one of sortDescriptorsOrNil, sortKeyPathOrNil, or sectionNameKeyPathOrNil must be non-nil in order to sort rows in the tableview, which is a requirement of Core Data."];
        }
        [self setSectionNameKeyPath:sectionNameKeyPathOrNil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self allowsCellDeletion] || [self allowsCellReordering]) {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[JLDataManager sharedInstance] save];
}

#pragma mark - Table view data source

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
        [fetchRequest setPredicate:[self filterPredicate]];
        [fetchRequest setSortDescriptors:[self sortDescriptors]];
        
        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                     managedObjectContext:[[JLDataManager sharedInstance] mainObjectContext]
                                                                                       sectionNameKeyPath:[self sectionNameKeyPath]
                                                                                                cacheName:[self entityName]];
        
        [controller setDelegate:self];
        
        NSError *fetchError = nil;
        [controller performFetch:&fetchError];
        
        if (fetchError) {
            NSLog(@"Fetching Employee objects failed with error: %@", fetchError);
        }

        [self setFetchedResultsController:controller];
    }
    
    return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numSections = [[[self fetchedResultsController] sections] count];
    return (numSections > 0)?numSections:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[self fetchedResultsController] sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self showsSectionHeaderTitles]?[[[self.fetchedResultsController sections] objectAtIndex:section] name]:nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self showsSectionQuickScrollBar]?[self.fetchedResultsController sectionIndexTitles]:nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(managedTableViewController:cellForManagedObject:atIndexPath:)]) {
        return [self.dataSource managedTableViewController:self cellForManagedObject:[self.fetchedResultsController objectAtIndexPath:indexPath] atIndexPath:indexPath];
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self allowsCellDeletion]||[self allowsCellReordering]);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self allowsCellReordering];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.delegate respondsToSelector:@selector(managedTableViewController:willDeleteObject:)]) {
            [self.delegate managedTableViewController:self willDeleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
        [[[JLDataManager sharedInstance] mainObjectContext] deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSManagedObject *insertedObj = [[NSClassFromString([self entityName]) alloc] initWithEntity:[NSEntityDescription entityForName:[self entityName]
                                                                                                                inManagedObjectContext:[[JLDataManager sharedInstance] mainObjectContext]]
                                                                     insertIntoManagedObjectContext:[[JLDataManager sharedInstance] mainObjectContext]];
        if ([self.delegate respondsToSelector:@selector(managedTableViewController:didInsertObject:)]) {
            [self.delegate managedTableViewController:self didInsertObject:insertedObj];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([self.delegate respondsToSelector:@selector(managedTableViewController:didMoveObject:fromIndexPath:toIndexPath:)]) {
        [self.delegate managedTableViewController:self didMoveObject:[self.fetchedResultsController objectAtIndexPath:fromIndexPath] fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
}

#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


@end
