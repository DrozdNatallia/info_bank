//
//  DataManager.swift
//  task_4
//
//  Created by Natalia Drozd on 17.01.23.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MarkersCoreDataModel")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func reset() {
        let coordinator = persistentContainer.persistentStoreCoordinator
        for store in coordinator.persistentStores where store.url != nil {
            try? coordinator.remove(store)
            try? FileManager.default.removeItem(atPath: store.url!.path)
        }
    }
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func setMarkers(name: String, latitude: Double, longitude: Double) {
        let marker = Markers(context: persistentContainer.viewContext)
        marker.name = name
        marker.latitude = latitude
        marker.longitude = longitude
    }
    
    func getMarkers() -> [Markers] {
        let request: NSFetchRequest<Markers> = Markers.fetchRequest()
        var fetchedMarkers: [Markers] = []
        do {
            fetchedMarkers = try persistentContainer.viewContext.fetch(request)
        } catch let error {
            print("Error fetching singers \(error)")
        }
        return fetchedMarkers
    }
    
    func deleteMarkers(marker: Markers) {
        let context = persistentContainer.viewContext
        context.delete(marker)
        save()
    }
}
