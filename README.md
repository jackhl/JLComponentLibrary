#JLComponentLibrary    
*A collection of classes that simplify complex boilerplate code. JLComponentLibrary takes a different approach to simplification. It does not attempt to obfusicate away all of the internals when possible. It will never attempt to assume behavior. Instead, it simply wraps the generic boilerplate that many apps require.*

Complete documentation is available [here][1].

---
##JLDataManager
*JLDataManager manages the entire Core Data stack, much of which is simply boilerplate code. JLDataManager manages a single NSManagedObjectContext that lives on the main thread while also allowing the class consumer to instantiate more instances with the same core data stack on different (or the same) threads. This makes keeping a reference to the object context much easier when you’re working with objects on the UI thread.*
##JLManagedTableViewController
*A subclass of `UITableViewController` that allows easy integration with Core Data and supports sorting, sections, deleting, and reordering.*


[1]: http://jlawr3nc3.github.com/JLComponentLibrary/
