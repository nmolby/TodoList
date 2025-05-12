//
//  CoreDataManager.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    @MainActor
    static let preview: CoreDataManager = {
        let result = CoreDataManager(inMemory: true)
        let viewContext = result.container.viewContext
        
        setPreviewItems(context: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            // ignore error in preview
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TodoList")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // In a real app, execute some sort of logging
                // And potentially force user to "failed to load" screen
                print(error)
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func perform<T>(useBackgroundContext: Bool = false, _ block: @escaping (NSManagedObjectContext) throws -> T) async rethrows -> T {
        
        let context = useBackgroundContext ? container.newBackgroundContext() : container.viewContext
        
        return try await context.perform {
            try block(context)
        }
    }
    
    func fetch<T>(useBackgroundContext: Bool = false, _ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        let context = useBackgroundContext ? container.newBackgroundContext() : container.viewContext

        return try context.fetch(request)
    }
}


extension CoreDataManager {
    @discardableResult private static func setPreviewItems(context: NSManagedObjectContext) -> [TodoItemEntity] {
        [
            TodoItemEntity(context: context, name: "Feed the dog", creationDate: Date()),
            TodoItemEntity(context: context, name: "Take out trash", creationDate: Date().addingTimeInterval(-3600)),
            TodoItemEntity(context: context, name: "Read Bible", creationDate: Date().addingTimeInterval(-7200)),
            TodoItemEntity(context: context, name: "Water plants", creationDate: Date().addingTimeInterval(-10800)),
            TodoItemEntity(context: context, name: "Reply to email", creationDate: Date().addingTimeInterval(-14400)),
            TodoItemEntity(context: context, name: "Buy groceries", creationDate: Date().addingTimeInterval(-18000)),
            TodoItemEntity(context: context, name: "Call Mom", creationDate: Date().addingTimeInterval(-21600)),
            TodoItemEntity(context: context, name: "Go for a walk", creationDate: Date().addingTimeInterval(-25200)),
            TodoItemEntity(context: context, name: "Check mailbox", creationDate: Date().addingTimeInterval(-28800)),
            TodoItemEntity(context: context, name: "Make dinner", creationDate: Date().addingTimeInterval(-32400))

        ]
    }
}
