//
//  TodoItemEntity.swift
//  TodoList
//
//  Created by Nathan Molby on 5/5/25.
//

import CoreData

extension String {
    static let todoItem = "TodoItem"
}

@objc final class TodoItem: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        return NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }

    @NSManaged public var itemIsComplete: Bool
    @NSManaged public var creationDate: Date
    @NSManaged public var editDate: Date?
    @NSManaged public var name: String
    @NSManaged public var id: String
    
    public init(context: NSManagedObjectContext, name: String, id: String = UUID().uuidString, creationDate: Date = .now, complete: Bool = false, editDate: Date? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: "TodoItem", in: context)!
        super.init(entity: entity, insertInto: context)
        self.id = id
        self.creationDate = creationDate
        self.editDate = editDate
        self.name = name
        self.itemIsComplete = complete
    }
    
    @objc
    override private init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    @available(*, unavailable)
    public init() {
        fatalError("\(#function) not implemented")
    }

    @available(*, unavailable)
    public convenience init(context: NSManagedObjectContext) {
        fatalError("\(#function) not implemented")
    }
}

extension TodoItem : Identifiable {

}
