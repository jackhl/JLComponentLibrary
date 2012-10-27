#JLComponentLibrary    
*A collection of classes that simplify complex boilerplate code. JLComponentLibrary takes a different approach to simplification. It does not attempt to obfusicate away all of the internals when possible. It will never attempt to assume behavior. Instead, it simply wraps the generic boilerplate that many apps require. It also attempts to solve discrete problems rather than attempt to provide overly-generalized solutions.*

Complete documentation is available [here][1].

---
##JLDataManager
*JLDataManager manages the entire Core Data stack, much of which is simply boilerplate code. JLDataManager manages a single NSManagedObjectContext that lives on the main thread while also allowing the class consumer to instantiate more instances with the same core data stack on different (or the same) threads. This makes keeping a reference to the object context much easier when you’re working with objects on the UI thread.*
##JLManagedTableViewController
*A subclass of UITableViewController that allows easy integration with Core Data and supports sorting, sections, deleting, and reordering.*
##JLRequestDispatch
*Dispatches cachable threaded network requests with completion blocks.
 JLRequestDispatch is useful for "set it and forget it" network requests that need
 to execute discrete behavior on completion. JLRequestDispatch efficiently manages
 multiple concurrent threads as well as data caching. Class consumers can use JLRequestDispatch to manage request cancellation, progress, and completion execution order.*
##JLRequestDispatchOperation
*An NSOperation subclass that manages a single network request that is guaranteed
 to execute asynchronously.
 You are free to use this operation in the context of an NSOperationQueue or as a 
 stand-alone asynchronous request executor. Call `-[NSOperation start]` if you are
 not using this object in the context of an NSOperationQueue.*


[1]: http://jlawr3nc3.github.com/JLComponentLibrary/
