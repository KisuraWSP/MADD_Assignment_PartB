//
//  Persistence.swift
//  Prioritv
//
//  Created by Kisura W.S.P on 2025-10-13.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let ctx = result.container.viewContext

        let samples: [(String, Int16, TimeInterval?)] = [
            ("Buy paper & markers", 2, 3600),
            ("Team sync talking points", 3, 7200),
            ("Water the plants", 1, nil)
        ]
        samples.forEach { title, prio, delta in
            let r = Reminder(context: ctx)
            r.title = title
            r.priority = prio
            r.createdAt = Date()
            if let d = delta { r.remindAt = Date().addingTimeInterval(d) }
        }
        try? ctx.save()
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Prioritv")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
