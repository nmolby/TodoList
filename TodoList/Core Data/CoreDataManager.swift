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
                //TODO: do something with error
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}


extension CoreDataManager {
    @discardableResult static func setPreviewItems(context: NSManagedObjectContext) -> [TodoItemEntity] {
        [
            TodoItemEntity(context: context, name: "Feed the dog", creationDate: Date(), editDate: nil),
            TodoItemEntity(context: context, name: "Take out trash", creationDate: Date().addingTimeInterval(-3600), editDate: Date().addingTimeInterval(-1800)),
            TodoItemEntity(context: context, name: "Read Bible", creationDate: Date().addingTimeInterval(-7200), editDate: nil),
            TodoItemEntity(context: context, name: "Water plants", creationDate: Date().addingTimeInterval(-10800), editDate: Date().addingTimeInterval(-9000)),
            TodoItemEntity(context: context, name: "Reply to email", creationDate: Date().addingTimeInterval(-14400), editDate: nil),
            TodoItemEntity(context: context, name: "Buy groceries", creationDate: Date().addingTimeInterval(-18000), editDate: Date().addingTimeInterval(-10000)),
            TodoItemEntity(context: context, name: "Call Mom", creationDate: Date().addingTimeInterval(-21600), editDate: nil),
            TodoItemEntity(context: context, name: "Go for a walk", creationDate: Date().addingTimeInterval(-25200), editDate: Date().addingTimeInterval(-20000)),
            TodoItemEntity(context: context, name: "Check mailbox", creationDate: Date().addingTimeInterval(-28800), editDate: nil),
            TodoItemEntity(context: context, name: "Make dinner", creationDate: Date().addingTimeInterval(-32400), editDate: nil)

        ]
    }
}
